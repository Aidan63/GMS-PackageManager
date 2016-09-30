package src.functions;

import src.WebDownloader;
import src.FileHandler;
import src.XmlReader;

class Update
{
    public function new()
    {
    }

    /**
     * For each url in the repositories.list file attempt to download the manifest and for each package inside add it to the packages.list file
     */
    public function updatePackages() : Void
    {
        var fh    = new FileHandler();
        var webDl = new WebDownloader();
        var xmlR  = new XmlReader();

        // Get a list all repos
        var repoList:List<String> = fh.getReposList();
        var pkgNumb = 0;
        for (repo in repoList)
        {
            // Download each repos xml
            var xml:String = webDl.getRepository(repo);
            if (xml != "")
            {
                Sys.println(repo + " reached");

                var list:List<Array<String>> = xmlR.readRepoPackages(xml);
                fh.addPackagesToList(list);
                pkgNumb += list.length;
            }
        }

        Sys.println(Std.string(pkgNumb) + " packages found");
    }
}
