# GameMaker:Studio Package Manager
A cross platform command line tool for managing GameMaker:Studio assets and extensions.
User created packages containing scripts, sprites, extension, and any other GMS resource can be downloaded and added into an existing project via one line in a terminal.

Right now the program supports...
- Installing and removing packages
- Adding and removing user hosted repositories
- Auto creating packages from a GMS project directory

In the future the program will support...
- Upgrading installed packages
- Installing, upgrading, or downgrading to a specific version of a package
- Pinning installed packages to a specific version so they can not be changed
- Command line options to add extra features to existing commands

Possible features if they are considered useful enough and EULA permitting...
- Auto downloading and adding scripts from gmlscripts.com
- Installing free assets from the GMS marketplace through the install command

## **Install**
### **Pre-Compiled Binaries**
Pre-compiled binaries are not yet provided.

### **Compiling from Source**

GMS-PM is built with Haxe 3.3.0 and depends on the HxSSL and XmlTools libraries which can be installed through haxelib.

```sh
haxelib install hxssl
haxelib install xmlTools
```

The build.hxml file is setup up to provide neko .n executables but hxcpp works fine and will be used for pre-compiled binaries.

## **Usage**

For a complete list of all commands and optional flags visit the github wiki page { link to wiki page }

### **End User**

#### Installing and Removing Packages

```sh
# List all available packages
gmr list

# Install a package
# Must be ran from within a GMS project directory
gmr install $package

# Remove a package
# Must be ran from within a GMS project directory
gmr remove $package
```

### **Package Creators**

TODO

### **Repository Hosters**

TODO
