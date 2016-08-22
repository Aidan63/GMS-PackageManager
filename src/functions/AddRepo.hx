package src.functions;

import src.WebDownloader;
import src.FileHandler;
import src.XmlReader;

class AddRepo
{
    public function new()
    {
        //
    }

    public function addRepository(_repo:String) : Void
    {
        var fh    = new FileHandler();
        var webDl = new WebDownloader();
        var xmlR  = new XmlReader();

        if (!fh.repoAlreadyAdded(_repo))
        {
            // Get the repo xml file 
            var repoXml = webDl.getRepository(_repo);

            if (repoXml != "")
            {
                // Add the repo url to the repositories.list file
                fh.addRepository(_repo);

                // Return a map with info about the repo
                var results = xmlR.readRepoXml(repoXml);

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
}
