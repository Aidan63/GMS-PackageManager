# GameMaker:Studio Package Manager
A cross platform command line tool for managing GameMaker:Studio assets and extensions.
User created packages containing scripts, sprites, extension, and any other GMS resource can be downloaded and added into an existing project via one line in a terminal.

## **Install**
### **Pre-Compilied Binaries**
Go to the releases section of the github repository and download the zip file for your operating system.
In the zip is a single executable file which can be ran from the command line.
Adding the file location to your PATH environment variable allows it to be called from anywhere.

To test that the program works type

```sh
gmr help
```

If everything is setup correctly you should see a list of commands which can be used.

### **Compiling from Source**

GMS-PM is built with Haxe 3.3.0 and depends on the HxSSL and XmlTools libraries which can be installed through haxelib.

```sh
haxelib install hxssl
haxelib install xmlTools
```

The pre-compiled binaries are built using hxcpp but by default the build.hxml is set to produce a neko .n file for faster compile times.

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
