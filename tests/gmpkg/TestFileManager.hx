package tests.gmpkg;

import utest.Assert;
import haxe.io.Path;
import gmpkg.shared.FileManager;

class TestFileManager
{
    public function new() {}

    public function testGetDataStorage()
    {
        var expectedDir:String = "";
        switch (Sys.systemName())
        {
            case "Windows":
                expectedDir = Path.addTrailingSlash(Path.join([Sys.getEnv("LOCALAPPDATA"), "gmpkg"]));
            case "Mac":
                expectedDir = Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), "Library", "Application Support", "gmpkg"]));
            case "Linux":
                expectedDir = Path.addTrailingSlash(Path.join([Sys.getEnv("HOME"), ".config", "gmpkg"]));
        }

        Assert.equals(expectedDir, FileManager.getDataStorage());
        Assert.equals("", FileManager.getDataStorage(""));
    }
}
