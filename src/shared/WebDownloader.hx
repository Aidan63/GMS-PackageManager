package shared;

import haxe.Http;

/**
 * The structure returned from the download functions.
 */
typedef DownloadReturn = {
    /**
     * Boolean for if the download was successful.
     */
    var success:Bool;

    /**
     * String of the file if the download was successful, an error message otherwise.
     */
    var data:String;
}

class WebDownloader
{
    /**
     * Attempts to download the file from the provided URL.
     *
     * @param   _url    The URL to download the file from.
     * @return  Anonymous structure with a successfield and a data field.
     */
    public static function downloadFile(_url:String):DownloadReturn
    {
        var request = new Http(_url);
        var returnData:DownloadReturn;

        request.onData = function(_data)
        {
            returnData = {success:true, data:_data};
        }

        request.onError = function(_error)
        {
            returnData = {success:false, data:_error};
        }

        request.request(false);

        return returnData;
    }
}
