package src.functions;

import haxe.io.Path;
import src.WebDownloader;
import src.FileHandler;
import src.XmlReader;
import src.Const;

class Install
{
    private var xmlFolder       : String = "";
    private var projectPath     : String = "";
    private var downloadOnly    : Bool   = false;
    private var localInstall    : Bool   = false;
    private var fromMarketplace : Bool   = false;
    private var fromGmlScripts  : Bool   = false;
    
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

    /**
     * Checks if the packages provided are already downloaded, downloads them if need be and then installs them.
     *
     * @param   _packages   Array containing all of the packages to try and install.
     */
    public function installPackages(_packages:Array<String>) : Void
    {
        var fh    = new FileHandler  ();
        var webDl = new WebDownloader();
        var gmxR  = new XmlReader    ();

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
                var projectGmx:String = fh.getGmx();
                var packageXml:String = fh.getPackageManifest(pkg);

                // Merge the manfiest file into the project gmx and then move the asset files into the appropriate folders 
                var newProjectGmx:String = gmxR.installPackageXml(projectGmx, packageXml);
                fh.moveAssetFiles(pkg);
                fh.moveManifestXml(pkg);

                // Backup the current .project.gmx and write the new xml to a file
                fh.writeNewXml(newProjectGmx);
                fh.removeDirRecursive(Path.join([Const.getDataConfig() + "tmp"]));

                Sys.println(pkg + " successfully installed");
            }
        }
    }

    /**
     * Prints a help message for the install command.
     */
    public function printHelp() : Void
    {
        Sys.println("You must specify at least one package to install when using the 'install' command.");
        Sys.println("");
        Sys.println("   Usage: gmr install $package");
        Sys.println("   Usage: gmr install $package1 $package2");
    }
}
