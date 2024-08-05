package states;

class ShopState extends MusicBeatState
{
	var bg:FlxSprite;
	var wipText:FlxText;
	var isShopping:Bool = false;

	private static var musicPosition:Float = 0;
	override public function create():Void
	{
		bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFF812A6E;
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

		wipText = new FlxText(0, 0, FlxG.width, "", 32);
		wipText.setFormat('DigitalDisco.ttf', 128 - 32, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		wipText.text = 'W.I.P.\nYou are idling.';
		wipText.screenCenter();
		add(wipText);

		super.create();

		FlxG.sound.music.stop();
		FlxG.sound.playMusic(Paths.music('shop/idle'), 0.8);
		FlxG.sound.music.time = musicPosition;

		Paths.music('shop/shopping'); // preload
	}

	var specialMoment:Bool = false;
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(specialMoment)
			return;

		musicPosition = FlxG.sound.music.time;

		if(controls.ACCEPT)
		{
			isShopping = !isShopping;

			FlxG.sound.music.stop();

			if(isShopping)
			{
				FlxG.sound.playMusic(Paths.music('shop/shopping'), 0.95);
				FlxG.sound.music.time = musicPosition;
			}
			else
			{
				FlxG.sound.playMusic(Paths.music('shop/idle'), 0.95);
				FlxG.sound.music.time = musicPosition;
			}

			wipText.text = 'W.I.P.\nYou are ${(isShopping ? 'shopping' : 'idling')}.';
		}

		if(controls.BACK)
		{
			specialMoment = true;
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('sncTitle'));
		}
	}
}