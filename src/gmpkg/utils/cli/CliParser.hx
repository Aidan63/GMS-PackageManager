package gmpkg.utils.cli;

import gmpkg.utils.cli.CliArguments;

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
     * Takes the arguments and creates a map of the provided options and the value for each one.
     */
    public static function getOptionsMap(_cmd:String, _arguments:Array<String>):Map<String, String>
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
        for (arg in _arguments)
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
                    optionsMap.set(args.getOptionFullName(_cmd, opt), values.shift());
                }
                else
                {
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
}
