package gmpkg.shared;

import gmpkg.utils.Log;
import gmpkg.shared.WebDownloader;

typedef OwnerJson = {
    var name   :String;
    var email  :String;
    var website:String;
}

typedef UrlJson = {
    var gmVersion:String;
    var version  :String;
    var url      :String;
}

typedef PackageJson = {
    var name:String;
    var url :Array<UrlJson>;
}

typedef RepositoryJson = {
    var name    :String;
    var url     :String;
    var owner   :OwnerJson;
    var packages:Array<PackageJson>;
}

class RepoManager
{
    public static function addRepository(_urls:Array<String>)
    {
        for (url in _urls)
        {
            Log.debug(url);

            var data:{success:Bool, data:String};
            data = WebDownloader.downloadFile(url);

            Log.debug(data.success + ", " + data.data);
        }
    }
}
