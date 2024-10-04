package states;

class GalleryState extends MusicBeatState
{
    override public function create():Void
    {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.color = 0xFFCA02A9;
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

        super.create();
    }
}