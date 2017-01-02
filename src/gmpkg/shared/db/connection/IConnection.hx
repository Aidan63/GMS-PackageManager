package gmpkg.shared.db.connection;

/**
 * Interface for all connection classes.
 *
 * @author  Aidan Lee <aidan.lee63@gmail.com>
 * @version 1.0.0
 * @since   0.2.0
 */
interface IConnection
{
    /**
     * Opens a connection to the database.
     */
    public function connect():Void;
}
