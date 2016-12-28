package utils.cli;

import utils.Help;
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
     * Parses the arguments and calls the apropriate sub functions or print error messages.
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
                Help.printUnknownCommand(cmd);
            }
        }
        else
        {
            Help.printNoCommand();
        }
    }

    /**
     * Takes the arguments and creates a map of the provided options and the value for each one.
     */
    private function getOptionsMap(_cmd:String):Map<String, String>
    {
        var args    = new CliArguments();
        // Arrays to hold all options and values.
        var options = new Array<String>();
        var values  = new Array<String>();

        // Map to hold each option and it's value
        var optionsMap = new Map<String, String>();

        // arguments begining with one or two dashes are options.
        // They are added to the options array with the dashes removed.
        // Otherwise the argument is added to the values list.
        for (arg in arguments)
        {
            if (arg.charAt(0) == "-")
            {
                if (arg.charAt(1) == "-")
                {
                    options.push(arg.substring(2));
                }
                else
                {
                    options.push(arg.substring(1));
                }
            }
            else
            {
                values.push(arg);
            }
        }

        // For each option add it to the map if it exists along with a value if it expects one.
        // values are also removed from the arguments list so all option releated arguments are gone.
        for (opt in options)
        {
            if (args.optionExists(_cmd, opt))
            {
                if (args.optionExpectsValue(_cmd, opt))
                {
                    arguments.shift();
                    arguments.shift();

                    optionsMap.set(args.getOptionFullName(_cmd, opt), values.shift());
                }
                else
                {
                    arguments.shift();
                    optionsMap.set(args.getOptionFullName(_cmd, opt), "");
                }
            }
            else
            {
                Log.error('Unknown option "$opt"');
                Sys.exit(0);
            }
        }

        return optionsMap;
    }

    private function processInstall()
    {
        var options:Map<String, String> = getOptionsMap("install");
        Log.debug(options.toString());
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
