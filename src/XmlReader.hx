package src;

import Xml;
import xmlTools.XmlPrinter;

using Lambda;

class XmlReader
{
    private var xmlDoc:String = "";

    public function new()
    {
        //
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
        var manifestAssets:Xml = Xml.parse(packageXml).firstElement();
        var projectAssets :Xml = Xml.parse(projectXml).firstElement();

        // Loop over the XML and add all sub elements of the manifest into a map based on the node name ("scripts", "objects", etc)
        for (item in manifestAssets.elements())
        {
            for (elt in item.elements())
            {
                manifestParentXml.set(item.nodeName, elt);
            }
        }

        // Empty GMS Projects don"t include XML elements for all assets
        // Create XML elements for any missing resources
        projectAssets = createAllElements(projectAssets);

        // Loop over each of the sub elements in the gmx xml structure
        // if the node name matches one of GMS" resources and that resource exists in the map
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
            var _xml = Xml.createElement("datafiles");
            _xml.set("name", "datafiles");
            _xml.set("number", "0");
            assets.addChild(_xml);
        }
        if (existsFonts == false)
        {
            var _xml = Xml.createElement("fonts");
            _xml.set("name", "fonts");
            assets.addChild(_xml);
        }
        if (existsScripts == false)
        {
            var _xml = Xml.createElement("scripts");
            _xml.set("name", "scripts");
            assets.addChild(_xml);
        }
        if (existsObjects == false)
        {
            var _xml = Xml.createElement("objects");
            _xml.set("name", "objects");
            assets.addChild(_xml);
        }
        if (existsRooms == false)
        {
            var _xml = Xml.createElement("rooms");
            _xml.set("name", "rooms");
            assets.addChild(_xml);
        }
        if (existsConstants == false)
        {
            var _xml = Xml.createElement("constants");
            _xml.set("number", "0");
            assets.addChild(_xml);
        }
        if (existsAudiogroup == false)
        {
            var _xml = Xml.createElement("audiogroups");
            _xml.set("name", "audiogroups");
            assets.addChild(_xml);
        }

        return assets;
    }

    /// Returns a list with the location of all the resources in the package (except for datafiles)
    public function getPackageResources(_pkgManifest:String) : List<String>
    {
        var assetsList = new List<String>();
        var assetsXml  = Xml.parse(_pkgManifest).firstElement();

        // Handle special case resources and remove them to make the normal ones easier to parse
        for (_elt in assetsXml.elements())
        {
            // Remove "datafiles" and "constants" from the xml to make it easier to parse
            if (_elt.nodeName == "datafiles" || _elt.nodeName == "constants")
            {
                assetsXml.removeChild(_elt);
            }

            // Add any extension elements to the list then remove them from the xml
            if (_elt.nodeName == "NewExtensions")
            {
                for (_child in _elt.elements())
                {
                    assetsList.add(_child.firstChild().nodeValue);
                }
                assetsXml.removeChild(_elt);
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
        var assetsXml   = Xml.parse(_pkgManifest).firstElement();

        for (_elt in assetsXml.elements())
        {
            if (_elt.get("name") == "datafiles")
            {
                for (_nodes in _elt.elements())
                {
                    if (_nodes.exists("name"))
                    {
                        parentNodes.add(_nodes.get("name"));
                    }
                }
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
        for (_elt in _xml.elements())
        {
            if (_elt.exists("name"))
            {
                _list = addElementAssets(_elt, _list);
            }
            else
            {
                for (_child in _elt)
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
        for (_elt in gmx.elements())
        {
            // Searching for standard resources
            if (_elt.nodeName != "datafiles" && _elt.nodeName != "NewExtensions" && _elt.nodeName != "constants")
            {
                searchXmlTree(_elt, _resourceList);
            }

            // Remove any matching extension elements
            if (_elt.nodeName == "NewExtensions")
            {
                for (_child in _elt.elements())
                {
                    for (_item in _resourceList)
                    {
                        if (_item == _child.firstChild().nodeValue)
                        {
                            _elt.removeChild(_child);
                        }
                    }
                }
            }

            // Remove any constants from the project xml
            if (_elt.nodeName == "constants")
            {
                for (child in _elt.elements())
                {
                    for (constName in _constantsList)
                    {
                        if (constName == child.get("name"))
                        {
                            _elt.removeChild(child);
                        }
                    }
                }
            }

            // Remove the root element of any datafiles 
            // This method is 'non safe' as non package resources could be deleted removed from the xml
            // The physical files remain untouched however
            if (_elt.nodeName == "datafiles")
            {
                for (_child in _elt.elements())
                {
                    for (_item in _datafilesList)
                    {
                        if (_child.get("name") == _item)
                        {
                            _elt.removeChild(_child);
                        }
                    }
                }
            }
        }

        // Uses the xmlTools printer to return a 2 space indented string of the xml (same which GMS produces, just to be consistant)
        return XmlPrinter.print(gmx, false, SPACES(2));
    }

    ///
    public function searchXmlTree(_xml:Xml, _list:List<String>) : Void
    {
        for (_elt in _xml.elements())
        {
            if (_elt.exists("name"))
            {
                searchXmlTree(_elt, _list);
            }
            else
            {
                for (_child in _elt)
                {
                    // Search for matching items in the list
                    for (_item in _list)
                    {
                        if (_item == _child.nodeValue)
                        {
                            _elt.removeChild(_elt.firstChild());
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

    // Returns a list of every package name and url from a repo xml
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
}
