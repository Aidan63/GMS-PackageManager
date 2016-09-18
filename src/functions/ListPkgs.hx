package src.functions;

import src.FileHandler;

class ListPkgs
{
    public function new()
    {
        listAll();
    }

    public function listAll() : Void
    {
        var fh:FileHandler = new FileHandler();
        var list = fh.getPackageList();

        for (line in list)
        {
            var split = line.split(",");
            if (split.length != 0)
            {
                if (fh.packageIsDownloaded(split[0]))
                {
                    Sys.println(split[0] + " (Downloaded)");
                }
                else
                {
                    Sys.println(split[0]);
                }
            }
        }
    }
}
