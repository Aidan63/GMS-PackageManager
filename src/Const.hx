package src;

import haxe.io.Path;
import Sys;

class Const
{
    public static var CURRENTDIR:String = Sys.getCwd();

    public function new()
    {
        //
    }

    public static function getDataConfig() : String
    {
        switch (Sys.systemName())
        {
            case "Windows":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("LOCALAPPDATA"), "gmr"]));

            case "Mac":
                return "";

            case "Linux":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), ".config/gmr"]));
        }

        Sys.exit(1);
        return "";
    }

    public static function getDataPack() : String
    {
        switch (Sys.systemName())
        {
            case "Windows":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("LOCALAPPDATA"), "gmr/packages"]));

            case "Mac":
                return "";

            case "Linux":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), ".config/gmr/packages"]));
        }

        Sys.exit(1);
        return "";
    }
}
