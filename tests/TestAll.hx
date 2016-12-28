import utest.Runner;
import utest.ui.Report;
import tests.gmpkg.TestCliArguments;

class TestAll
{
    public static function main()
    {
        var runner = new Runner();
        runner.addCase(new TestCliArguments());
        Report.create(runner);
        runner.run();
    }
}
