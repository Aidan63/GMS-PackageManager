package packagemanager;

import utest.Assert;
import src.CLIParser;

class TestCLIParser
{
    var parser:CLIParser;

    public function new()
    {
        //
    }

    public function setup()
    {
        var args = ["install", "-fp", "extensions", "home/aidan/GameMaker-Studio/Applications/", "InputDog"];
        parser = new CLIParser(args);
    }

    public function testPopTopItem()
    {
        var expectedItem = "install";
        var actualItem:String = parser.popTopItem();

        Assert.equals(expectedItem, actualItem);
    }
}
