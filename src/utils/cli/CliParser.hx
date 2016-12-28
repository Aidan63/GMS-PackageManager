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

    /**
     * Holds mapping of the program commands to a function to call for each one.
     */
    private var argFunctionMapping:Map<String, Void->Void>;

    /**
     * Sets arguments to the array passed and creates the map of commands and function.
     */
    public function new(_args:Array<String>)
    {
        arguments = _args;

        argFunctionMapping = [
            "ADD-REPO"    => processAddRepo,
            "REMOVE-REPO" => processRemoveRepo,
            "HELP"        => processHelp,
            "LIST"        => processList,
            "UPDATE"      => processUpdate,

            "CREATE-PKG"  => processCreatePkg,
            "INSTALL"     => processInstall,
            "REMOVE"      => processRemove,
            "UPGRADE"     => processUpgrade
        ];
    }

    /**
     * Parses the arguments and calls the apropriate sub functions.
     */
    public function parse()
    {
        if (arguments.length > 0)
        {
            var cmd:String = arguments.shift().toUpperCase();

            if (argFunctionMapping.exists(cmd))
            {
                var func = argFunctionMapping.get(cmd);
                func();
            }
            else
            {
                Log.error('Unknown command $cmd');
                Log.info ("Run 'gmpkg help' for a list of all commands and usage");
            }
        }
        else
        {
            Log.error("No arguments provided!");
            Log.info ("Run 'gmpkg help' for a list of all commands and usage");
        }
    }

    private function processInstall()
    {
        Log.debug("Works");
    }

    private function processAddRepo() {}
    private function processCreatePkg() {}
    private function processHelp() {}
    
    private function processList() {}
    private function processRemove() {}
    private function processRemoveRepo() {}
    private function processUpdate() {}
    private function processUpgrade() {}
}
