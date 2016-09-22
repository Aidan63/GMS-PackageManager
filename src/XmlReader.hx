package src;

import Xml;
import xmlTools.XmlPrinter;
import src.Const;

using Lambda;
using StringTools;

class XmlReader
{
    public function new()
    {
    }
    
    /// Recursivly loop over the datafile elements and set the number attribute to the root number
    public function datafilesSetNumber(_xml:Xml, _number:String) : Void
    {
        for (elt in _xml.elements())
        {
            if (elt.nodeName == "datafiles")
            {
                elt.set("number", _number);
                datafilesSetNumber(elt, _number);
            }
        }
    }

    /// Add elements from the manifest.xml to the xml structure of the .project.gmx file
    public function installPackageXml(projectXml:String, packageXml:String) : String
    {
        // List stores all of the xml sections to add to the gmx project
        var manifestParentXml:Map<String, Xml> = new Map<String, Xml>();

        // The first section in the manifest.xml is assets, loop over each one and add it to the list
        var manifestAssets:Xml = Xml.parse(packageXml).firstElement().firstElement();
        var projectAssets :Xml = Xml.parse(projectXml).firstElement();

        // Loop over the XML and add all sub elements of the manifest into a map based on the node name ("scripts", "objects", etc)
        for (item in manifestAssets.elements())
        {
            manifestParentXml.set(item.nodeName, item);
        }

        // Empty GMS Projects don"t include XML elements for all assets
        // Create XML elements for any missing resources
        projectAssets = createAllElements(projectAssets);

        // Loop over each of the sub elements in the gmx xml structure
        // if the node name matches one of GMS's resources and that resource exists in the map
        // add the xml in the map as a child of that xml element
        for (elt in projectAssets.elements())
        {
            var node = elt.nodeName;
            if (manifestParentXml.exists(node))
            {
                elt.addChild(manifestParentXml.get(node));
            }

            // Loop over any extensions and reasign the extension index to prevent any conflicts
            if (node == "NewExtensions")
            {
                var index = 0;
                for (child in elt.elements())
                {
                    child.set("index", Std.string(index));
                    index ++;
                }
            }

            // Set all datafile number attributes to the same which was assigned by GMS
            if (node == "datafiles")
            {
                var number = elt.get("number");
                datafilesSetNumber(elt, number);
            }

            // Set the constant value to the number of constants
            if (node == "constants")
            {
                var number = elt.count();
                elt.set("number", Std.string(number));
            }
        }

        // Uses the xmlTools printer to return a 2 space indented string of the xml (same which GMS produces, just to be consistant)
        return XmlPrinter.print(projectAssets, false, SPACES(2));
    }

    /// GMS does not add elements for all resource in empty projects
    /// Add any missing resource elements incase the package needs them
    public function createAllElements(assets:Xml) : Xml
    {
        // datafiles
        // fonts
        // scripts
        // objects
        // rooms
        // contstants number
        // audiogroups

        var existsDatafiles  = false;
        var existsFonts      = false;
        var existsObjects    = false;
        var existsRooms      = false;
        var existsConstants  = false;
        var existsAudiogroup = false;
        var existsScripts    = false;

        for (elt in assets.elements())
        {
            switch (elt.nodeName)
            {
                case "datafiles":
                    existsDatafiles = true;

                case "fonts":
                    existsFonts = true;

                case "scripts":
                    existsScripts = true;

                case "objects":
                    existsObjects = true;

                case "rooms":
                    existsRooms = true;

                case "constants":
                    existsConstants = true;

                case "audiogroups":
                    existsAudiogroup = true;
            }
        }

        // Create the non existsing elements
        if (existsDatafiles == false)
        {
            var xml = Xml.createElement("datafiles");
            xml.set("name", "datafiles");
            xml.set("number", "0");
            assets.addChild(xml);
        }
        if (existsFonts == false)
        {
            var xml = Xml.createElement("fonts");
            xml.set("name", "fonts");
            assets.addChild(xml);
        }
        if (existsScripts == false)
        {
            var xml = Xml.createElement("scripts");
            xml.set("name", "scripts");
            assets.addChild(xml);
        }
        if (existsObjects == false)
        {
            var xml = Xml.createElement("objects");
            xml.set("name", "objects");
            assets.addChild(xml);
        }
        if (existsRooms == false)
        {
            var xml = Xml.createElement("rooms");
            xml.set("name", "rooms");
            assets.addChild(xml);
        }
        if (existsConstants == false)
        {
            var xml = Xml.createElement("constants");
            xml.set("number", "0");
            assets.addChild(xml);
        }
        if (existsAudiogroup == false)
        {
            var xml = Xml.createElement("audiogroups");
            xml.set("name", "audiogroups");
            assets.addChild(xml);
        }

        return assets;
    }

