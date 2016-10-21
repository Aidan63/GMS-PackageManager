package src;

class CLIParser
{
    private var arguments:Array<String>;

    public function new(_args)
    {
        arguments = _args;
    }

    public function parseInput() : Void
    {
        if (arguments.length > 0)
        {
            var cmd:String = popTopItem();
            switch (cmd.toUpperCase())
            {
                case "INSTALL":

                case "REMOVE":

                case "UPDATE":

                case "UPGRADE":

                case "ADD-REPOSITORY":

                case "REMOVE-REPOSITORY":

                case "LIST":

                case "CREATE":

                default:
                    trace("UNKNOWN COMMAND", cmd);
            }
        }
        else
        {
            // Print Help
        }
    }

    //

    /**
     * Removes and returns the top item from the arguments array.
     *
     * @return          The item removed from the array.
     */
    public function popTopItem() : String
    {
        var item  = arguments[0];
        arguments = arguments.slice(1);

        return item;
    }
}
