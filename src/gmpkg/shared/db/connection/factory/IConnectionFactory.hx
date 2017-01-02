package gmpkg.shared.db.connection.factory;

import gmpkg.shared.db.connection.IConnection;

/**
 * Interface for getting the db connection type.
 *
 * @author  Aidan Lee <aidan.lee63@gmail.com>
 * @version 1.0.0
 * @since   0.2.0
 */
interface IConnectionFactory
{
    /**
     * Returns a connection instance for the connection connection factory type.
     */
    public function getConnection():IConnection;
}
