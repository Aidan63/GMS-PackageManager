package src.functions;

import src.WebDownloader;
import src.FileHandler;
import src.XmlReader;
import src.Const;

class Install
{   
    public function new(_args:Array<String>)
    {
        // If there is an entry in the array then attempt to install a package of that name
        // Else print the help text
        if (_args.length > 0)
        {
            installPackages(_args);
        }
        else
        {
            printHelp();
        }
    }

    /// Attempt to install the packages passed to it in the array
    public function installPackages(_packages:Array<String>) : Void
    {
        var fh   :FileHandler   = new FileHandler  ();
        var webDl:WebDownloader = new WebDownloader();
        var gmxR :XmlReader     = new XmlReader    ();

        var pkgsToInstall = new List<String>();

        // Create a list of packages which are not installed and available
        for (pkg in _packages)
        {
            if (!fh.packageIsInstalled(pkg))
            {
                if (!fh.packageAvailable(pkg))
                {
                    Sys.println("Failed to find package " + pkg + " in packages.list");
                    Sys.exit(2);
                }
                else
                {
                    pkgsToInstall.add(pkg);
                    Sys.println(pkg + " package found");
                }
            }
            else
            {
                Sys.println(pkg + " already installed, skipping.");
            }
        }
        
        // If there are packages to install from the list
        if (!pkgsToInstall.isEmpty())
        {
            // Attempt to download all of the packages in the list
            for (pkg in pkgsToInstall)
            {
                if (!fh.packageIsDownloaded(pkg))
                {
                    Sys.println(pkg + " not yet downloaded, downloading...");

                    var url = fh.findURL(pkg);
                    if (url != null)
                    {
                        webDl.downloadPackages(url, pkg);
                    }
                    else
                    {
                        Sys.println("Unable to find a url for package " + pkg + " in packages.list");
                        Sys.exit(3);
                    }
                }
                else
                {
                    Sys.println("Package already downloaded");
                }
            }

            // Attempt to install all of the packages which were just downloaded
            for (pkg in pkgsToInstall)
            {
                // Extract the package to the tmp folder and find the gmx file in the current directory
                fh.extractPackage(pkg);
                var projectGmx = fh.getGmx();
                var packageXml = fh.getPackageManifest(pkg);

                // Merge the manfiest file into the project gmx and then move the asset files into the appropriate folders 
                var newProjectGmx = gmxR.installPackageXml(projectGmx, packageXml);
                fh.moveAssetFiles(pkg);
                fh.moveManifestXml(pkg);

                // Backup the current .project.gmx and write the new xml to a file
                fh.writeNewXml(newProjectGmx);
                fh.removeDirRecursive(Const.getDataConfig() + "tmp");

                Sys.println(pkg + " successfully installed");
            }
        }
    }

    public function printHelp() : Void
    {
        Sys.println("You must specify a package to install when using the 'install' command.");
        Sys.println("");
        Sys.println("   Usage: gmr install $package");
        Sys.println("   Usage: gmr install $package1 $package2");
    }
}
