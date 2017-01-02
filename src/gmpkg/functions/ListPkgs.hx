package src.functions;

import src.FileHandler;

class ListPkgs
{
    public function new(_options:Map<String, String>, _args:Array<String>)
    {
        listAll();
    }

    /**
     * Displays all packages in the packages.list file and if they are already downloaded.
     */
    public function listAll() : Void
    {
        var fh = new FileHandler();
        var list:List<String> = fh.getPackageList();

        for (line in list)
        {
            var split:Array<String> = line.split(",");
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
