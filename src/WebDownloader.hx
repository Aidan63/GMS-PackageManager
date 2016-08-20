package src;

import haxe.Http;
import src.FileHandler;

class WebDownloader
{
    public function new() {
        //
    }
    
    public function downloadPackages(_packageUrl:String, _packageName:String) : Void
    {
        var fh:FileHandler = new FileHandler();
        var req = new Http(_packageUrl);
        
        req.onData = function (data) {
            Sys.println("Successfully downloaded " + _packageName);
            fh.writeToFile(data, _packageName);
        }
        req.onError = function (error) {
            Sys.println("Error while downloading package " + _packageName + ", " + error);
        }
        
        req.request(false);
    }

    /// Returns the xml of the repo or an empty string if it couldn't be found
    public function getRepository(_repoURl:String) : String
    {
        var req = new Http(_repoURl);
        var retData = "";

        req.onData = function (data) {
            retData = data;
        }

        req.onError = function (error) {
            Sys.println("Error trying to download repository details from " + _repoURl);
            Sys.println(error);
        }

        req.request(false);

        return retData;
    }
}
