package src.functions;

import src.FileHandler;
import src.XmlReader;
import src.WebDownloader;
import src.Const;

using Lambda;
using StringTools;

class CreatePackage
{
    private var pkgName        :String = "";
    private var pkgSite        :String = "";
    private var pkgLicense     :String = "";
    private var pkgVersion     :String = "";
    private var pkgDevelopers  :Array<String> = new Array<String>();
    private var pkgDependancies:Array<String> = new Array<String>();

    public function new(_options:Map<String, String>, _args:Array<String>)
    {
        getPkgDetails();
        createXmlManifest();
    }

    /**
     * Asks the user to input the information required to create the package, some entries are split into arrays by commas.
     */
    public function getPkgDetails() : Void
    {
        // Read the user input for the package details
        var stdin = Sys.stdin();

        Sys.println("Package Creator");
        Sys.println("---------------");
        Sys.println("Enter the name of the package. If you leave this blank the name of the GMS project will be used.");
        Sys.print(">");
        pkgName = stdin.readLine();

        Sys.println("Enter the names of the developers who worked on this package. Multiple names can be entered by seperating them with commas.");
        Sys.print(">");
        var ln = stdin.readLine();
        pkgDevelopers = ln.split(",");

        Sys.println("Enter the license for the package, if you choose one of the following licenses the file will be automatically downloaded, details filled in, and added to the project.");
        Sys.println("MIT, GNU AGPLv3, GNU GPLv3, GNU LGPLv3, Apache 2.0, BSD, New BSD, Simplified BSD, Unlicense");
        Sys.println("If you need help choosing a license visit http://choosealicense.com/");
        Sys.println("If you want your own license visit (wiki url page) for including your own license file.");
        Sys.print(">");
        pkgLicense = stdin.readLine();

        Sys.println("Enter the version of the package.");
        Sys.print(">");
        pkgVersion = stdin.readLine();

        Sys.println("If you have a website / git repo for the package or your self you can add it here, if not leave it blank.");
        Sys.print(">");
        pkgSite = stdin.readLine();

        Sys.println("List any dependancies needed for this package to work, you can add multiple dependancies by seperating them with commas.");
        Sys.print(">");
        var ln = stdin.readLine();
        pkgDependancies = ln.split(",");
    }

    /**
     * Starts the packaging process, calls the appropriate functions to create a asset archive from a GMS directory
     */
    public function createXmlManifest() : Void
    {
        var fh:FileHandler = new FileHandler();
        var xmlr:XmlReader = new XmlReader();

        Sys.println("Creating package archive, please wait...");

        var xmlStr          = fh.getGmx();
        var packageManifest = xmlr.createManifestXml(xmlr.generateAssetXml(xmlStr), pkgName, pkgVersion, pkgLicense, pkgSite, pkgDevelopers, pkgDependancies);

        var resourcesList       :List<String> = xmlr.getPackageResources(packageManifest.toString());
        var datafilesParentNodes:List<String> = xmlr.getPackageDatafiles(packageManifest.toString());

        fh.createPackageDirectory(pkgName, packageManifest, resourcesList, datafilesParentNodes, getLicenseFile(pkgLicense));

        Sys.println(pkgName + ".gmp created in " + Const.getDataConfig()+"/packages");
    }

    /**
     * Attemps to download a license file if it's a default license and add it to the pacakge's 'package' directory
     *
     * @param   _license    The name of the license
     * @return              String containing the license with any required information substituted in
     */
    private function getLicenseFile(_license:String) : String
    {
        var webDL    = new WebDownloader();
        var licenses = ["MIT", "APACHE20", "GNUAGPLV3", "GNUGPLV3", "GNULGPLV3", "BSD", "NEWBSD", "SIMPLIFIEDBSD", "UNLICENSE"];

        // Remove any spaces or dots from the name to check and make it easier to download from a URL
        if (licenses.has(_license.toUpperCase().replace(" ", "").replace(".", "")))
        {
            var licenseUrl = "https://raw.githubusercontent.com/Aidan63/GMS-PackageManager/createPackage/Licenses/" + _license.toUpperCase().replace(" ", "").replace(".", "") + ".txt";
            var content    = webDL.downloadLicense(licenseUrl);

            // Replace the year and holder tags with the current year and all of the developers if the license requires it
            content = content.replace("[year]", Std.string(Date.now().getFullYear()));
            content = content.replace("[copyright holder]", Std.string(pkgDevelopers).replace("[", "").replace("]", ""));

            return content;
        }

        return "";
    }
}
