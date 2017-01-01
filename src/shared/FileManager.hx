package shared;

import haxe.io.Path;

class FileManager
{
    /**
     * Gets the base directory for storing all config files based on the operating system.
     *
     * @param   _os OS parameter for unit testing, if left blank Sys.systemName() is used.
     * @return      String containing the base config directory.
     */
    public static function getDataStorage(?_os:String):String
    {
        if (_os == null)
        {
            _os = Sys.systemName();
        }

        var directory:String = "";
        switch (_os)
        {
            case "Windows":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("LOCALAPPDATA"), "gmpkg"]));
            case "Mac":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), "Library", "Application Support", "gmpkg"]));
            case "Linux":
                return Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), ".config", "gmpkg"]));
        }

        return directory;
    }
}
