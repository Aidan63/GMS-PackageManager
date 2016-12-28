package utils.cli;

/**
 * Stores some basic info about each argument.
 *
 * @author  Aidan Lee <aidan.lee63@gmail.com>
 * @version 1.0.0
 * @since   0.2.0
 */
class CliArg
{
    /**
     * The full typed name of the argument. e.g. --full-name
     */
    public var fullName (default, null):String;
    /**
     * The short typed name of the argument. e.g. -f
     */
    public var shortName(default, null):String;
    /**
     * Whether the argument expects a value to come with it.
     */
    public var expected (default, null):Bool;

    public function new(_full:String, _short:String, _expected:Bool)
    {
        fullName  = _full;
        shortName = _short;
        expected  = _expected;
    }
}

/**
 * Stores details for all command options and some functions for getting and checking options.
 *
 * @author  Aidan Lee <aidan.lee63@gmail.com>
 * @version 1.0.0
 * @since   0.2.0
 */
class CliArguments
{
    /**
     * Maps each command with an array of the CliArg object for each optional argument.
     */
    private static var commandArgs:Map<String, Array<CliArg>> = [
        "install" => [
            new CliArg("local"  , "l", false),
            new CliArg("git"    , "g", false),
            new CliArg("path"   , "p", true ),
            new CliArg("script" , "s", false)
        ]
    ];
}