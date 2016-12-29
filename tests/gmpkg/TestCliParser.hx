package tests.gmpkg;

import utest.Assert;
import utils.cli.CliParser;

class TestCliParser
{
    public function new() {}

    public function testGetOptionsMap()
    {
        var expectedMap:Map<String, String>;

        expectedMap = [
            "local" => "",
            "dl-only" => "",
            "path" => "/path/to/project.gmx",
            "git" => "git@github.com"
        ];
        Assert.same(expectedMap, CliParser.getOptionsMap("install", ["-p", "-l", "-d", "-g", "/path/to/project.gmx", "git@github.com"]));
        Assert.same(expectedMap, CliParser.getOptionsMap("install", ["--path", "-l", "--dl-only", "-g", "/path/to/project.gmx", "git@github.com"]));
        Assert.same(expectedMap, CliParser.getOptionsMap("install", ["/path/to/project.gmx", "--path", "git@github.com", "-l", "--dl-only", "-g"]));

        expectedMap = [
            "dl-only" => "",
            "git" => "git@github.com"
        ];
        Assert.same(expectedMap, CliParser.getOptionsMap("install", ["-d", "-g", "git@github.com"]));
        Assert.same(expectedMap, CliParser.getOptionsMap("install", ["git@github.com", "--dl-only", "-g"]));
        Assert.same(expectedMap, CliParser.getOptionsMap("install", ["-d", "git@github.com", "--git"]));
    }
}
