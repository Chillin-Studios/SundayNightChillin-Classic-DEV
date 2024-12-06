package states;

import flixel.graphics.frames.FlxAtlasFrames;
import backend.WeekData;
import flixel.FlxObject;
import backend.PsychCamera;

class FreeplayState extends MusicBeatState
{
    public static var freeplayOptions:Array<Array<Dynamic>> = [
		// Name, Unlocked
		['part1', true],
        ['part2', true],
        ['part3', false],
        ['extra', true],
        ['old', true]
	];

    public static var lastRemembered:String = 'tutorial';

    public var curFreeplayState:CurFreeplayState = SELECTOR;

    public var songs:Array<SongMetadata>;
    public var filteredSongs:Array<SongMetadata>;
    public var wipText:FlxText;

    public var bgCamera:FlxCamera;
    public var selectorCamera:FlxCamera;
    public var songCamera:FlxCamera;

    public var selectorCamFollow:FlxObject;

    public var curSelectionSelector:Int = 0;
    public var curSelectionSong:Int = 0;

    public var bg:FlxSprite;

    public var freeplayItems:FlxTypedGroup<FlxSprite>;
    public var arrowUp:FlxSprite;
	public var arrowDown:FlxSprite;

    public var oppIcon:FlxSprite;

    var cumingFromPlayState:Bool = false;

    public function new(?cumingFromPlayState:Bool = false)
    {
        this.cumingFromPlayState = cumingFromPlayState;
        super();
    }

    override public function create():Void
    {
        bgCamera = initPsychCamera();
        selectorCamera = new PsychCamera();
        songCamera = new PsychCamera();
		selectorCamera.bgColor.alpha = 0;
		songCamera.bgColor.alpha = 0;

        FlxG.cameras.add(selectorCamera, false);
        FlxG.cameras.add(songCamera, false);

        // LOADING SONGS
        songs = [];
        WeekData.reloadWeekFiles(false);
        for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);

