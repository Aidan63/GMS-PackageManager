package;

import Sys.args;
import src.Const;
import src.CLIParser;

class Main
{
    public static function main()
    {
        Const.setupStorage();

        var cli = new CLIParser(args());
        cli.parseInput();
    }
}