    /// Returns a list with the location of all the resources in the package (except for datafiles)
    public function getPackageResources(_pkgManifest:String) : List<String>
    {
        var assetsList = new List<String>();
        var assetsXml  = Xml.parse(_pkgManifest).firstElement().firstElement();

        // Handle special case resources and remove them to make the normal ones easier to parse
        for (elt in assetsXml.elements())
        {
            // Remove "datafiles" and "constants" from the xml to make it easier to parse
            if (elt.nodeName == "datafiles" || elt.nodeName == "constants")
            {
                assetsXml.removeChild(elt);
            }

            // Add any extension elements to the list then remove them from the xml
            if (elt.nodeName == "NewExtensions")
            {
                for (_child in elt.elements())
                {
                    assetsList.add(_child.firstChild().nodeValue);
                }
                assetsXml.removeChild(elt);
            }
        }

        // Get a list of all the standard resources which can be removed from the project xml and return it
        assetsList = addElementAssets(assetsXml, assetsList);

        return assetsList;
    }

    /// Returns a list of all the parent node names for datafiles
    public function getPackageDatafiles(_pkgManifest:String) : List<String>
    {
        var parentNodes = new List<String>();
        var assetsXml   = Xml.parse(_pkgManifest).firstElement().firstElement();

        function datafileSearch(_xml:Xml) : Void
        {
            for (elt in _xml.elements())
            {
                if (elt.nodeName == "datafile" && !elt.exists("name"))
                {
                    parentNodes.add(elt.firstElement().firstChild().nodeValue);
                }
                else
                {
                    datafileSearch(elt);
                }
            }
        }

        // Adds the 'name' attribute for all first level xml elements from the package manifest
        for (elt in assetsXml.elements())
        {
            if (elt.nodeName == "datafiles")
            {
                datafileSearch(elt);
            }
        }

        return parentNodes;
    }

    /// Returns a list of all the constant name attributes in the package manifest
    public function getPackageConstants(_pkgManifest:String) : List<String>
    {
        var assetsXml = Xml.parse(_pkgManifest).firstElement();
        var constList = new List<String>();

        for (elt in assetsXml.elements())
        {
            if (elt.nodeName == "constants")
            {
                for (child in elt.elements())
                {
                    if (child.exists("name"))
                    {
                        constList.add(child.get("name"));
                    }
                }
            }
        }

        return constList;
    }

    /// Recusivly loop over the xml structure adding any child nodeValues into a list then returning that list
    /// If the current node is an element call the function again passing that element through
    public function addElementAssets(_xml:Xml, _list:List<String>) : List<String>
    {
        for (elt in _xml.elements())
        {
            if (elt.exists("name"))
            {
                _list = addElementAssets(elt, _list);
            }
            else
            {
                for (_child in elt)
                {
                    _list.add(_child.nodeValue);
                }
            }
        }

        return _list;
    }

