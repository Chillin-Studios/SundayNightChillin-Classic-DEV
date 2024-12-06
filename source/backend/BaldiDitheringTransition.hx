package backend;

import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.display.BitmapData;

class BaldiDitheringTransition extends MusicBeatSubstate
{
    public static final ditherScale:Int = 4;
    public static final ditherSide:Int = 3;
    public static final ditherSpeed:Float = 0.06;
    public static final ditherRemove:Array<Array<Int>> = [
        [1, 0],
        [2, 1],
        [1, 2],
        [0, 1],
        [2, 0],
        [2, 2],
        [0, 2],
        [0, 0],
        [1, 1]
    ];

    static var grabbedState:BitmapData;
    public static function grabLastState():Void
    {
        if(grabbedState != null)
        {
            grabbedState.dispose();
            grabbedState.disposeImage();
        }

        grabbedState = BitmapData.fromImage(FlxG.stage.window.readPixels());
    }

    var transitionSprite:FlxSprite;
    override public function create()
    {
        var camera:FlxCamera = new FlxCamera();
        camera.bgColor = 0;
        FlxG.cameras.add(camera, false);
        cameras = [camera];

        super.create();

        if(grabbedState == null)
        {
            close();
            return;
        }
        
        transitionSprite = new FlxSprite().loadGraphic(grabbedState.clone());
        add(transitionSprite);
    }

    var transitionTime:Float = 0;
    var transitionIndex:Int = 0;
    override public function update(elapsed:Float):Void
    {
        if(grabbedState == null)
            return;

        transitionTime += elapsed;

        if(transitionTime >= ditherSpeed)
        {
            for(i in 0...Math.round(transitionSprite.width / (ditherSide * ditherScale)))
            {
                for(j in 0...Math.round(transitionSprite.height / (ditherSide * ditherScale)))
                {
                    var xRemove:Float = ((ditherSide * i) + ditherRemove[transitionIndex][0]) * ditherScale;
                    var yRemove:Float = ((ditherSide * j) + ditherRemove[transitionIndex][1]) * ditherScale;
                    transitionSprite.pixels.fillRect(new Rectangle(xRemove, yRemove, ditherScale, ditherScale), 0);
                }
            }

            transitionTime = 0;
            transitionIndex++;

            if(transitionIndex >= ditherRemove.length)
            {
                transitionSprite.destroy();
                FlxG.cameras.remove(cameras[0]);
                close();
            }
        }
        super.update(elapsed);
    }
}