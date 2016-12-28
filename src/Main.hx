package;

import utils.cli.CliParser;
import utils.Help;

class Main
{
    public static function main()
    {
        var parser = new CliParser(Sys.args());
        parser.parse();
    }
}
