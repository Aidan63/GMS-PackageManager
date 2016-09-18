package src.functions;

import src.FileHandler;
import src.XmlReader;

using StringTools;

class Remove
{
    public function new()
    {
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
                Sys.exit(4);
            }
        }

        // Safe removal method (just have to cleanup empty xml tags)
        for (_pkg in _packages)
        {
            var manifest   = fh.getInstalledManifest(_pkg);
            var projectGmx = fh.getGmx();

            // returns lists containing all the resouces to be removed from the project
            var resourcesList       :List<String> = gmxR.getPackageResources(manifest);
            var datafilesParentNodes:List<String> = gmxR.getPackageDatafiles(manifest);
            var packageConstants    :List<String> = gmxR.getPackageConstants(manifest);

            // Remove the package xml from the project xml and returns a string for writing to a file
            projectGmx = gmxR.removePackageXml(projectGmx, resourcesList, datafilesParentNodes, packageConstants);

            // Remove any package files from the project directory (optional eventually)
            fh.removePackageFiles(resourcesList, datafilesParentNodes);

            // Cleanup the xml by spliting it into an array, removing any white space, and checking and removing empty tags
            projectGmx = removeEmptyXml(projectGmx);
            
            // Write the xml to the .project.gmx then remove the package manifest from the project 'packages' folder
            fh.writeNewXml(projectGmx);
            fh.removeLocalManifest(_pkg);

            Sys.println(_pkg + " successfully removed");
        }
    }

    /// Split the xml into an array and loop over it checking for empty tags of all the resource types
    public function removeEmptyXml(_xml:String) : String
    {
        var tags  = [ "<sound/>", "<sprite/>", "<background/>", "<path/>", "<font/>", "<script/>", "<object/>", "<room/>" ];
        var lines = _xml.split("\n");
        var list  = new List<String>();

        // Loop over the array and trim any whitespace before checking against the tags array
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

        // Use a string buffer to build the new xml structure and return it as a string
        var strBuf = new StringBuf();
        for (line in list)
        {
            strBuf.add(line + "\n");
        }

        return strBuf.toString();
    }
}
