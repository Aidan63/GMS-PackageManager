package src.cliParser;

import Sys.println;

class Help
{
    public function new(_args:Array<String>)
    {
        if (_args.length > 0)
        {
            printCommandHelp(_args[0]);
        }
        else
        {
            printShortHelp();
        }
    }

    private function printShortHelp()
    {
        println("GameMaker:Studio Package Manager");
        println("for more in depth information on a command type 'gmr help $command'.");
        println("");
        println("Commands:");
        println("");
        println("install : Installs the specified package(s) to a project.");
        println("remove  : Removes the specified packages(s) from a project.");
        println("update  : Fetches the latest information about packages from all repositories.");
        println("upgrade : Updates all packages install in the project to the latest version.");
        println("list    : Lists all available packages and the repository they come from.");
        println("create  : Creates a package from the project folder");
        println("add-repository    : Adds the repository so it's packages can be downloaded.");
        println("remove-repository : Removes the repository from the config file.");
    }

    private function printCommandHelp(_cmd:String)
    {
        switch (_cmd.toUpperCase())
        {
            case "INSTALL":
                printHelpInstall();

            case "REMOVE":

            case "UPDATE":

            case "UPGRADE":

            case "LIST":

            case "ADD-REPOSITORY":

            case "REMOVE-REPOSITORY":

            case "CREATE":

            case "HELP":
        }
    }

    // ---------------------------------- //

    private function printHelpInstall()
    {
        println("Install");
        println("Adds the specified package(s) to a GMS project folder.");
        println("With no options supplied the command must be ran within the project folder.");
        println("");
        println("Examples:");
        println("");
        println("   gmr install $package");
        println("   gmr install $package1 $package2");
        println("   gmr install --path /home/aidan/GameMakerStudio/MyProject.gmx $package");
        println("");
        println("Options:");
        println("");
        println("--path     -p :");
        println("   Specifies a path to a project for the package to be install to.");
        println("--folder   -f :");
        println("   Specifies a folder within the project to try and install the package to.");
        println("--download -d :");
        println("   Downloads the package to the package storage and does not install it.");
        println("--local    -l :");
        println("   Installs a package from the speicified path.");
    }
}