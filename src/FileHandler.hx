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
        //
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
                while (!file.eof())
                {
                    var _line      = file.readLine();
                    var _splitLine = _line.split(",");
                    
                    if (_splitLine[0] == _package)
                    {
                        file.close();
                        return _splitLine[1];
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
        var split  = Path.removeTrailingSlashes(Const.CURRENTDIR).split("/");
        var topDir = split[split.length - 1].split(".");

        if (topDir.length >= 2)
        {
            var sb = new StringBuf();
            sb.add(topDir[0]);
            sb.add(".project.gmx");

            var path = Path.join([Const.CURRENTDIR, sb.toString()]);
            if (FileSystem.exists(path))
            {
                return File.getContent(path);
            }
            else
            {
                println("Unable to find " + split[split.length - 1] + ".project.gmx");
                removeDirRecursive(Const.getDataConfig() + "tmp");
                Sys.exit(0);
                return "";
            }
        }
        else
        {
            println("not in a .gmx directory");
            removeDirRecursive(Const.getDataConfig() + "tmp");
            Sys.exit(0);
            return "";
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
                
                for (_entry in zipData)
                {
                    var fileName  = _entry.fileName;
                    var structure = Path.removeTrailingSlashes(fileName).split("/");
                    var basePath  = Const.getDataConfig() + "tmp";

                    if (Path.extension(structure[structure.length - 1]) == "")
                    {
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
                        var data = Reader.unzip(_entry);
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
            Sys.exit(0);
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
            var sb = new StringBuf();
            sb.add(topDir[0]);
            sb.add(".project.gmx");

            var path = Path.join([Const.CURRENTDIR, sb.toString()]);

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

    // =============== Install Functions =============== //

    /// Returns true / false if the package provided is found in the packges.list file
    public function packageAvailable(_package:String) : Bool
    {
        if (FileSystem.exists(Const.getDataConfig() + "packages.list"))
        {
            var file = File.read(Const.getDataConfig() + "packages.list", false);
            while (!file.eof())
            {
                var line = file.readLine();
                var split = line.split(",");

                if (split[0] == _package)
                {
                    file.close();
                    return true;
                }
            }

            file.close();
            return false;
        }
        else
        {
            return false;
        }
    }

    /// Returns true / false if there is a zip file of the package provided
    public function packageIsDownloaded(_package:String) : Bool
    {
        if (FileSystem.exists(Const.getDataPack() + _package + ".gmp"))
        {
            return true;
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
    public function removePackageFiles(_resourcesList:List<String>, _datafilesParents:List<String>) : Void
    {
        for (_item in _resourcesList)
        {
            var pwd      = Path.removeTrailingSlashes(Const.CURRENTDIR).split("/");
            var split    = _item.split("\\");
            var absPath  = "/" + Path.normalize(Path.join(pwd.concat(split)));

            switch (split[0])
            {
                // The following resources have .$tpye.gmx appended to the end or nothing for scripts
                case "scripts":
                    if (FileSystem.exists(absPath))
                    {
                        FileSystem.deleteFile(absPath);
                    }

                case "objects":
                    if (FileSystem.exists(absPath + ".object.gmx"))
                    {
                        FileSystem.deleteFile(absPath + ".object.gmx");
                    }

                case "paths":
                    if (FileSystem.exists(absPath + ".path.gmx"))
                    {
                        FileSystem.deleteFile(absPath + ".path.gmx");
                    }

                case "rooms":
                    if (FileSystem.exists(absPath + ".room.gmx"))
                    {
                        FileSystem.deleteFile(absPath + ".room.gmx");
                    }

                case "shaders":
                    if (FileSystem.exists(absPath + ".shader"))
                    {
                        FileSystem.deleteFile(absPath + ".shader");
                    }

                case "timelines":
                    if (FileSystem.exists(absPath + ".timeline.gmx"))
                    {
                        FileSystem.deleteFile(absPath + ".timeline.gmx");
                    }

                // Fonts create a png consisting of that font in the same folder as the .font.gmx
                case "fonts":
                    if (FileSystem.exists(absPath + ".font.gmx"))
                    {
                        FileSystem.deleteFile(absPath + ".font.gmx");
                    }
                    if (FileSystem.exists(absPath + ".png"))
                    {
                        FileSystem.deleteFile(absPath + ".png");
                    }
                    
                // Probably Shaders

                // The following resources have extra files which need to removed as well
                case "sound":
                    if (FileSystem.exists(absPath + ".sound.gmx"))
                    {
                        FileSystem.deleteFile(absPath + ".sound.gmx");
                    }

                    removeGeneralResource(split[1], "sound", "audio");

                case "background":
                    if (FileSystem.exists(absPath + ".background.gmx"))
                    {
                        FileSystem.deleteFile(absPath + ".background.gmx");
                    }

                    removeGeneralResource(split[1], "background", "images");

                case "sprites":
                    if (FileSystem.exists(absPath + ".sprite.gmx"))
                    {
                        FileSystem.deleteFile(absPath + ".sprite.gmx");
                    }

                    removeSpriteFiles(split[1]);

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

        // TODO : Remove datafiles
        for (_item in _datafilesParents)
        {
            //trace(_item);
            var absPath = Path.join([Const.CURRENTDIR, "datafiles"]);
            var dirPath = Path.join([absPath, _item]);

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
                // GMS treats each frame as a seprate image file on disk with the _x appended to the end of the file name
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
        var content  = File.getContent(repoPath);
        var repos    = new List<String>();

        var file = File.read(repoPath, false);
        try
        {
            while (true)
            {
                repos.add(file.readLine());
            }
            file.close();
        }
        catch (err:Dynamic) {}

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

        try {
            while (!file.eof())
            {
                list.add(file.readLine());
            }
        }
        catch (err:Dynamic) {}

        file.close();

        return list;
    }

    public function addPackagesToList(_list:List<Array<String>>, _pkgNumb:Int) : Int
    {
        var file = File.write(Path.join([Const.getDataConfig(), "packages.list"]));

        for (array in _list)
        {
            file.writeString(array[0] + "," + array[1] + "\n");
            _pkgNumb ++;
        }

        file.close();

        return _pkgNumb;
    }
}
