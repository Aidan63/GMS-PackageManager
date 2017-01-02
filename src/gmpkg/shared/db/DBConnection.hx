package gmpkg.shared.db;

import gmpkg.shared.db.connection.IConnection;
import gmpkg.shared.db.connection.factory.IConnectionFactory;
import gmpkg.shared.db.connection.factory.HaxeLowConnectionFactory;

/**
 * Used to open, close, send, and retrieve data from a db connection.
 *
 * @author  Aidan Lee <aidan.lee63@gmail.com>
 * @version 1.0.0
 * @since   0.2.0
 */
class DBConnection
{
    /**
     * The connection factory that will be used to get the connection type.
     */
    private var connectionFactory:IConnectionFactory;

    public function new(?_connFactory:IConnectionFactory)
    {
        if (_connFactory == null)
        {
            connectionFactory = getConnectionType();
        }
        else
        {
            connectionFactory = _connFactory;
        }
    }

    /**
     * Gets a connection factory instance for a database.
     *
     * @return  The connection factory instance for use in the connection.
     */
    private function getConnectionType():IConnectionFactory
    {
        return new HaxeLowConnectionFactory();
    }

    /**
     * Attempts to open a databse connection based on the connection factory.
     */
    public function start()
    {
        var connection:IConnection = connectionFactory.getConnection();
        connection.connect();
    }
}
