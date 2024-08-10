package objects;

/**
 * A FlxSprite that acts like a mouse.
 *
 * This follows the original FlxG.mouse positions and adds basic mouse functionality.
 *
 * TODO:
 * - [x] clicked Bool should be if the mouse is actually clicking.
 * - [x] Put the enum as an abstract string.
 * - [ ] (MAYBE) Make Clickable object class and call that click code in here. via the click function. (3 bools and/or functions that consist of justClicked, clicked, justReleasedClick)
 */
class ChillinCursor extends FlxSprite
{
    static inline final pathToCursor:String = 'shop/cursor/';

    final assetList:Array<String> = ['normal', 'clicked', 'left_arrow', 'left_arrow_clicked', 'right_arrow', 'right_arrow_clicked', 'sleeping'];

    /**
     * The current state this mouse is in right now.
     */
    public var mouseState:MouseState = NORMAL;

    /**
     * The mouse states that won't allow you to click.
     */
    public final ignoreClickStates:Array<MouseState> = [SLEEPING];

    /**
     * Whether the mouse is being clicked right now.
     */
    public var clicked:Bool = false;

    public function new()
    {
        super();

        for (ass in assetList)
            Paths.image(pathToCursor + ass); // Caching

        switchMouseState(NORMAL, true);
        antialiasing = false;
    }

    override public function update(elapsed:Float):Void
    {
        x = FlxG.mouse.x;
        y = FlxG.mouse.y;

        clicked = (FlxG.mouse.pressed && !ignoreClickStates.contains(mouseState));

        if (clicked)
        {
            click();
        }
        else
        {
            switchMouseState(NORMAL, false);
        }

        #if FLX_DEBUG
        FlxG.watch.addQuick('Mouse [X/Y/STATE]', [x, y, mouseState]);
        #end

        super.update(elapsed);
    }

    /**
     * Replaces the mouses graphic and also sets its current state.
     * @param graphicName Mouse Image Name. (MUST BE LOCATED IN `shop/cursor`)
     * @param state The state the mouse should be in on switch.
     * @param skipStateCheck If false, checks the mouse state BEFORE loading the next graphic. (NOT RECOMMENDED TO LEAVE TRUE IN UPDATE ESPECIALLY!)
     */
    public function loadMouseGraphic(graphicName:String, state:MouseState, ?skipStateCheck:Bool = false):Void
    {
        if (mouseState != state || skipStateCheck)
            loadGraphic(Paths.image(pathToCursor + graphicName));

        mouseState = state;
    }

    public function click():Void
    {
        switch (mouseState)
        {
            case LEFT_ARROW:
                switchMouseState(LEFT_ARROW_CLICKED, false);

            case RIGHT_ARROW:
                switchMouseState(RIGHT_ARROW_CLICKED, false);

            default:
                switchMouseState(CLICKED, false);
        }
    }

    public function switchMouseState(nextMouseState:MouseState, ?skipStateCheck:Null<Bool> = false):Void
    {
        loadMouseGraphic(cast (nextMouseState, String).toLowerCase(), nextMouseState, skipStateCheck);
    }
}

enum abstract MouseState(String)
{
    var NORMAL = 'NORMAL';
    var CLICKED = 'CLICKED';
    var LEFT_ARROW = 'LEFT_ARROW';
    var RIGHT_ARROW = 'RIGHT_ARROW';
    var LEFT_ARROW_CLICKED = 'LEFT_ARROW_CLICKED';
    var RIGHT_ARROW_CLICKED = 'RIGHT_ARROW_CLICKED';
    var SLEEPING = 'SLEEPING';
}