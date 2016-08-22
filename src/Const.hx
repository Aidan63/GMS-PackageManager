package src;

import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import Sys;

class Const
{
    public static var CURRENTDIR:String = Sys.getCwd();

    /// Creates the directories for storing the packages and repo info
    public static function setupStorage() : Void
    {
        if (!FileSystem.exists(getDataConfig()))
        {
            FileSystem.createDirectory(getDataConfig());
            FileSystem.createDirectory(getDataPack());
            FileSystem.createDirectory(Path.join([getDataConfig(), "tmp"]));

            // Opening a file in write mode will create the file even if we don't write any data
            var fileRepo = File.write(Path.join([getDataConfig(), "repositories.list"]));
            var filePkgs = File.write(Path.join([getDataConfig(), "packages.list"]));

            fileRepo.close();
            filePkgs.close();
        }
    }

    /// Returns the path for the base config storage
    public static function getDataConfig() : String
    {
        switch (Sys.systemName())
        {
            case "Windows":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("LOCALAPPDATA"), "gmr"]));

            case "Mac":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), "Library", "Application Support", "gmr"]));

            case "Linux":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), ".config", "gmr"]));
        }

        Sys.exit(1);
        return "";
    }

    /// Returns the path for the folder where packages are stored
    public static function getDataPack() : String
    {
        switch (Sys.systemName())
        {
            case "Windows":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("LOCALAPPDATA"), "gmr", "packages"]));

            case "Mac":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), "Library", "Application Support", "gmr", "packages"]));

            case "Linux":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), ".config", "gmr", "packages"]));
        }

        Sys.exit(1);
        return "";
    }
}
