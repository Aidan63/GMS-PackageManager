package;

import utils.Help;
import utils.Log;
import utils.cli.CliParser;

class App
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
     * Starts the program, gets the initial command and calls the appropriate function.
     */
    public function run()
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

    private function processInstall()
    {
        var options :Map<String, String> = CliParser.getOptionsMap("install", arguments);
        var optLocal:Bool = options.exists("local"  ) ? true : false;
        var optDl   :Bool = options.exists("dl-only") ? true : false;
        var optGit  :String = options.exists("git"  ) ? options.get("git" ) : "";
        var optPath :String = options.exists("path" ) ? options.get("path") : "";

        Log.debug(options.toString());
    }

    private function processAddRepo()
    {
        Log.debug("add-repo");
    }

    private function processCreatePkg() {}
    private function processHelp() {}
    private function processList() {}
    private function processRemove() {}
    private function processRemoveRepo() {}
    private function processUpdate() {}
    private function processUpgrade() {}
}
