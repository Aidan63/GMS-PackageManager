package;

import Sys.args;
import src.FileHandler;
import src.XmlReader;
import src.functions.*;

class Main
{
    public static function main()
    {
        var cliArgs:Array<String> = args();
        if (cliArgs.length > 0)
        {            
            switch (cliArgs[0])
            {
                case "update":
                    var update = new Update();
                    update.updatePackages();
                    
                case "upgrade":
                    trace("Upgrade");
                    
                case "install":
                    cliArgs.remove("install");
                    var install = new Install(cliArgs);

                case "remove":
                    cliArgs.remove("remove");

                    var remove = new Remove();
                    remove.removePackages(cliArgs);
                                    
                case "add-repository":
                    cliArgs.remove("add-repository");
                    
                    var ar:AddRepo = new AddRepo();
                    ar.addRepository(cliArgs[0]);
                    
                case "remove-repository":
                    cliArgs.remove("remove-repository");
                    
                    var fh:FileHandler = new FileHandler();
                    fh.removeRepository(cliArgs[0]);
                    
                case "self-upgrade":
                    trace("Self Upgrade");

                case "find":
                    trace("find");

                case "list":
                    trace("list");

                case "help":
                    trace("help");

                case "version":
                    Sys.println("GMR v0.1.0+0000000");
                    
                default:
                    trace("no such command");
            }
        }
        else
        {
            Sys.println("GameMaker:Studio Package Manager v0.1.0+0000000");
            Sys.println("Type 'gmr help' for a list of commands and their usage");
        }
    }
}
