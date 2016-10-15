package src;

import haxe.io.Path;
import sys.io.*;
import sys.FileSystem;
import Sys.println;
import haxe.zip.Reader;
import haxe.zip.Entry;
import haxe.zip.Tools;
import haxe.zip.Writer;
import haxe.io.BytesOutput;
import haxe.crypto.Crc32;
import src.Const;

class FileHandler
{
    //
    public function new()
    {
    }

    // =============== General Functions =============== //

    /**
     * recursivly removes all of the files and sub directories within the provided directory.
     * Does not delete the provided base directory.
     *
     * @param   _path   The directory to recursivly remove.
     */
    public function removeDirRecursive(_path:String) : Void
    {
        if (FileSystem.exists(_path) && FileSystem.isDirectory(_path))
        {
            for (entry in FileSystem.readDirectory(_path))
            {
                if (FileSystem.isDirectory(Path.join([_path, entry])))
                {
                    removeDirRecursive(Path.join([_path, entry]));
                    FileSystem.deleteDirectory(Path.join([_path, entry]));
                }
                else
                {
                    FileSystem.deleteFile(Path.join([_path, entry]));
                }
            }
        }
    }

    /**
     * Searches for the package provided in the packages.list file and returns the URL for the package if found.
     *
     * @param   _package    The package to search for.
     * @return              The URL of the package or null.
     */
    public function findURL(_package:String) : String
    {
        if (FileSystem.exists(Const.getDataConfig() + "packages.list"))
        {
            var file = File.read(Const.getDataConfig() + "packages.list", false);
            try
            {
                // Package lines are split as 'name,URL' so splitting by the comma gets the name and url seperate
                // If a match based on the name is found return the url of that package
                while (!file.eof())
                {
                    var line      = file.readLine();
                    var splitLine = line.split(",");
                    
                    if (splitLine[0] == _package)
                    {
                        file.close();
                        return splitLine[1];
                    }
                }
                
                file.close();
                return null;
            }
            catch (e:haxe.io.Eof)
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }

    /**
     * Returns the name of the GMX in the project directory.
     *
     * @return      The name of the GMX. 
     */
    public function getGmx() : String
    {
        // Split the path by the '/' and try to split the basename by a period
        // If the split was successful then we assume the current directory is a GMS .gmx
        var split :Array<String> = Path.removeTrailingSlashes(Const.CURRENTDIR).split("/");
        var topDir:Array<String> = split[split.length - 1].split(".");

        // Using that info we can take the name part before the .gmx and add .project.gmx to it to get the project xml file name
        if (topDir.length >= 2)
        {
            var gmxFile:String = topDir[0] + ".project.gmx";
            var path   :String = Path.join([Const.CURRENTDIR, gmxFile]);

            if (FileSystem.exists(path))
            {
                return File.getContent(path);
            }
            else
            {
                println("Unable to find " + gmxFile);
                removeDirRecursive(Const.getDataConfig() + "tmp");
                Sys.exit(5);
                return null;
            }
        }
        else
        {
            println("not in a .gmx directory");
            removeDirRecursive(Const.getDataConfig() + "tmp");
            Sys.exit(0);
            return null;
        }
    }

    /**
     * Extracts the package archive into the tmp directory.
     *
     * @param   _package    The name of the package to extract.
     */
    public function extractPackage(_package:String) : Void
    {
        var zipPath:String = Const.getDataPack() + _package + ".gmp";
        if (FileSystem.exists(zipPath))
        {
            try
            {
                var zipBytes:sys.io.FileInput     = File.read(zipPath);
                var zipData :List<haxe.zip.Entry> = Reader.readZip(zipBytes);
                
                // Loop over every file in the archive, unzip it, and write it to the tmp folder based on its place in the archive
                for (entry in zipData)
                {
                    var filePath = entry.fileName;
                    var basePath = Path.join([Const.getDataConfig(), "tmp"]);
                    var relPath  = filePath.split("/");
                    var fileName = relPath.pop();

                    // Create the folder to store the file in
                    FileSystem.createDirectory(Path.join([basePath].concat(relPath)));

                    var data:Null<haxe.io.Bytes> = Reader.unzip(entry);
                    var file:sys.io.FileOutput   = File.write(Path.join([basePath, filePath]), true);
                    file.write(data);
                    file.close();
                }
                zipBytes.close();
            }
            catch (e:Dynamic)
            {
                Sys.println("An error has occured extracting the package zip file : " + e);
            }
        }
    }

    /**
     * Returns the content of the package manifest file.
     *
     * @param   _package    The package to get the manifest of.
     * @return              String containing the package manifest.
     */
    public function getPackageManifest(_package:String) : String
    {
        var path:String = Path.join([Const.getDataConfig(), "tmp", _package, "manifest.xml"]);
        if (FileSystem.exists(path))
        {
            return File.getContent(path);
        }
        else
        {
            println("Unable to find the package manifest.xml for " + _package);
            println("The package may be corrupt or incomplete.");
            println("Please try redownloading the package or contacting the package maintainer");
            removeDirRecursive(Const.getDataConfig() + "tmp");
            Sys.exit(7);
            return "";
        }
    }

    /**
     * Recursivly copies the content of one folder into another one.
     *
     * @param _sourceDir        The source directory to copy from.
     * @param _destinationDir   The destination directory to copy into.
     */
    public function recursiveFsCopy(_sourceDir:String, _destinationDir:String) : Void
    {
        for (item in FileSystem.readDirectory(_sourceDir))
        {
            var pathSrc :String = Path.join([_sourceDir, item]);
            var pathDest:String = Path.join([_destinationDir, item]);

            if (FileSystem.isDirectory(pathSrc))
            {
                if (!FileSystem.exists(pathDest))
                {
                    FileSystem.createDirectory(pathDest);
                }

                recursiveFsCopy(pathSrc, pathDest);
            }
            else
            {
                File.copy(pathSrc, pathDest);
            }
        }
    }

    /**
     * Copy the current .project.gmx to a backup file and write the new xml to the current .project.gmx file.
     *
     * @param   _projectXml     The XML string to write to the project gmx file.
     */
    public function writeNewXml(_projectXml:String) : Void
    {
        var split :Array<String> = Path.removeTrailingSlashes(Const.CURRENTDIR).split("/");
        var topDir:Array<String> = split[split.length - 1].split(".");

        if (topDir.length >= 2)
        {
            var gmxFile:String = topDir[0] + ".project.gmx";
            var path   :String = Path.join([Const.CURRENTDIR, gmxFile]);

            if (FileSystem.exists(path))
            {
                File.copy(path, path + ".backup");
            }

            File.saveContent(path, _projectXml);
        }
    }

    /**
     * Returns if the xml manifest of the package provided can be found in the project directory.
     *
     * @param   _pkg    The package to look for.
     * @return          True / false based on if the package was found.
     */
    public function packageIsInstalled(_pkg:String) : Bool
    {
        return FileSystem.exists(Path.join([Const.CURRENTDIR, "packages", _pkg + ".xml"]));
    }

    /// Returns the xml manifest of the package from the packages folder in the gmx directory  
    public function getInstalledManifest(_pkg:String) : String
    {
        return File.getContent(Path.join([Const.CURRENTDIR, "packages", _pkg+".xml"]));
    }

    /**
     * Checks if the package is already downloaded in the packages directory.
     *
     * @param   _package    The package to look for.
     * @return              True / false based on if the package is downloaded.
     */
    public function packageIsDownloaded(_package:String) : Bool
    {
        return FileSystem.exists(Const.getDataPack() + _package + ".gmp");
    }

    // =============== Install Functions =============== //

    /**
     * Returns if the package is in the packages.list file
     *
     * @param   _package    The package to search for.
     * @return              True / false based on if the package was found in the file
     */
    public function packageAvailable(_package:String) : Bool
    {
        if (FileSystem.exists(Const.getDataConfig() + "packages.list"))
        {
            var file:sys.io.FileInput = File.read(Const.getDataConfig() + "packages.list", false);
            try
            {
                while (!file.eof())
                {
                    var line :String        = file.readLine();
                    var split:Array<String> = line.split(",");

                    if (split[0] == _package)
                    {
                        file.close();
                        return true;
                    }
                }
            }
            catch (e:haxe.io.Eof) { /* EOF exception catch */ }

            file.close();
            return false;
        }
        else
        {
            return false;
        }
    }
    
    /**
     * Writes the package byte stream to the disk with the name provided and the .gmp extension.
     *
     * @param   _byteStream     The bytes of the package.
     * @param   _fileName       The name of the package and archive.
     */
    public function writeToFile(_byteStream:String, _fileName:String) : Void
    {
        File.write(Const.getDataPack() + _fileName + ".gmp", true).writeString(_byteStream);
        println(_byteStream.length + " bytes downloaded");
    }

    /// Loop over every item in the tmp asset directory, if its a directory copy its contents to the appropriate project directory
    public function moveAssetFiles(_pkg:String) : Void
    {
        var assetsPath:String = Path.join([Const.getDataConfig(), "tmp", _pkg]);

        // Loop through all folders in the tmp package directory
        for (item in FileSystem.readDirectory(assetsPath))
        {
            // If the current item is a directory copy it over to the project folder
            var dir:String = Path.join([assetsPath, item]);

            if (FileSystem.isDirectory(dir))
            {
                var pathDest:String = Path.join([Const.CURRENTDIR, item]);

                if (!FileSystem.exists(pathDest))
                {
                    FileSystem.createDirectory(pathDest);
                }

                recursiveFsCopy(dir, pathDest);
            }
        }
    }

    /**
     * Moves the package manifest into the project "packages" folder and rename it to the package name.
     *
     * @param   _pkg    The package to copy and rename the manifest file of.
     */
    public function moveManifestXml(_pkg:String) : Void
    {
        if (!FileSystem.exists(Path.join([Const.CURRENTDIR, "packages"])))
        {
            FileSystem.createDirectory(Path.join([Const.CURRENTDIR, "packages"]));
        }

        FileSystem.rename(Path.join([Const.getDataConfig(), "tmp", _pkg, "manifest.xml"]), Path.join([Const.CURRENTDIR, "packages", _pkg + ".xml"]));
    }

    // =============== Remove Functions =============== //

    /// Removes the package manifest file of the provided name from the current gmx project directory
    public function removeLocalManifest(_pkg:String) : Void
    {
        FileSystem.deleteFile(Path.join([Const.CURRENTDIR, "packages", _pkg+".xml"]));
    }

    /// Removes all the general resource files from the xml
    /// TODO : A fair bit of this could be cleaned up
    public function removePackageFiles(_resourcesList:List<String>, _datafilesParents:List<String>) : Void
    {
        for (item in _resourcesList)
        {
            var pwd      = Path.removeTrailingSlashes(Const.CURRENTDIR).split("/");
            var split    = item.split("\\");
            var absPath  = "/" + Path.normalize(Path.join(pwd.concat(split)));

            switch (split[0])
            {
                // scripts can removed with no changes as they are just .gml
                case "scripts":
                    if (FileSystem.exists(absPath))
                    {
                        FileSystem.deleteFile(absPath);
                    }

                case "shaders":
                    if (FileSystem.exists(absPath + ".shader"))
                    {
                        FileSystem.deleteFile(absPath + ".shader");
                    }

                //
                case "objects", "paths", "rooms", "timelines", "fonts", "sound", "background", "sprites":
                    // If the resource type has an 's' on the end of it tremove it
                    var resource = split[0];
                    if (split[0].charAt(split[0].length - 1) == "s")
                    {
                        resource = split[0].substr(0, split[0].length - 1); 
                    }

                    // General resource file checking
                    if (FileSystem.exists(absPath + "." + resource + ".gmx"))
                    {
                        FileSystem.deleteFile(absPath + "." + resource + ".gmx");
                    }

                    // Remove font files
                    if (split[0] == "fonts" && FileSystem.exists(absPath + ".png"))
                    {
                        FileSystem.deleteFile(absPath + ".png");
                    }

                    // Remove sound and background resources (could probably move this into one if eventually)
                    if (split[0] == "sound")
                    {
                        removeGeneralResource(split[1], "sound", "audio");
                    }
                    if (split[0] == "background")
                    {
                        removeGeneralResource(split[1], "background", "images");
                    }

                    // Remove sprite files
                    if (split[0] == "sprites")
                    {
                        removeSpriteFiles(split[1]);
                    }

                // Extensions special case
                case "extensions":
                    if (FileSystem.exists(absPath + ".extension.gmx"))
                    {
                        FileSystem.deleteFile(absPath + ".extension.gmx");
                    }

                    if (FileSystem.exists(absPath))
                    {
                        removeDirRecursive(absPath);
                        FileSystem.deleteDirectory(absPath);
                    }
            }
        }

        /// Looks for a folder with the same name as the item and recursivly delete it
        for (item in _datafilesParents)
        {
            //trace(_item);
            var absPath = Path.join([Const.CURRENTDIR, "datafiles"]);
            var dirPath = Path.join([absPath, item]);

            if (FileSystem.exists(dirPath) && FileSystem.isDirectory(dirPath))
            {
                removeDirRecursive(dirPath);
                FileSystem.deleteDirectory(dirPath);
            }
        }
    }

    /// Looks for a resource file with the same name as the gmx resource and deletes it
    public function removeGeneralResource(_file:String, _resource:String, _folder:String) : Void
    {
        var path    = Path.join([Const.CURRENTDIR, _resource, _folder]);
        var content = FileSystem.readDirectory(path);

        // Iterate over every item in the directory
        for (file in content)
        {
            if (!FileSystem.isDirectory(Path.join([path, file])))
            {
                var currentFile = Path.withoutExtension(file);
                if (currentFile == _file)
                {
                    FileSystem.deleteFile(Path.join([path, file]));
                }
            }
        }
    }

    /// Looks for any image files with the same name as the .sprite.gmx and removes them
    public function removeSpriteFiles(_file:String) : Void
    {
        var path    = Path.join([Const.CURRENTDIR, "sprites", "images"]);
        var content = FileSystem.readDirectory(path);

        for (file in content)
        {
            if (!FileSystem.isDirectory(Path.join([path, file])))
            {
                // GMS treats each frame as a seprate image file on disk with the _x (x being frame id int) appended to the end of the file name
                // Getting the substring of the input file with find any matches regardless of the _x part
                var fileName = file.substring(0, _file.length);
                if (fileName == _file)
                {
                    FileSystem.deleteFile(Path.join([path, file]));
                }
            }
        }
    }

    // =============== Repository Functions =============== //

    /**
     * Appends the provided string to the end of the repositories.list file.
     *
     * @param   _repo   The URL to append to the file.
     */
    public function addRepository(_repo:String) : Void
    {
        var repoPath:String            = Path.join([Const.getDataConfig(), "repositories.list"]);
        var file    :sys.io.FileOutput = File.append(repoPath, false);
        file.writeString(_repo + "\n");
        file.close();
    }

    /**
     * Removes the provided repo from the repositories.list file if found.
     *
     * @param   _repo   The URL string to look for in the file.
     */
    public function removeRepository(_repo:String) : Void
    {
        var repoPath = Path.join([Const.getDataConfig(), "repositories.list"]);

        if (FileSystem.exists(repoPath))
        {
            var repos = new List<String>();
            var file  = File.read(repoPath, false);

            // Add every line in the file to the list
            try
            {
                while (!file.eof())
                {
                    repos.add(file.readLine());
                }
            }
            catch (err:haxe.io.Eof) { /* Catch end of file */ }
            file.close();

            // Now loop over that list and only write back the lines where the repositories do not match
            var file = File.write(repoPath, false);
            for (repo in repos)
            {
                if (repo != _repo)
                {
                    file.writeString(repo + "\n");
                }
            }
            file.close();
        }
        else
        {
            Sys.println("Unable to remove repository as repositories.list could not be found");
            Sys.exit(8);
        }
    }

    /**
     * Loops over every line in the repositories.list file looking for a line which matches the argument provided.
     *
     * @param   _repo   The Repository URL to loop for.
     * @return          Returns true / false if the repo url was found.
     */
    public function repoAlreadyAdded(_repo) : Bool
    {
        var repoPath:String           = Path.join([Const.getDataConfig(), "repositories.list"]);
        var file    :sys.io.FileInput = File.read(repoPath, false);

        // Loop over each line looking for one which matches the argument
        try
        {
            while (true)
            {
                var line = file.readLine();
                if (line == _repo)
                {
                    file.close();
                    return true;
                }
            }
        }
        catch (err:Dynamic) { /* Catch end of file */ }

        file.close();
        return false;
    }

    /**
     * Open the repositories.list file and add every line to a list and then return that list
     *
     * @return  List of each line from the repositories.list file
     */
    public function getReposList() : List<String>
    {
        var list = new List<String>();
        var file:sys.io.FileInput = File.read(Path.join([Const.getDataConfig(), "repositories.list"]));

        // Loop over every line in the file and add it to a list
        try
        {
            while (!file.eof())
            {
                list.add(file.readLine());
            }
        }
        catch (err:haxe.io.Eof) { /* Catch end of file */ }

        file.close();
        return list;
    }

    public function getPackageList() : List<String>
    {
        var list = new List<String>();
        var file = File.read(Path.join([Const.getDataConfig(), "packages.list"]));

        try
        {
            while (!file.eof())
            {
                list.add(file.readLine());
            }
        }
        catch (err:haxe.io.Eof) { /* Catch end of file */ }

        file.close();
        return list;
    }

    /**
     * For each array in the provided list add the package into the package list file.
     *
     * @param   _list   List of arrays where each array contains the name and URL of a package.
     */
    public function addPackagesToList(_list:List<Array<String>>) : Void
    {
        var file:sys.io.FileOutput = File.write(Path.join([Const.getDataConfig(), "packages.list"]));

        // Write the package name and the url for each array to the packages.list file
        for (array in _list)
        {
            file.writeString(array[0] + "," + array[1] + "\n");
        }

        file.close();
    }

    // =============== Create Pkg Functions =============== //

    /**
     * Creates a folder in the tmp gmr directory and adds file to that folder then zips it up into a valid package zip.
     *
     * @param   _pkgName        The name of the package.
     * @param   _manifestXml    The xml structure to be saved into the manifest file.
     * @param   _resource       List containing the names of all the resources which need to be copied from the project dir to the tmp dir.
     * @param   _datafile       List containing the names of all the datafiles which need to be copied from the project dir to the tmp dir.
     * @param   _license        The license to add to the package.
     */
    public function createPackageDirectory(_pkgName:String, _manifestXml:Xml, _resources:List<String>, _datafiles:List<String>, _license:String) : Void
    {
        // Create a folder in the tmp dir to store the package content
        var tmpPkgDirectory = Path.join([Const.getDataConfig(), "tmp", _pkgName]);
        FileSystem.createDirectory(tmpPkgDirectory);

        // Save the manifest to directory
        File.saveContent(Path.join([tmpPkgDirectory, "manifest.xml"]), xmlTools.XmlPrinter.print(_manifestXml, false, SPACES(2)));
        
        // Copy standard resources
        for (_res in _resources)
        {
            moveResourceToPkg(_res, Const.CURRENTDIR, tmpPkgDirectory);
        }

        /**
         * Loops over every item in the project datafiles folder looking for a matching file.
         * If a matching file is found make the equivilent subdirectory in the tmp folder and copy the file over. 
         *
         * @param   _datafile   The name of the datafile to search for.
         * @param   _path       The path of the directory to search in.
         */
        function searchAndCopyDatafile(_datafile:String, _path:String) : Void
        {
            for (item in FileSystem.readDirectory(_path))
            {
                if (!FileSystem.isDirectory(Path.join([_path, item])))
                {
                    if (item == _datafile)
                    {
                        // Uses the base project datafiles path to mask and seperate the sub directory path
                        // then pop the end item off as it's the actual file name
                        var pathFull   = Path.join([_path, item]).split("/");
                        var pathOffset = Path.join([Const.CURRENTDIR, "datafiles"]).split("/");
                        var dir = pathFull.slice(pathOffset.length);
                        dir.pop();

                        // Move the file to the tmp package dir
                        var datafileDir = Path.join([tmpPkgDirectory, "datafiles"].concat(dir)); 
                        FileSystem.createDirectory(datafileDir);
                        File.copy(Path.join([_path, item]), Path.join([datafileDir, item]));
                    }
                }
                else
                {
                    searchAndCopyDatafile(_datafile, Path.join([_path, item]));
                }
            }
        }

        // Search through the directory for the datafiles found in the project xml and copy them over 
        for (_df in _datafiles)
        {
            searchAndCopyDatafile(_df, Path.join([Const.CURRENTDIR, "datafiles"]));
        }

        // Write the license to the directory
        if (_license != "")
        {
            var licenseDir:String = Path.join([Const.getDataConfig(), "tmp", _pkgName, "package"]);
            FileSystem.createDirectory(licenseDir);
            File.saveContent(Path.join([licenseDir, _pkgName + " license.txt"]), _license);
        }

        // Create an archive of the directory
        zipPackageDirectory(tmpPkgDirectory, _pkgName);

        // everything has been done, wipe the tmp dir
        removeDirRecursive(Path.join([Const.getDataConfig() + "tmp"]));
    }

    public function moveResourceToPkg(_res:String, _projDir:String, _tmpPkgDir:String) : Void
    {
        var split = _res.split("\\");
        var resType:String = split[0];
        var resName:String = split[1];

        // If the resType sub directory doesn't exist create it
        var resDir = Path.join([_tmpPkgDir, resType]);
        if (!FileSystem.exists(resDir))
        {
            FileSystem.createDirectory(resDir);
        }

        switch (resType)
        {
            case "extensions", "scripts", "shaders":
                // Based on the resType get the right file extension
                var resExt = "";
                switch (resType)
                {
                    case "extensions": resExt = ".extension.gmx";
                    case "scripts"   : resExt = "";
                    case "shaders"   : resExt = ".shader";
                }

                // Move the extension file over
                var _pathSrc  = Path.join([_projDir, resType, resName + resExt]);
                var _pathDest = Path.join([resDir  , resName + resExt]);
                File.copy(_pathSrc, _pathDest);

            case "objects", "paths", "rooms", "timelines", "fonts", "sound", "background", "sprites":
                // Create the subdir for specific resources if it doesn't exist yet 
                var subDir = "";
                switch (resType)
                {
                    case "sprites", "background": subDir = "images";
                    case "sound"                : subDir = "audio" ;
                }

                if (subDir != "")
                {
                    var _path = Path.join([_tmpPkgDir, resType, subDir]);
                    if (!FileSystem.exists(_path))
                    {
                        FileSystem.createDirectory(_path);
                    }
                }

                // Get the resource part of the path eg. .sound.gmx, .sprite.gmx
                // If the resource Type ends with 's' remove it
                var resExt = "." + resType + ".gmx";
                if (resType.charAt(resType.length - 1) == "s")
                {
                    resExt = "." + resType.substr(0, resType.length - 1) + ".gmx";
                }

                // Move the .gmx files and any additional files
                var _pathSrc = Path.join([_projDir, resType, resName + resExt]);
                var _pathDest = Path.join([resDir , resName + resExt]);
                File.copy(_pathSrc, _pathDest);

                // Font image files are not kept in a 'images' subfolder
                // they might not even need to be transfered, will have to check
                if (resType == "fonts")
                {
                    File.copy(Path.join([_projDir, resType, resName + ".png"]), Path.join([resDir, resName + ".png"]));
                }

                // Copy over any images or audio files for those resources that have them in sub directories
                if (subDir != "")
                {
                    for (file in FileSystem.readDirectory(Path.join([_projDir, resType, subDir])))
                    {
                        var _fileSplit = Path.removeTrailingSlashes(file).split("/");
                        var _fileName  = _fileSplit[_fileSplit.length - 1];

                        // if the resname can fit in the current file then cut it to the length of the resname and check if they match
                        if (_fileName.length > resName.length)
                        {
                            if (resName == _fileName.substr(0, resName.length))
                            {
                                var _pathSrc  = Path.join([_projDir, resType, subDir, file]);
                                var _pathDest = Path.join([resDir  , subDir, file]);
                                File.copy(_pathSrc, _pathDest);
                            }
                        }
                    }
                }
        }
    }

    /**
     * Loops over the created tmp package directory creating entries for each file which is added to the list
     * Then the entries are compressed and added to a zip and saved to the package directory
     *
     * @param   _basePath   The absolute path of tmp package directory
     */
    public function zipPackageDirectory(_basePath:String, _pkgName:String) : Void
    {
        var packageEntries = new List<Entry>();

        /**
         * Recursive loop over the directory creating entires for each file found
         * 
         * @param   _path   The directory to search
         */
        function createEntriesOfDir(_path:String)
        {
            for (item in FileSystem.readDirectory(_path))
            {
                var path = Path.join([_path, item]);
                if (!FileSystem.isDirectory(path))
                {
                    var pathFull   = path.split("/");
                    var pathOffset = Path.join([Const.getDataConfig(), "tmp"]).split("/");
                    var dir = Path.join(pathFull.slice(pathOffset.length));

                    var fileBytes = File.getBytes(path);
                    var entry:Entry = {
                        fileName   : dir,
                        fileSize   : fileBytes.length,
                        fileTime   : Date.now(),
                        compressed : false,
                        dataSize   : 0,
                        data       : fileBytes,
                        crc32      : Crc32.make(fileBytes)
                        };

                    Tools.compress(entry, 1);
                    packageEntries.add(entry);
                }
                else
                {
                    createEntriesOfDir(path);
                }
            }
        }

        // Start the zipping process
        createEntriesOfDir(_basePath);

        // Write the entries to a bytes stream
        var bytesOutput = new BytesOutput();
        var writer      = new Writer(bytesOutput);
        writer.write(packageEntries);

        // Write the bytes to a file
        var zippedBytes = bytesOutput.getBytes();
        var file = File.write(Path.join([Const.getDataConfig(), "packages", _pkgName + ".gmp"]), true);
        file.write(zippedBytes);
        file.close();
    }
}
