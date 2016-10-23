package src.cliParser;

import haxe.macro.Expr;
import haxe.macro.Context;
import src.functions.*;

class CLIParser
{
    private var arguments:Array<String>;

    public function new(_args)
    {
        arguments = _args;
    }

    /**
     * Gets the cli options
     */
    public function parseInput() : Void
    {
        if (arguments.length > 0)
        {
            var cmd    : String              = popTopItem();
            var options: Map<String, String> = getCliOptions();
            switch (cmd.toUpperCase())
            {
                case "INSTALL":
                    var install = new Install(options, arguments);

                case "REMOVE":
                    var remvove = new Remove(options, arguments);

                case "UPDATE":
                    var update = new Update();

                case "UPGRADE":

                case "ADD-REPOSITORY":

                case "REMOVE-REPOSITORY":

                case "LIST":

                case "CREATE":

                case "VERSION":
                    printVersion();

                default:
                    trace("Unknown command " + cmd);
            }
        }
        else
        {
            printHelp();
        }
    }

    /**
     * Gets the CLI options and the values and returns them in a map structure.
     *
     * @return      Map with the key being each cli options and the value being the value of the option.
     */
    public function getCliOptions() : Map<String, String>
    {
        var optionsMap  = new Map<String, String>();
        var optionsList = new List<String>();

        for (arg in arguments)
        {
            // If the first two characters are dashes then it's a full name option.
            if (arg.charAt(0) == "-" && arg.charAt(1) == "-")
            {
                optionsList.add(popTopItem().substr(2));
            }
            // with a single dash each following character represents an option.
            else if (arg.charAt(0) == "-" && arg.charAt(1) != "-")
            {
                var newArg = arg.substr(1);
                for (char in 0...newArg.length)
                {
                    optionsList.add(newArg.charAt(char));
                }
                popTopItem();
            }
        }

        // Loop over each option in the list and add the matching argument to the map.
        var i = 0;
        for (item in optionsList)
        {
            optionsMap.set(item, arguments[i]);
            i ++;
        }

        // Removes all of the now unneeded items from the option arguments.
        for (item in optionsList)
        {
            popTopItem();
        }

        return optionsMap;
    }

    /**
     * Removes and returns the top item from the arguments array.
     *
     * @return          The item removed from the array.
     */
    public function popTopItem() : String
    {
        var item  = arguments[0];
        arguments = arguments.slice(1);

        return item;
    }

    /**
     * Prints basic help for the program.
     */
    private function printHelp()
    {
        Sys.println("GameMaker:Studio Package Manager");
        Sys.println("type 'gmr help' for a list of commands and their usage");
    }

    /**
     * Prints the version with the short git commit hash.
     */
    private function printVersion()
    {
        Sys.println("v0.1.0+" + getGitCommitHash().substring(0, 7));
    }

    /**
     * Returns the git commit hash for the current commit.
     *
     * @return      String containing the current commit hash.
     */
    public static macro function getGitCommitHash() : haxe.macro.ExprOf<String>
    {
        #if !display
        var process = new sys.io.Process('git', ['rev-parse', 'HEAD']);
        if (process.exitCode() != 0)
        {
            var message = process.stderr.readAll().toString();
            var pos     = haxe.macro.Context.currentPos();
            Context.error("Cannot execute 'git rev-parse HEAD'. " + message, pos);
        }

        var commitHash:String = process.stdout.readLine();
        return macro $v{commitHash};
        #else
        var commitHash:String = "";
        return macro $v{commitHash};
        #end
    }
}
