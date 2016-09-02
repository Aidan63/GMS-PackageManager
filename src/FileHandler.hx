package src;

import haxe.io.Path;
import sys.io.*;
import sys.FileSystem;
import Sys.println;
import haxe.zip.Reader;
import src.Const;

class FileHandler
{
    //
    public function new()
    {
    }

    // =============== General Functions =============== //

    // Removes all files and folders within the folder provided in the argument
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

    // Returns the url for the package provided
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

    /// Returns the GMX in the current directory
    public function getGmx() : String
    {
        // Split the path by the '/' and try to split the basename by a period
        // If the split was successful then we assume the current directory is a GMS .gmx
        var split  = Path.removeTrailingSlashes(Const.CURRENTDIR).split("/");
        var topDir = split[split.length - 1].split(".");

        // Using that info we can take the name part before the .gmx and add .project.gmx to it to get the project xml file name
        if (topDir.length >= 2)
        {
            var gmxFile = topDir[0] + ".project.gmx";
            var path = Path.join([Const.CURRENTDIR, gmxFile]);

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

    // Extracts the provided packges zip file into the tmp folder
    public function extractPackage(_package:String) : Void
    {
        var zipPath = Const.getDataPack() + _package + ".gmp";
        if (FileSystem.exists(zipPath))
        {
            try
            {
                var zipBytes = File.read(zipPath);
                var zipData = Reader.readZip(zipBytes);
                
                // Loop over every file in the archive, unzip it, and write it to the tmp folder based on its place in the archive
                for (entry in zipData)
                {
                    var fileName  = entry.fileName;
                    var structure = Path.removeTrailingSlashes(fileName).split("/");
                    var basePath  = Const.getDataConfig() + "tmp";

                    // Current item has no file extension so is assumed to be a folder
                    if (Path.extension(structure[structure.length - 1]) == "")
                    {
                        // Create that directory based on its position in the archive
                        var path = "";
                        for (item in structure)
                        {
                            path += "/" + item;
                            FileSystem.createDirectory(Path.join([basePath, path]));
                        }
                    }
                    else
                    {
                        // Create the path structure to store the file in the correct folder
                        var data = Reader.unzip(entry);
                        var file = File.write(basePath + "/" + fileName, true);
                        file.write(data);
                        file.close();
                    }
                }
                zipBytes.close();
            }
            catch (e:Dynamic)
            {
                trace("An error has occured extracting the package zip file", e);
            }
        }
    }

    /// Returns a string containing the package manifest xml
    public function getPackageManifest(_package:String) : String
    {
        var path = Path.join([Const.getDataConfig(), "tmp", _package, "manifest.xml"]);
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

    /// Copy the entire contents of one directory into another
    public function recursiveFsCopy(_sourceDir:String, _destinationDir:String) : Void
    {
        // Start to recursivly copy files and create folders
        for (item in FileSystem.readDirectory(_sourceDir))
        {
            var pathSrc  = Path.join([_sourceDir, item]);
            var pathDest = Path.join([_destinationDir, item]);

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

    /// Copy the current .project.gmx to a backup file and write the new xml to the current .project.gmx file
    public function writeNewXml(_projectXml:String) : Void
    {
        var split  = Path.removeTrailingSlashes(Const.CURRENTDIR).split("/");
        var topDir = split[split.length - 1].split(".");

        if (topDir.length >= 2)
        {
            var gmxFile = topDir[0] + ".project.gmx";
            var path = Path.join([Const.CURRENTDIR, gmxFile]);

            if (FileSystem.exists(path))
            {
                File.copy(path, path + ".backup");
            }

            File.saveContent(path, _projectXml);
        }
    }

    /// Returns true for a package being installed if an xml file with the argument name is found
    public function packageIsInstalled(_pkg:String) : Bool
    {
        return FileSystem.exists(Path.join([Const.CURRENTDIR, "packages", _pkg+".xml"]));
    }

    /// Returns the xml manifest of the package from the packages folder in the gmx directory  
    public function getInstalledManifest(_pkg:String) : String
    {
        return File.getContent(Path.join([Const.CURRENTDIR, "packages", _pkg+".xml"]));
    }

    /// Returns true / false if there is a zip file of the package provided
    public function packageIsDownloaded(_package:String) : Bool
    {
        return FileSystem.exists(Const.getDataPack() + _package + ".gmp");
    }

    // =============== Install Functions =============== //

    /// Returns a bool based on if the package provided is found in the packges.list file
    public function packageAvailable(_package:String) : Bool
    {
        if (FileSystem.exists(Const.getDataConfig() + "packages.list"))
        {
            var file = File.read(Const.getDataConfig() + "packages.list", false);
            try
            {
                while (!file.eof())
                {
                    var line  = file.readLine();
                    var split = line.split(",");

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
    
    // Writes the downloaded zip file to the package folder
    public function writeToFile(_byteStream:String, _fileName:String) : Void
    {
        File.write(Const.getDataPack() + _fileName + ".gmp", true).writeString(_byteStream);
        println(_byteStream.length + " bytes downloaded");
    }

    /// Loop over every item in the tmp asset directory, if its a directory copy its contents to the appropriate project directory
    public function moveAssetFiles(_pkg:String) : Void
    {
        var assetsPath = Path.join([Const.getDataConfig(), "tmp", _pkg]);

        // Loop through all folders in the tmp package directory
        for (item in FileSystem.readDirectory(assetsPath))
        {
            // If the current item is a directory copy it over to the project folder
            var dir = Path.join([assetsPath, item]);

            if (FileSystem.isDirectory(dir))
            {
                var pathDest = Path.join([Const.CURRENTDIR, item]);

                if (!FileSystem.exists(pathDest))
                {
                    FileSystem.createDirectory(pathDest);
                }

                recursiveFsCopy(dir, pathDest);
            }
        }
    }

    /// Moves the package manifest into the project "packages" folder and rename it to $packageName.xml
    public function moveManifestXml(_pkg:String) : Void
    {
        if (!FileSystem.exists(Path.join([Const.CURRENTDIR, "packages"])))
        {
            FileSystem.createDirectory(Path.join([Const.CURRENTDIR, "packages"]));
        }

        FileSystem.rename(Path.join([Const.getDataConfig(), "tmp", _pkg, "manifest.xml"]), Path.join([Const.CURRENTDIR, "packages", _pkg+".xml"]));
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

    /// Adds a url to the repositories.list file
    public function addRepository(_repo:String) : Void
    {
        var repoPath = Path.join([Const.getDataConfig(), "repositories.list"]);
        var file     = File.append(repoPath, false);
        file.writeString(_repo + "\n");
        file.close();
    }

    /// Removes a url from the repositories.list file
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

    /// Returns if the repo has already been added to the repositories.list file
    public function repoAlreadyAdded(_repo) : Bool
    {
        var repoPath = Path.join([Const.getDataConfig(), "repositories.list"]);
        var file     = File.read(repoPath, false);

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

    /// Returns a list of every repo url from repositories.list
    public function getReposList() : List<String>
    {
        var list = new List<String>();
        var file = File.read(Path.join([Const.getDataConfig(), "repositories.list"]));

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

    /// Adds package names and their url to the packages.list file and returns the number of packages added
    public function addPackagesToList(_list:List<Array<String>>, _pkgNumb:Int) : Int
    {
        var file = File.write(Path.join([Const.getDataConfig(), "packages.list"]));

        // Write the package name and the url for each array to the packages.list file
        for (array in _list)
        {
            file.writeString(array[0] + "," + array[1] + "\n");
            _pkgNumb ++;
        }

        file.close();
        return _pkgNumb;
    }
}