    /// Removes the child nodes found in the list from the project xml 
    public function removePackageXml(_gmx:String, _resourceList:List<String>, _datafilesList:List<String>, _constantsList:List<String>) : String
    {
        var gmx = Xml.parse(_gmx).firstElement();

        // Safe removal for standard resources
        // Loops over each child node checking against the list and removing it if a match is found
        for (elt in gmx.elements())
        {
            // Searching for standard resources
            if (elt.nodeName != "datafiles" && elt.nodeName != "NewExtensions" && elt.nodeName != "constants")
            {
                searchXmlTree(elt, _resourceList);
            }

            // Remove any matching extension elements
            if (elt.nodeName == "NewExtensions")
            {
                for (child in elt.elements())
                {
                    for (item in _resourceList)
                    {
                        if (item == child.firstChild().nodeValue)
                        {
                            elt.removeChild(child);
                        }
                    }
                }
            }

            // Remove any constants from the project xml
            if (elt.nodeName == "constants")
            {
                for (child in elt.elements())
                {
                    for (constName in _constantsList)
                    {
                        if (constName == child.get("name"))
                        {
                            elt.removeChild(child);
                        }
                    }
                }
            }

            // Remove the root element of any datafiles
            // TODO : Look for the root name in sub folder instead of just the top level
            if (elt.nodeName == "datafiles")
            {
                for (child in elt.elements())
                {
                    for (item in _datafilesList)
                    {
                        if (child.get("name") == item)
                        {
                            elt.removeChild(child);
                        }
                    }
                }
            }
        }

        // Uses the xmlTools printer to return a 2 space indented string of the xml (same which GMS produces, just to be consistant)
        return XmlPrinter.print(gmx, false, SPACES(2));
    }

    /// Recursivly search through the provided xml for any matching elements from the list
    /// Matching xml is then removed
    public function searchXmlTree(_xml:Xml, _resourceList:List<String>) : Void
    {
        for (elt in _xml.elements())
        {
            // Having the attribute 'name' means it is a folder not a end element
            // So we call the function again and search that sub folder
            if (elt.exists("name"))
            {
                searchXmlTree(elt, _resourceList);
            }
            else
            {
                for (child in elt)
                {
                    // Search for matching items in the list
                    for (item in _resourceList)
                    {
                        if (item == child.nodeValue)
                        {
                            elt.removeChild(elt.firstChild());
                        }
                    }
                }
            }
        }
    }

    /// Returns a map with data about the repo which is gathered from the xml file
    public function readRepoXml(_repoXml:String) : Map<String, String>
    {
        var xml  = Xml.parse(_repoXml);
        var data = new Map<String, String>();

        for (elt in xml.elements())
        {
            if (elt.nodeName == "repository")
            {
                for (child in elt.elements())
                {
                    data.set(child.nodeName, child.firstChild().nodeValue);
                }
            }
        }
        
        return data;
    }

    /// Returns a list of every package name and url from a repo xml
    public function readRepoPackages(_repoXml:String) : List<Array<String>>
    {
        var xml = Xml.parse(_repoXml);
        var data = new List<Array<String>>();

        for (elt in xml.elements())
        {
            if (elt.nodeName == "packages")
            {
                for (pkg in elt.elements())
                {
                    data.add([pkg.get("name"), pkg.firstChild().nodeValue]);
                }
            }
        }

        return data;
    }

