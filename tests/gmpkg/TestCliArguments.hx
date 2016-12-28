package tests.gmpkg;

import utest.Assert;
import utils.cli.CliArguments;

class TestCliArguments
{
    private var args:CliArguments;

    public function new() {}

    public function setup()
    {
        args = new CliArguments();
    }

    public function testOptionExists()
    {
        Assert.isTrue(args.optionExists("install", "local"));
        Assert.isTrue(args.optionExists("install", "l"));

        Assert.isFalse(args.optionExists("install", ""));
        Assert.isFalse(args.optionExists("install", "not an option"));

        Assert.isFalse(args.optionExists("not a command", ""));
    }

    public function testOptionExpectsValue()
    {
        Assert.isTrue(args.optionExpectsValue("install", "path"));
        Assert.isTrue(args.optionExpectsValue("install", "p"));

        Assert.isFalse(args.optionExpectsValue("install", "local"));
        Assert.isFalse(args.optionExpectsValue("install", "l"));

        Assert.isFalse(args.optionExpectsValue("install", ""));
        Assert.isFalse(args.optionExpectsValue("install", "not an option"));

        Assert.isFalse(args.optionExpectsValue("not a command", ""));
    }

    public function testGetOptionFullName()
    {
        Assert.equals("git", args.getOptionFullName("install", "g"));
        Assert.equals("git", args.getOptionFullName("install", "git"));

        Assert.isNull(args.getOptionFullName("install", ""));
        Assert.isNull(args.getOptionFullName("install", "not an option"));

        Assert.isNull(args.getOptionFullName("not a command", ""));
    }
}
