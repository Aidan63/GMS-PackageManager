package utils;

import utils.Log;

/**
 * Contains functions for printing help for the program commands.
 *
 * @author  Aidan Lee <aidan.lee63@gmail.com>
 * @version 1.1.0
 * @since   0.2.0
 */
class Help
{
    /**
     * Prints help for the install command.
     */
    public static function printHelpInstall()
    {
        Log.info ("Install");
        Log.print("Adds a specified package(s) to a GMS project folder.");
        Log.print("Visit $URL for full documentation on this command.");
        Log.print("");
        Log.info ("Examples");
        Log.print("");
        Log.print("    gmpkg install $package");
        Log.print("    gmpkg install $package1 $package2");
        Log.print("    gmpkg install --path /home/aidan/GMSProject/MyProject.gmx $package");
        Log.print("");
        Log.info ("Options");
        Log.print("");
        Log.info ("-p --project");
        Log.print("    Specifies the project directory to install the package(s) to.");
        Log.info ("-d --dl-only");
        Log.print("    Only downloads the package, does not install it.");
        Log.info ("-l --local");
        Log.print("    Install the package from the specified local file.");
        Log.info ("-g --git");
        Log.print("    Install a package from the git repository provided.");
    }

    /**
     * Prints text for an unknown command.
     *
     * @param   _cmd    The unknown command the user entered.
     */
    public static function printUnknownCommand(_cmd:String)
    {
        Log.error('Unknown command $_cmd');
        Log.info ("Run 'gmpkg help' for a list of all commands and usage.");
    }

    /**
     * Prints text for when no command is provided.
     */
    public static function printNoCommand()
    {
        Log.error("No command provided");
        Log.info ("Run 'gmpkg help' for a list of all commands and usage.");
    }
}