package src.functions;

import src.WebDownloader;
import src.FileHandler;
import src.XmlReader;

class AddRepo
{
    public function new(_args:Array<String>)
    {
        if (_args.length > 0)
        {
            addRepository(_args[0]);
        }
        else
        {
            printHelp();
        }
    }

    /**
     * Adds the provided repo to the repositories.list file if it's not already added and attempts to download the manifest file to print info.
     *
     * @param   _repo   The repository URL to add.
     */
    public function addRepository(_repo:String) : Void
    {
        var fh    = new FileHandler();
        var webDl = new WebDownloader();
        var xmlR  = new XmlReader();

        if (!fh.repoAlreadyAdded(_repo))
        {
            // Get the repo xml file 
            var repoXml:String = webDl.getRepository(_repo);

            if (repoXml != "")
            {
                // Add the repo url to the repositories.list file
                fh.addRepository(_repo);

                // Return a map with info about the repo
                var results:Map<String, String> = xmlR.readRepoXml(repoXml);

                // Print out some info about the added repo
                Sys.println(results.get("name") + " successfully added");
                Sys.println("Owned by " + results.get("owner") + ":" + results.get("email"));
            }
        }
        else
        {
            Sys.println("Repository is already added");
            Sys.exit(0);
        }
    }

    /**
     * Prints help information if no arguments were provided.
     */
    public function printHelp() : Void
    {
        Sys.println("You must specify a repository URL to add when using the 'add-repository' command.");
        Sys.println("");
        Sys.println("   Usage: gmr add-repository $repoURL");
    }
}
