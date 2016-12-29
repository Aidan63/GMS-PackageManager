import utest.Runner;
import utest.ui.Report;
import tests.gmpkg.*;

class TestAll
{
    public static function main()
    {
        var runner = new Runner();
        runner.addCase(new TestCliArguments());
        runner.addCase(new TestCliParser());
        Report.create(runner);
        runner.run();
    }
}
