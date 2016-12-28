package;

import utils.cli.CliParser;
import utils.Log;

class Main
{
    public static function main()
    {
        var parser = new CliParser(Sys.args());
        parser.parse();
    }
}
