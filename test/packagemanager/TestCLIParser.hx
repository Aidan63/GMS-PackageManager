/*
package packagemanager;

import utest.Assert;
import src.cliParser.CLIParser;

class TestCLIParser
{
    private var parser:CLIParser;
    private var args = ["install", "-fp", "extensions", "home/aidan/GameMaker-Studio/Applications/", "InputDog"];

    public function new()
    {
        //
    }

    public function testPopTopItem()
    {
        var parser = new CLIParser(args);

        var expectedItem = "install";
        var actualItem:String = parser.popTopItem();

        Assert.equals(expectedItem, actualItem);
    }

    public function testGetCliOptions()
    {
        var parser = new CLIParser(args);

        var expectedMap = new Map<String, String>();
        expectedMap.set("f", "extensions");
        expectedMap.set("p", "home/aidan/GameMaker-Studio/Applications/");

        parser.popTopItem();
        var actualMap:Map<String, String> = parser.getCliOptions();

        Assert.equals(expectedMap.toString(), actualMap.toString());
    }
}
*/