            var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			
            WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				songs.push(new SongMetadata(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), song[3], isLocked, leWeek.album));

				Paths.image('freeplay/volumes/' + song[3]); // precache
			}
		}
		Mods.loadTopMod();

        bg = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.color = 0xFFFDE871;
		add(bg);
		bg.screenCenter();

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

        // CAMFOLLOWS
        selectorCamFollow = new FlxObject(0, 0, 1, 1);
		add(selectorCamFollow);

        // SELECTOR CRAP
        freeplayItems = new FlxTypedGroup<FlxSprite>();
        freeplayItems.cameras = [selectorCamera];
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
        arrowUp.cameras = [selectorCamera];
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
        arrowDown.cameras = [selectorCamera];
		add(arrowDown);

        changeItemSelector();

        // SONG CRAP
        wipText = new FlxText(0, 0, FlxG.width, '', 64);
		wipText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		wipText.scrollFactor.set();
        wipText.screenCenter(Y);
        wipText.cameras = [songCamera];
		add(wipText);

        var iconBox:FlxSprite = new FlxSprite(10, 10).loadGraphic(Paths.image('freeplay/icons/iconbox'));
        iconBox.scrollFactor.set();
        iconBox.cameras = [songCamera];
        add(iconBox);

        oppIcon = new FlxSprite();
        oppIcon.scrollFactor.set();
        oppIcon.cameras = [songCamera];

        var charsAdded:Array<String> = [];
        var frames:FlxAtlasFrames = new FlxAtlasFrames(null);
        for(i in 0...songs.length)
        {
            var char:String = songs[i]?.songCharacter ?? 'haxeflixel';

            if(!Paths.fileExists('images/' + 'freeplay/icons/' + char + '.xml', TEXT))
                char = 'haxeflixel';

            if(charsAdded.contains(char))
                continue;

            var iconFrames:FlxAtlasFrames = Paths.getSparrowAtlas('freeplay/icons/' + char);

            for(frame in iconFrames.frames)
                frame.name = char + frame.name.substring('idle'.length);

            frames.addAtlas(iconFrames);

            charsAdded.push(char);
        }

        oppIcon.frames = frames; 
        for(anim in charsAdded) oppIcon.animation.addByPrefix(anim, anim + '0', 24);
        add(oppIcon);

        super.create();

        selectorCamera.follow(selectorCamFollow, null, 8);
		selectorCamera.snapToTarget();

        if(cumingFromPlayState)
        {
            var theLastSong:SongMetadata = songs.filter(function(song:SongMetadata) {
                return song.songName == lastRemembered;
            })[0];

            var partIndex:Int = -1;
            for(i=>part in freeplayOptions)
            {
                if(part[0] == theLastSong.album)
                {
                    partIndex = i;
                    break;
                }
            }

            curSelectionSelector = partIndex;
            changeItemSelector();
            curFreeplayState = SONG;
        }

        switch(curFreeplayState)
        {
            case SELECTOR:
                songCamera.y = FlxG.height;
                changeItemSelector();

            case SONG:
                selectorCamera.visible = false;
                changeItemSong();

            default:
        }
    }

    override public function update(elapsed:Float):Void
    {
        switch(curFreeplayState)
        {
            case SELECTOR:
                selectorUpdate(elapsed);

            case SONG:
                songUpdate(elapsed);

            default:
        }

        super.update(elapsed);
    }

    public function selectorUpdate(elapsed:Float):Void
    {
        if (controls.UI_UP_P)
        {
            changeItemSelector(-1);
            arrowUp.animation.play('pressed');
        }

        if (controls.UI_DOWN_P)
        {
            changeItemSelector(1);
            arrowDown.animation.play('pressed');
        }

        if(controls.UI_UP_R)
            arrowUp.animation.play('idle');

        if(controls.UI_DOWN_R)
            arrowDown.animation.play('idle');

        if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
            curFreeplayState = TRANSITION;
		}

        if(controls.ACCEPT)
        {
            selectorCamera.snapToTarget();

            var selectedItem = freeplayOptions[curSelectionSelector];
            if (!selectedItem[1])
			{
				var buzzer:FlxSound = FlxG.sound.play(Paths.sound('buzzer'), 0.1);
                selectorCamera.shake(0.0015, buzzer.length / 1000);
                bgCamera.shake(0.0015, buzzer.length / 1000);
				return;
			}
            else
            {
                curFreeplayState = TRANSITION;

                filterSongByAlbum(selectedItem[0]);
                if(filteredSongs[curSelectionSong]?.songName == lastRemembered)
                    curSelectionSong = 0;

                changeItemSong();

                songCamera.visible = true;
                FlxTween.tween(songCamera, {y: 0}, 0.7, {ease: FlxEase.quadIn, onComplete: function(_) {
                    curFreeplayState = SONG;
                }});

                FlxTween.tween(bgCamera, {zoom: 1.2}, 0.7, {ease: FlxEase.quadIn});
                FlxTween.color(bg, 0.7, bg.color, filteredSongs[curSelectionSong].color, {ease: FlxEase.quadIn});

                FlxTween.tween(selectorCamera, {alpha: 0}, 0.7, {ease: FlxEase.quadOut, onComplete: function(_) {
                    selectorCamera.visible = false;
                    selectorCamera.alpha = 1;
                }});
            }
        }
    }

    function changeItemSelector(huh:Int = 0):Void
	{
        if(huh != 0)
            FlxG.sound.play(Paths.sound('scrollMenu'));

        curSelectionSelector += huh;

        if (curSelectionSelector >= freeplayOptions.length)
			curSelectionSelector = 0;
		if (curSelectionSelector < 0)
			curSelectionSelector = freeplayOptions.length - 1;

        selectorCamFollow.setPosition(FlxG.width / 2, (FlxG.height * curSelectionSelector) + (FlxG.height / 2));
	}

    function weekIsLocked(name:String):Bool 
    {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

    function filterSongByAlbum(album:String):Void
    {
        filteredSongs = [];

        for(song in songs)
        {
            if(song.album == album)
                filteredSongs.push(song);
        }
    }

    var selectingDifficulty:Bool = false;
    public function songUpdate(elapsed:Float):Void
    {
        if(!selectingDifficulty)
        {
            if (controls.UI_LEFT_P)
                changeItemSong(-1);
    
            if (controls.UI_RIGHT_P)
                changeItemSong(1);
    
            if(controls.ACCEPT)
            {
                var song:SongMetadata = filteredSongs[curSelectionSong];

                Mods.currentModDirectory = song.folder;
                PlayState.storyWeek = song.week;
                Difficulty.loadFromWeek();

                /*if(Difficulty.list.length != 0)
                {
                    var difficultyIndex:Int = Difficulty.list.indexOf(Difficulty.getDefault());
                    if(difficultyIndex == -1)
                        difficultyIndex = Difficulty.list.indexOf('Normal'); //default for legacy
                    if(difficultyIndex == -1)
                        difficultyIndex = 0;
                }
                else*/
                {
                    PlayState.isStoryMode = false;
                    SNCLoadingState.loadPlayState(song.songName, Difficulty.list.indexOf(Difficulty.getDefault()));
                }
            }
    
            if(controls.BACK)
            {
                curFreeplayState = TRANSITION;
    
                changeItemSelector();
    
                FlxTween.tween(songCamera, {y: FlxG.height}, 0.7, {ease: FlxEase.quadOut, onComplete: function(_) {
                    songCamera.visible = false;
                    curFreeplayState = SELECTOR;
                }});
    
                FlxTween.cancelTweensOf(bg);
                FlxTween.tween(bgCamera, {zoom: 1}, 0.7, {ease: FlxEase.quadOut});
                FlxTween.color(bg, 0.7, bg.color, 0xFFFDE871, {ease: FlxEase.quadOut});
    
                selectorCamera.alpha = 0;
                selectorCamera.visible = true;
                FlxTween.tween(selectorCamera, {alpha: 1}, 0.7, {ease: FlxEase.quadIn});
            }
        }
    }

    function changeItemSong(huh:Int = 0):Void
	{
        if(huh != 0)
            FlxG.sound.play(Paths.sound('scrollMenu'));

        curSelectionSong += huh;

        if (curSelectionSong >= filteredSongs.length)
			curSelectionSong = 0;
		if (curSelectionSong < 0)
			curSelectionSong = filteredSongs.length - 1;

        var curSong:SongMetadata = filteredSongs[curSelectionSong];

        if(huh != 0)
        {
            FlxTween.cancelTweensOf(bg);
            FlxTween.color(bg, 1, bg.color, curSong.color);
        }

        var animToPlay:String = curSong.songCharacter;

        if(!oppIcon.animation.exists(animToPlay))
            animToPlay = 'haxeflixel';

        if(oppIcon.animation.curAnim?.name != animToPlay)
        {
            oppIcon.animation.play(animToPlay, true);

            oppIcon.updateHitbox();

            oppIcon.setPosition(10 + (220 - oppIcon.width) / 2, 10 + (219 - oppIcon.width) / 2);
        }

        wipText.text = curSong.songName;
        wipText.screenCenter(Y);
	}

    public static function destroyFreeplayVocals():Void
    {
        // do a thing
    }
}

enum CurFreeplayState
{
    SELECTOR;
    SONG;
    TRANSITION;
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var volume:String = "";
	public var lastDifficulty:String = null;
    public var locked:Bool = false;
    public var album:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int, volume:String, locked:Bool, album:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
        this.locked = locked;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
		this.volume = volume;
		if(this.volume == null) this.volume = 'volume1';
        this.album = album;
        if(this.album == null) this.album = 'part1';
	}
}