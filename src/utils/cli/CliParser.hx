package utils.cli;

import utils.Log;
import utils.cli.CliArguments;

/**
 * Parses the cli arguments and calls the appropriate function with options values passed to it.
 *
 * @author  Aidan Lee <aidan.lee63@gmail.com>
 * @version 1.0.0
 * @since   0.2.0
 */
class CliParser
{
    /**
     * Holds all of the cli arguments provided when the program was ran.
     */
    private var arguments:Array<String>;

    public function new(_args:Array<String>)
    {
        arguments = _args;
    }

    /**
     * Parses the arguments and calls the apropriate sub functions.
     */
    public function parse()
    {
        if (arguments.length > 0)
        {
            var cmd:String = arguments[0].toUpperCase();
            switch (cmd)
            {
                // Shared Commands
                case "ADDREPO":
                    Log.debug("add repo");
                case "REMOVEREPO":
                    Log.debug("remove repo");
                case "HELP":
                    Log.debug("help");
                case "LISTPKGS":
                    Log.debug("list pkgs");
                case "UPDATE":
                    Log.debug("update");

                // Backend Specific
                case "CREATEPKG":
                    Log.debug("create pkg");
                case "INSTALL":
                    Log.debug("install");
                case "REMOVE":
                    Log.debug("remove");
                case "UPGRADE":
                    Log.debug("upgrade");
            }
        }
        else
        {
            Log.error("No arguments provided!");
            Log.info ("Run 'gmpkg help' for a list of all commands and usage");
        }
    }
}
