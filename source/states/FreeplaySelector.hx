package states;

import states.FreeplayState;
import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import options.OptionsState;
import states.editors.MasterEditorMenu;

class FreeplaySelector extends MusicBeatState
{
	public static var curSelected:Int = 0;
	public var comingFromFreeplay:Bool = false;

	var freeplayItems:FlxTypedGroup<FlxSprite>;

	var freeplayOptions:Array<Array<Dynamic>> = [
		// Name, Unlocked
		['part1', true],
        ['part2', true],
        ['part3', false],
        ['extra', true],
        ['old', true]
	];

	public static var bg:FlxSprite;
	var camFollow:FlxObject;

	public static var arrowUp:FlxSprite;
	public static var arrowDown:FlxSprite;

	public function new(?comingFromFreeplay:Bool = false)
	{
		this.comingFromFreeplay = comingFromFreeplay;
		super();
	}

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFFFDE871;
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		if (TitleState.titleJSON.checkerData.enabled)
		{
			var checkeredBG:Checkers = new Checkers({
				size: TitleState.titleJSON.checkerData.size,
				colors: [0x33FFFFFF, 0x0],
				speed: TitleState.titleJSON.checkerData.speed,
				alpha: 1
			});
			checkeredBG.scrollFactor.set(0, 0);
			add(checkeredBG);
		}

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		freeplayItems = new FlxTypedGroup<FlxSprite>();
		add(freeplayItems);

		for (i in 0...freeplayOptions.length)
		{
			var freeplayItem:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/' + freeplayOptions[i][0]));
            freeplayItem.screenCenter();
            freeplayItem.y += (FlxG.height * i);
            freeplayItems.add(freeplayItem);
		}

		arrowUp = new FlxSprite();
		arrowUp.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		arrowUp.animation.addByPrefix('idle', 'arrow left');
		arrowUp.animation.addByPrefix('pressed', 'arrow push left');
		arrowUp.animation.play('idle');
		arrowUp.updateHitbox();
		arrowUp.angle = 90;
		arrowUp.scrollFactor.set();
		arrowUp.screenCenter(X);
		arrowUp.y = 10;
		add(arrowUp);

		arrowDown = new FlxSprite();
		arrowDown.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		arrowDown.animation.addByPrefix('idle', 'arrow right');
		arrowDown.animation.addByPrefix('pressed', 'arrow push right');
		arrowDown.animation.play('idle');
		arrowDown.updateHitbox();
		arrowDown.angle = 90;
		arrowDown.scrollFactor.set();
		arrowDown.screenCenter(X);
		arrowDown.y = FlxG.height - arrowDown.height - 10;
		add(arrowDown);

		changeItem();

		super.create();

		FlxG.camera.follow(camFollow, null, 8);
		FlxG.camera.snapToTarget();

		if(comingFromFreeplay)
		{
            arrowUp.alpha = arrowDown.alpha = 0;
			FlxTween.tween(arrowUp, {alpha: 1}, 0.2, {ease: FlxEase.quadIn});
			FlxTween.tween(arrowDown, {alpha: 1}, 0.2, {ease: FlxEase.quadIn});

            for (i in freeplayItems.members)
            {
				i.alpha = 0;
                FlxTween.tween(i, {alpha: 1}, 0.4, {ease: FlxEase.quadIn});
            }
        }
	}

	var selectedSomethin:Bool = false;
	var isMagenta:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;

			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.UI_UP_P)
				arrowUp.animation.play('pressed');

			if (controls.UI_DOWN_P)
				arrowDown.animation.play('pressed');

			if(controls.UI_UP_R)
				arrowUp.animation.play('idle');

			if(controls.UI_DOWN_R)
				arrowDown.animation.play('idle');

			arrowUp.angle = arrowDown.angle = 90;

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT)
			{
				if (!freeplayOptions[curSelected][1])
				{
					var buzzer:FlxSound = FlxG.sound.play(Paths.sound('buzzer'), 0.1);
					FlxG.camera.shake(0.0015, buzzer.length / 1000);
					return;
				}

				FlxG.sound.play(Paths.sound('confirmMenu'));

				selectedSomethin = true;

                if (ClientPrefs.data.flashing)
				{
					new FlxTimer().start(0.15, function (tmr:FlxTimer)
					{
						if (isMagenta)
							bg.color = 0xFFFDE871;
						else
							bg.color = 0xFFFD719B;

						isMagenta = !isMagenta;
					}, Std.int(1.1 / 0.15));
				}

				FlxFlicker.flicker(freeplayItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
				{
                    freeplayItems.members[curSelected].visible = true;
                    freeplayItems.members[curSelected].alpha = 0;

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.switchState(new FreeplayState(freeplayOptions[curSelected][0]));
				});

				FlxTween.tween(arrowUp, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				FlxTween.tween(arrowDown, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});

                for (i in 0...freeplayItems.members.length)
				{
					if (i == curSelected)
						continue;

					FlxTween.tween(freeplayItems.members[i], {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
				}
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (selectedSomethin)
			return;

		FlxG.sound.play(Paths.sound('scrollMenu'));

        curSelected += huh;

        if (curSelected >= freeplayItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = freeplayItems.length - 1;

        var point = freeplayItems.members[curSelected].getGraphicMidpoint();
		camFollow.setPosition(point.x, point.y);
	}
}
