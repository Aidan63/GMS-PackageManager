package gmpkg.shared.db.connection.factory;

import gmpkg.shared.db.connection.IConnection;
import gmpkg.shared.db.connection.HaxeLowConnection;

/**
 * Class for a connection to a HaxeLow database.
 *
 * @author  Aidan Lee <aidan.lee63@gmail.com>
 * @version 1.0.0
 * @since   0.2.0
 */
class HaxeLowConnectionFactory implements IConnectionFactory
{
    public function new() {};
    
    /**
     * Creates a new HaxeLow connection instance.
     *
     * @return  Returns a new HaxeLow connection.
     */
    public function getConnection():IConnection
    {
        return new HaxeLowConnection();
    }
}
