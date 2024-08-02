package states.stages;

import cutscenes.DialogueBoxPsych;
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;

class GBStage extends BaseStage
{
	var rainShader:FlxRuntimeShader;
	var isRaining:Bool = false;

	var lightning:FlxSprite;
	var secondsUntilStrike:Float = 9;
	var isLightning:Bool = false;

	var bg:FlxSprite;
	var clouds:BGSprite;
	var mountain3:BGSprite;
	var mountain2:BGSprite;
	var mountain1:BGSprite;
	var ground:BGSprite;

	override public function create():Void
	{
		bg = new FlxSprite(-600, -500).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		bg.color = 0x0;

		if (!ClientPrefs.data.lowQuality)
		{
			clouds = new BGSprite(null, -600, -400, 0.3, 0.3);
			mountain3 = new BGSprite(null, -550, -11, 0.8, 0.4);
			mountain2 = new BGSprite(null, -600, 41, 0.75, 0.4);
			mountain1 = new BGSprite(null, -600, 150, 0.7, 0.4);
		}

		ground = new BGSprite(null, -500, 702, 0.9, 0.9);

		reloadSprites('Light');

		add(bg);

		if (!ClientPrefs.data.lowQuality)
		{
			add(clouds);
			add(mountain3);
			add(mountain2);
			add(mountain1);
		}

		add(ground);
	}

    override public function createPost():Void
    {
        if (isStoryMode && !PlayState.seenCutscene)
        {
            switch (songName)
            {
                case 'chillin':
                    setStartCallback(function () {
						game.videoCutscene = game.startVideo('chillin-start', false, true, false, true);
						game.videoCutscene.finishCallback = game.videoCutscene.onSkip = function ()
						{
							if (game.generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !game.endingSong && !game.isCameraOnForcedPos)
							{
								game.moveCameraSection();
								camGame.snapToTarget();
							}
							game.skipBG.destroy();
							game.skipTxt.destroy();
							game.startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')));
						};
                    });

				case 'serenity':
					setStartCallback(function () {
						game.startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')));
					});

                case 'anger-issues':
					setStartCallback(function () {
						game.startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')));
					});

                    setEndCallback(function () {
                        // All because I saw a frame of the actual game at the end.
                        var black:FlxSprite = new FlxSprite(-1000, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.BLACK);
                        black.scrollFactor.set();
                        black.camera = camOther;
                        black.alpha = 0;
                        add(black);

						isLightning = true;

                        // Just so it doesn't flash black before playing.
                        new FlxTimer().start(1, function (tmr:FlxTimer) {
                            black.alpha = 1;
                        });

                        game.videoCutscene = game.startVideo('anger-issues-end', false, true, false, true);
                        game.endingSong = true;
                    });
            }
        }
    }

	override public function update(elapsed:Float):Void
	{
		if (ClientPrefs.data.shaders && isRaining && rainShader != null)
			rainShader.setFloat('uTime', rainShader.getFloat('uTime') + elapsed);

        if (game.isDead && rainShader != null && isRaining)
            removeRainShader();

		if(!isLightning && ClientPrefs.data.flashing && isRaining)
		{
			secondsUntilStrike -= elapsed;

			FlxG.watch.addQuick('strikeShit', secondsUntilStrike);

			if(secondsUntilStrike <= 0)
			{
				secondsUntilStrike = FlxG.random.int(7, 24);
				applyLightning();
			}
		}
	}

	override public function camZoomChange(zoom:Float):Void
	{
		if (ClientPrefs.data.shaders && isRaining && rainShader != null)
			rainShader.setFloatArray('uCameraBounds', [camGame.viewLeft / zoom, camGame.viewTop / zoom, camGame.viewRight / zoom, camGame.viewBottom / zoom]);
	}

	public function applyLightning():Void
	{
		if(!ClientPrefs.data.flashing)
			return;

		isLightning = true;

		if(ClientPrefs.data.lowQuality)
		{
			FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
			camGame.flash(FlxColor.WHITE, 1, function() {
				isLightning = false;
			});
		}
		else
		{
			lightning.alpha = 1;
			lightning.x = FlxG.random.float(camFollow.x - (FlxG.width / 2), camFollow.x + (FlxG.width / 2));
			remove(lightning);

			// i hate myself
			var spriteBehindMyAss:FlxSprite = FlxG.random.getObject([mountain3, mountain2, mountain1, ground]);
			insert(members.indexOf(spriteBehindMyAss), lightning);
			lightning.scrollFactor.set(spriteBehindMyAss.scrollFactor.x, spriteBehindMyAss.scrollFactor.y);

			new FlxTimer().start((1/24)*2, function(_) {
				lightning.alpha = 0;

				new FlxTimer().start((1/24)*1, function(_) {
					lightning.alpha = 1;

					camGame.flash();
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

					if(boyfriend.animOffsets.exists('scared'))
						boyfriend.playAnim('scared', true);

					if(dad.animOffsets.exists('scared'))
						dad.playAnim('scared', true);

					FlxTween.tween(lightning, {alpha: 0}, 1.8, {onComplete: function(_) {
						isLightning = false;
					}});
				});
			});
		}
	}

