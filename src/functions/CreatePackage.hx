package src.functions;

import src.FileHandler;
import src.XmlReader;
import src.WebDownloader;
import src.Const;

class CreatePackage
{
    private var pkgName        :String = "";
    private var pkgSite        :String = "";
    private var pkgLicense     :String = "";
    private var pkgVersion     :String = "";
    private var pkgDevelopers  :Array<String> = new Array<String>();
    private var pkgDependancies:Array<String> = new Array<String>();

    public function new()
    {
        getPkgDetails();
        createXmlManifest();
    }

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
        Sys.println("MIT, GNU AGPLv3, GNU GPLv3, GNU LGPLv2, Apache 2.0, BSD, New BSD, Simplified BSD, Unlicense");
        Sys.println("If you need help choosing a license visit http://choosealicense.com/ for an overview of several different types.");
        Sys.println("If you want your own license visit (wiki url page) for including your own license file.");
        Sys.println("This entry cannot be left empty.");
        Sys.print(">");
        pkgLicense = stdin.readLine();

        Sys.println("Enter the version of the package. MAJOR.MINOR.PATCH http://semver.org/");
        Sys.print(">");
        pkgVersion = stdin.readLine();

        Sys.println("If you have a website / git repo for the package or your self you can add it here, if not leave it blank.");
        Sys.print(">");
        pkgSite = stdin.readLine();

        Sys.println("List any dependancies needed for this package to work, you can add multiple dependancies by seperating them with commas.");
        Sys.print(">");
        var ln = stdin.readLine();
        pkgDependancies = ln.split(",");

        // TODO, Download license files if needed
    }

    public function createXmlManifest() : Void
    {
        var fh:FileHandler = new FileHandler();
        var xmlr:XmlReader = new XmlReader();

        Sys.println("Creating package archive, please wait...");

        var xmlStr          = fh.getGmx();
        var packageManifest = xmlr.createManifestXml(xmlr.generateAssetXml(xmlStr), pkgName, pkgVersion, pkgLicense, pkgSite, pkgDevelopers, pkgDependancies);

        var resourcesList       :List<String> = xmlr.getPackageResources(packageManifest.toString());
        var datafilesParentNodes:List<String> = xmlr.getPackageDatafiles(packageManifest.toString());

        fh.createPackageDirectory(pkgName, packageManifest, resourcesList, datafilesParentNodes);

        Sys.println(pkgName + ".gmp created in " + Const.getDataConfig()+"packages");
    }
}
