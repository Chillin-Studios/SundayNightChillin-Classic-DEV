package objects;

import states.ShopState;

class SleepZGroup extends FlxTypedGroup<FlxSprite>
{
    public function new()
    {
        super();

        var zSprite:FlxSprite = new FlxSprite().loadGraphic(Paths.image(ShopState.imageAssetsPath + '/cursor/sleeping'));
        zSprite.kill();
        add(zSprite);

        // FlxG.debugger.track(this);
    }

    public function generateZ():Void
    {
        var zSprite:FlxSprite = recycle(FlxSprite, function() {
            return new FlxSprite().loadGraphic(Paths.image(ShopState.imageAssetsPath + '/cursor/sleeping'));
        });

        zSprite.x = 40;
        FlxTween.tween(zSprite, {x: zSprite.x + FlxG.random.float(20, 30)}, 4 / 8, {type: PINGPONG});

        zSprite.y = FlxG.height - 185;
        FlxTween.tween(zSprite, {y: 348}, 4, {onComplete: function(_) {
            FlxTween.cancelTweensOf(zSprite);
            zSprite.kill();
        }});

        zSprite.alpha = 0;
        FlxTween.tween(zSprite, {alpha: 1}, 0.1, {onComplete: function(_) {
            FlxTween.tween(zSprite, {alpha: 0}, 4 - _.duration);
        }});
    }
}