	var precacheImageList:Array<String> = ['clouds', 'mountainback3', 'mountainback2', 'mountainback1', 'lightning'];
	var precacheImageListLowQuality:Array<String> = ['ground'];

	override public function eventPushed(event:objects.Note.EventNote):Void
	{
		var value1:String = event.value1.toLowerCase();

		switch (event.event)
		{
			case 'Change GB Stage Setting':
				// Precaching all images before hand to avoid frame drops upon changing.
				var precache:Array<String> = precacheImageListLowQuality;

				if (!ClientPrefs.data.lowQuality)
				{
					for (i in precacheImageList)
					{
						precache.push(i);
					}
				}

				for (image in precache)
				{
					if (Paths.fileExists('$value1/$image', IMAGE))
						Paths.image('$value1/$image', null, true);
				}

				// Also precaching thunder sound for rain
				// Fun Facts with CrusherNotDrip: idk what causes the lag spike we did allw e could GO HOME

				if (value1.toLowerCase() == 'rain')
				{
					Paths.sound('thunder_1');
					Paths.sound('thunder_2');
				}

				if (ClientPrefs.data.shaders && value1.toLowerCase() == 'rain' && rainShader == null)
				{
					rainShader = game.createRuntimeShader('rain');
					rainShader.setFloatArray('uScreenResolution', [FlxG.width, FlxG.height]);
					rainShader.setFloatArray('uCameraBounds', [camGame.viewLeft / game.defaultCamZoom, camGame.viewTop / game.defaultCamZoom, camGame.viewRight / game.defaultCamZoom, camGame.viewBottom / game.defaultCamZoom]);
					rainShader.setFloat('uTime', 1);
					rainShader.setFloat('uIntensity', 0.2);
					rainShader.setFloat('uScale', FlxG.height / 500);
				}
		}
	}

    var rainShaderFilter:ShaderFilter;

	override public function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float):Void
	{
		switch (eventName)
		{
			case 'Change GB Stage Setting':
				reloadSprites(value1);

				if (ClientPrefs.data.shaders && rainShader != null)
				{
					if (value1.toLowerCase() == 'rain' && !isRaining)
					{
                        rainShaderFilter = new ShaderFilter(rainShader);

                        if (FlxG.camera.filters == null)
                            FlxG.camera.filters = [rainShaderFilter];
                        else
                            FlxG.camera.filters.push(rainShaderFilter);

						isRaining = true;

						applyLightning();
					}
                    else if (value1.toLowerCase() != 'rain' && isRaining)
                        removeRainShader();
				}
		}
	}

	override public function gameOver()
	{
		if (rainShader != null && isRaining)
            removeRainShader();
	}

    function removeRainShader():Void
    {
        rainShader = null;
        FlxG.camera.filters.remove(rainShaderFilter);
        isRaining = false;
    }

	function reloadSprites(type:String):Void
	{
		var typeLowercase:String = type.toLowerCase();

		bg.color = grabBGColor(typeLowercase);
		bg.scrollFactor.set(0.1, 0.1);

		if (!ClientPrefs.data.lowQuality)
		{
			clouds.loadGraphic(Paths.image('$typeLowercase/clouds'));

			if (typeLowercase == 'light')
			{
				clouds.x = 634;
				clouds.y = -367;
				clouds.velocity.x = 5;
			}
			else
			{
				clouds.x = -750;
				clouds.y = -200;
				clouds.velocity.x = 0;
			}

			mountain3.loadGraphic(Paths.image('$typeLowercase/mountainback3'));
			mountain2.loadGraphic(Paths.image('$typeLowercase/mountainback2'));
			mountain1.loadGraphic(Paths.image('$typeLowercase/mountainback1'));
		}

		ground.loadGraphic(Paths.image('$typeLowercase/ground'));
		ground.setGraphicSize(Std.int(ground.width * 1.2));

		if (typeLowercase == 'rain' && !ClientPrefs.data.lowQuality) // was acting up if i didnt do this
		{
			remove(lightning);

			lightning = new FlxSprite(0, -250);
			lightning.frames = Paths.getSparrowAtlas('rain/lightning');
			lightning.animation.addByPrefix('strike', 'Lightning w effect', 24, true);
			lightning.animation.play('strike');
			insert(members.indexOf(ground), lightning);
			lightning.alpha = 0;

			FlxG.debugger.track(lightning);
		}
	}

	function grabBGColor(type:String):FlxColor
	{
		return switch (type.toLowerCase())
		{
			case 'light':
				0xFF95D1DD;

			case 'rain':
				0xFF78979D;

			default:
				0x0;
		};
	}
}
