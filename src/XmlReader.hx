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

    /**
     * Adds elements from the manifest assets parent into the .project.gmx assets xml.
     *
     * @param   _projectXml     The string containing the XML of the project gmx.
     * @param   _packageXml     The string containing the manifest XML of the package.
     *
     * @return      String containing the xml of the project .gmx with the package xml inserted.
     */
    public function installPackageXml(_projectXml:String, _packageXml:String) : String
    {
        // List stores all of the xml sections to add to the gmx project
        var manifestParentXml = new Map<String, Xml>();

        // The first section in the manifest.xml is assets, loop over each one and add it to the list
        var manifestAssets:Xml = Xml.parse(_packageXml).firstElement().firstElement();
        var projectAssets :Xml = Xml.parse(_projectXml).firstElement();

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
            var node:String = elt.nodeName;
            // if a matching entry is found in the map add it to the project xml
            if (manifestParentXml.exists(node))
            {
                if (node == "NewExtensions" || node == "constants")
                {
                    var extXml = manifestParentXml.get(node);
                    for (ext in extXml.elements())
                    {
                        elt.addChild(ext);
                    }
                }
                else
                {
                    elt.addChild(manifestParentXml.get(node));
                }
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
    
    /**
     * GMS does not add elements for every resource by default, correct that by adding any missing resource elements to the .gmx xml.
     *
     * @param   _assets     The .gmx xml to check for any missing resource elements.
     * @return              Project xml structure with all resource elements.
     */
    public function createAllElements(_assets:Xml) : Xml
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

        for (elt in _assets.elements())
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
            _assets.addChild(xml);
        }
        if (existsFonts == false)
        {
            var xml = Xml.createElement("fonts");
            xml.set("name", "fonts");
            _assets.addChild(xml);
        }
        if (existsScripts == false)
        {
            var xml = Xml.createElement("scripts");
            xml.set("name", "scripts");
            _assets.addChild(xml);
        }
        if (existsObjects == false)
        {
            var xml = Xml.createElement("objects");
            xml.set("name", "objects");
            _assets.addChild(xml);
        }
        if (existsRooms == false)
        {
            var xml = Xml.createElement("rooms");
            xml.set("name", "rooms");
            _assets.addChild(xml);
        }
        if (existsConstants == false)
        {
            var xml = Xml.createElement("constants");
            xml.set("number", "0");
            _assets.addChild(xml);
        }
        if (existsAudiogroup == false)
        {
            var xml = Xml.createElement("audiogroups");
            xml.set("name", "audiogroups");
            _assets.addChild(xml);
        }

        return _assets;
    }

    /**
     * Returns a list with the location of all the standard resources in the package.
     * Datafiles and constants are not included.
     *
     * @param   _pkgManifest    String containing the XML manifest of the package.
     * @return                  
     */
    public function getPackageResources(_pkgManifest:String) : List<String>
    {
        var assetsList:List<String> = new List<String>();
        var assetsXml :Xml = Xml.parse(_pkgManifest).firstElement().firstElement();

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
    
    /**
     * Returns a list of all the datafile parent nodes.
     *
     * @param   _pkgManifest    String containing the Xml to search for the datafiles.
     * @return                  Returns a list containing the name of the datafile parent node.
     */
    public function getPackageDatafiles(_pkgManifest:String) : List<String>
    {
        var parentNodes = new List<String>();
        var assetsXml   = Xml.parse(_pkgManifest).firstElement().firstElement();

        /**
         * Recursivly search the Xml structure for a datafile parent node.
         *
         * @param   _xml    The Xml strucute to search.
         */
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

    /**
     * Returns a list of all the constant name attributes in the package manifest.
     *
     * @param   _pkgManifest    The string of the Xml to get constants from
     * @return                  List of the constants names.
     */
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

    /**
     * Recusivly loop over the xml structure adding any child nodeValues into a list then returning that list.
     * If the current node is an element call the function again passing that element through.
     *
     * @param   _xml    The xml structure to loop over.
     * @return          List of every standard asset in the package.
     */
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
    /**
     * Removes nodes from the project Xml which are also found in the lists of resources to be removed.
     *
     * @param   _gmx            The string of the project gmx Xml.
     * @param   _resourceList   The list containing all of the standard resources to be removed.
     * @param   _datafilesList  The list containing all of the datafiles to be removed.
     * @param   _constantsList  The list containing all of the constants to be removed.
     *
     * @return          Formatted Xml string of the project gmx file with the resources removed.
     */
    public function removePackageXml(_gmx:String, _resourceList:List<String>, _datafilesList:List<String>, _constantsList:List<String>) : String
    {
        var gmx:Xml = Xml.parse(_gmx).firstElement();

        /**
         * Recursivly search through the provided xml removing any matching elements from the list.
         *
         * @param   _xml            The Xml structure to search through.
         * @param   _resourceList   The list of resources to look for.
         */
        function searchXmlTree(_xml:Xml, _resourceList:List<String>) : Void
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

    /**
     * Returns a map of data about the repository from the repo manifest XML.
     * Contains the repo name, owner, and email address.
     *
     * @param   _repoXml    The XML String of the repo manifest.
     * @return              Map containing data about the repository.
     */
    public function readRepoXml(_repoXml:String) : Map<String, String>
    {
        var xml:Xml = Xml.parse(_repoXml);
        var data    = new Map<String, String>();

        for (elt in xml.elements())
        {
            if (elt.nodeName == "repository")
            {
                // Sub nodes contain info such as the repo name, owner, contact email
                for (child in elt.elements())
                {
                    data.set(child.nodeName, child.firstChild().nodeValue);
                }
            }
        }
        
        return data;
    }

    /**
     * Parses the manifest XML and for each package element add information about it into a list of arrays. 
     *
     * @param   _repoXml    The string representation of the manifest file.
     * @return              Each array within the list represents one package. Position 0 is the package name and position 1 is the URL.
     */
    public function readRepoPackages(_repoXml:String) : List<Array<String>>
    {
        var xml:Xml = Xml.parse(_repoXml);
        var data    = new List<Array<String>>();

        // Search for the 'packages' element which contains all of the package sub elements
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

    /**
     * Creates a package manifest xml structure from a GMS dir xml structure and the package data collected from the user
     *
     * @param   _pkgAssets          The XML structure containing all of the GMS resources
     * @param   _pkgName            Holds the package name
     * @param   _pkgVersion         Holds the package version
     * @param   _pkgLicense         Holds the package license
     * @param   _pkgSite            Holds the package website url
     * @param   _pkgDevelopers      Array containing the developers of the package
     * @param   _pkgDependencies    Array containing the dependencies of the package
     *
     * @return                      Xml structure of the completed package manifest
     */
    public function createManifestXml(_pkgAssets:Xml, _pkgName:String, _pkgVersion:String, _pkgLicense:String, _pkgSite:String, _pkgDevelopers:Array<String>, _pkgDependencies:Array<String>) : Xml
    {
        // Creates the room element and the metadata elements to store the package info
        var xmlRoot = Xml.createElement("root");

        var xmlMetadata = Xml.createElement("metadata");
        
        var xmlPkgName    = Xml.createElement("name");
        var xmlPkgVersion = Xml.createElement("version");
        var xmlPkgLicense = Xml.createElement("license");
        var xmlPkgSite    = Xml.createElement("site");
        var xmlPkgDevs    = Xml.createElement("developers");
        var xmlPkgDeps    = Xml.createElement("dependencies");

        // PCData holds the node value for the metadata elements
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
