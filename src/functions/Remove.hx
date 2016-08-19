package src.functions;

import src.FileHandler;
import src.XmlReader;

using StringTools;

class Remove
{
    public function new()
    {
        //
    }
    
    public function removePackages(_packages:Array<String>) : Void
    {
        var fh   :FileHandler = new FileHandler();
        var gmxR :XmlReader   = new XmlReader();

        // If a package is not installed stop the program
        for (_pkg in _packages)
        {
            if (!fh.packageIsInstalled(_pkg))
            {
                Sys.println(_pkg + " is not installed.");
                Sys.println("Unable to find " + _pkg + ".xml in the projects 'packages' directory");
                Sys.exit(0);
            }
        }

        // Safe removal method (just have to cleanup empty xml tags)
        for (_pkg in _packages)
        {
            var manifest   = fh.getInstalledManifest(_pkg);
            var projectGmx = fh.getGmx();

            var resourcesList       :List<String> = gmxR.getPackageResources(manifest);
            var datafilesParentNodes:List<String> = gmxR.getPackageDatafiles(manifest);
            var packageConstants    :List<String> = gmxR.getPackageConstants(manifest);

            // Remove the package xml from the project xml and returns a string for writing to the file
            projectGmx = gmxR.removePackageXml(projectGmx, resourcesList, datafilesParentNodes, packageConstants);

            // Remove any package files from the project directory (optional eventually)
            fh.removePackageFiles(resourcesList, datafilesParentNodes);

            // Cleanup the xml by spliting it into an array, removing any white space, and checking for empty tags
            // Then convert that array into one string, parse it to xml then convert the formatted xml back to a string...
            projectGmx = removeEmptyXml(projectGmx);
            
            fh.writeNewXml(projectGmx);
            fh.removeLocalManifest(_pkg);

            Sys.println(_pkg + " successfully removed");
        }

        // Non safe (non package elements could potentially be removed) removal method (cleaner xml)
        /*
        for (pkg in _packages)
        {
            var manifest   = fh.getInstalledManifest(pkg);
            var projectGmx = fh.getGmx();

            projectGmx = gmxR.removePackageNonSafe(projectGmx, pkg, gmxR.getPackageConstants(manifest));
        }
        */
    }

    public function removeEmptyXml(_xml:String) : String
    {
        var tags  = [ "<sound/>", "<sprite/>", "<background/>", "<path/>", "<font/>", "<script/>", "<object/>", "<room/>" ];
        var lines = _xml.split("\n");
        var list  = new List<String>();

        for (line in lines)
        {
            var currentLine = line.trim();
            var isEmpty     = false;

            for (tag in tags)
            {
                if (currentLine == tag)
                {
                    isEmpty = true;
                    break;
                }
            }

            if (!isEmpty)
            {
                list.add(line);
            }
        }

        var strBuf = new StringBuf();
        for (line in list)
        {
            strBuf.add(line + "\n");
        }

        return strBuf.toString();
    }
}
