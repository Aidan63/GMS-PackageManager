package;

import Sys.args;
import src.FileHandler;
import src.functions.*;
import src.Const;

class Main
{
    public static function main()
    {
        Const.setupStorage();
        
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
                    var remove = new Remove(cliArgs);
                                    
                case "add-repository":
                    cliArgs.remove("add-repository");
                    var ar:AddRepo = new AddRepo(cliArgs);
                    
                case "remove-repository":
                    cliArgs.remove("remove-repository");
                    
                    var fh:FileHandler = new FileHandler();
                    fh.removeRepository(cliArgs[0]);
                    
                case "create":
                    var pkg:CreatePackage = new CreatePackage();

                case "self-upgrade":
                    trace("Self Upgrade");

                case "find":
                    trace("find");

                case "list":
                    var ls:ListPkgs = new ListPkgs();

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