    /// Goes over a gmx xml file and gets any resource xml trees for the manifest
    /// For each resource if there is a folder with the name of the project then that is the only xml tree that is copied over to the 
    public function generateAssetXml(_projectXml:String) : Xml
    {
        var pathSplit = Const.CURRENTDIR.split("/");
        var pathSplit = pathSplit[pathSplit.length - 2].split(".");
        var projectName = pathSplit[0].toLowerCase();

        var assetsXml = Xml.createElement("assets");

        // Loop over every resource element
        var gmx = Xml.parse(_projectXml).firstElement();
        for (elt in gmx.elements())
        {
            // Ignore the config, help, tutorialstate and any empty elements
            if (elt.nodeName != "Configs" && elt.nodeName != "help" && elt.nodeName != "TutorialState" && elt.count() != 0)
            {
                // Handle extensions and constats seperately from standard resources due to a difference in xml structure
                if (elt.nodeName == "NewExtensions")
                {
                    // Loop over each extension element and look for one where the extension matches the project name
                    // If one is found add it to the map
                    // If not do nothing, eventually users will be able to specify a ext name or be able to add all
                    var _elt = Xml.createElement("NewExtensions");
                    for (ext in elt.elements())
                    {
                        var split   = ext.firstChild().nodeValue.split('\\');
                        var extName = split[1];
                        if (extName.toLowerCase() == projectName)
                        {
                            _elt.addChild(ext);
                            assetsXml.addChild(_elt);
                            break;
                        }
                    }
                }
                else if (elt.nodeName == "constants")
                {
                    // Add any constants which are not the two default ones GMS creates
                    /*
                    var _elt = Xml.createElement("constants");
                    for (const in elt.elements())
                    {
                        if (const.get("name") != "GM_build_date" && const.get("name") != "GM_version")
                        {
                            _elt.addChild(const);
                        }
                    }

                    // Only add constants to the map if any were found
                    if (_elt.count() > 0)
                    {
                        assetsXml.addChild(_elt);
                    }
                    */
                }
                else
                {
                    // Loop over each of the inner elements looking for one with a name which matches the project name
                    // If this is found use it for that resouces package files
                    var nameMatchFound = false;
                    for (innerElt in elt.elements())
                    {
                        if (innerElt.exists("name") && innerElt.get("name").toLowerCase() == projectName)
                        {
                            assetsXml.addChild(innerElt);
                            nameMatchFound = true;
                            break;
                        }
                    }

                    // If a name matching element is not found take all the resources from the parent xml and add it to a new element for the package
                    if (!nameMatchFound)
                    {
                        var _elt = Xml.createElement(elt.nodeName);
                        _elt.set("name", projectName);
                        for (innerElt in elt.elements())
                        {
                            _elt.addChild(innerElt);
                        }

                        assetsXml.addChild(_elt);
                    }
                }
            }
        }

        return assetsXml;
    }

    public function createManifestXml(_pkgAssets:Xml, _pkgName:String, _pkgVersion:String, _pkgLicense:String, _pkgSite:String, _pkgDevelopers:Array<String>, _pkgDependencies:Array<String>) : Xml
    {
        var xmlRoot = Xml.createElement("root");

        var xmlMetadata = Xml.createElement("metadata");
        
        var xmlPkgName    = Xml.createElement("name");
        var xmlPkgVersion = Xml.createElement("version");
        var xmlPkgLicense = Xml.createElement("license");
        var xmlPkgSite    = Xml.createElement("site");
        var xmlPkgDevs    = Xml.createElement("developers");
        var xmlPkgDeps    = Xml.createElement("dependencies");

        xmlPkgName   .addChild(Xml.createPCData(_pkgName));
        xmlPkgVersion.addChild(Xml.createPCData(_pkgVersion));
        xmlPkgLicense.addChild(Xml.createPCData(_pkgLicense));
        xmlPkgSite   .addChild(Xml.createPCData(_pkgSite));

        // Loop through the developers and add them to the related root xml element
        if (_pkgDevelopers.length > 0)
        {
            for (dev in _pkgDevelopers)
            {
                var _xmlDev = Xml.createElement("developer");
                _xmlDev.addChild(Xml.createPCData(dev.trim()));
                xmlPkgDevs.addChild(_xmlDev);
            }
        }

        // Loop through the dependencies and add them to the related root xml element
        if (_pkgDevelopers.length > 0)
        {
            for (dep in _pkgDependencies)
            {
                var _xmlDep = Xml.createElement("dependency");
                _xmlDep.addChild(Xml.createPCData(dep.trim()));
                xmlPkgDeps.addChild(_xmlDep);
            }
        }

        // Add all metadata sub elements to the base metadata tag
        xmlMetadata.addChild(xmlPkgName);
        xmlMetadata.addChild(xmlPkgVersion);
        xmlMetadata.addChild(xmlPkgLicense);
        xmlMetadata.addChild(xmlPkgSite);
        xmlMetadata.addChild(xmlPkgDevs);
        xmlMetadata.addChild(xmlPkgDeps);

        xmlRoot.addChild(_pkgAssets);
        xmlRoot.addChild(xmlMetadata);

        return xmlRoot;
    }
}
