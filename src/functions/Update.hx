package src.functions;

import src.WebDownloader;
import src.FileHandler;
import src.XmlReader;

class Update
{
    public function new()
    {
        //
    }

    public function updatePackages() : Void
    {
        var fh    = new FileHandler();
        var webDl = new WebDownloader();
        var xmlR  = new XmlReader();

        // Get a list all repos
        var repoList = fh.getReposList();
        var pkgNumb  = 0;
        for (repo in repoList)
        {
            // Download each repos xml
            var xml  = webDl.getRepository(repo);
            if (xml != "")
            {
                Sys.println(repo + " reached");
                var list = xmlR.readRepoPackages(xml);
                pkgNumb += fh.addPackagesToList(list, pkgNumb);
            }
        }

        Sys.println(Std.string(pkgNumb) + " packages found");
    }
}
