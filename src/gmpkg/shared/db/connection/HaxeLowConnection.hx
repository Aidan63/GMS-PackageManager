package gmpkg.shared.db.connection;

import gmpkg.utils.Log;

/**
 * Interface for getting the db connection type.
 *
 * @author  Aidan Lee <aidan.lee63@gmail.com>
 * @version 1.0.0
 * @since   0.2.0
 */
class HaxeLowConnection implements IConnection
{
    public function new() {}

    public function connect()
    {
        Log.debug("Connecting to HaxeLow DB...");
    }
}
