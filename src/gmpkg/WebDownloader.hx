package src;

import haxe.Http;
import src.FileHandler;

class WebDownloader
{
    public function new()
    {
    }
    
    /**
     * Attempts to download the package from the provided URL.
     *
     * @param   _packageUrl     The URL to download the package from.
     * @param   _packageName    The name of the package to pass download.
     */
    public function downloadPackages(_packageUrl:String, _packageName:String) : Void
    {
        var fh  = new FileHandler();
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

    /**
     * Attempt to download the manifest file from the url and return the data.
     *
     * @param   _repoURl    The URL to attempt to download the manifest from.
     * @return              The downloaded manifest or an empty string.
     */
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

    /**
     * Attempts to download a license file and returns a string of the content.
     * Returns a string of the file content.
     *
     * @param   _licenseUrl     The url to try and get the license file from.  
     */
    public function downloadLicense(_licenseUrl:String) : String
    {
        var req = new Http(_licenseUrl);
        var retData = "";

        req.onData = function (data)
        {
            retData = data;
        }

        req.onError = function (error)
        {
            Sys.println("Error trying to download the license file from " + _licenseUrl);
            Sys.println("License file will not be added to the package");
            Sys.println(error);
        }

        req.request(false);

        return retData;
    }
}
