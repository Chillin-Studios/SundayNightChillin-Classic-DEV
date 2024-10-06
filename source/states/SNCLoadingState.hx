package states;

import backend.StageData;
import sys.thread.Thread;
import flixel.math.FlxRect;
import haxe.Json;
import openfl.utils.Assets;
import backend.WeekData;
import backend.Song;
import objects.NoteSplash;
import objects.Note;
import backend.Highscore;

/**
 * Handles all of the loading done by the engine.
 * This is a rewrite of Psych 1.0 LoadingState.
 * TODO: LOAD SOUNDS.
 * @author TechnikTil
 */
class SNCLoadingState extends MusicBeatState
{
    /**
     * Loads an instance of PlayState.
     * @param song The song ID you want to load. Keep `null` to not load any charts.
     * @param difficulty The difficulty for that song. Keep `null` to not load any charts.
     */
    public static function loadPlayState(?song:String, ?difficulty:Int):Void
    {
        var loadingState:SNCLoadingState = new SNCLoadingState();
        loadingState.finishState = new PlayState();

        if(song != null && difficulty != null)
        {
            loadingState.priorityLoading.push(0); // Charts, they are very important

            loadingState.loadingFunctions.push(function(progress:Float->Void) {
                var songLowercase:String = Paths.formatToSongPath(song);
                var poop:String = Highscore.formatSong(song, difficulty);

                PlayState.SONG = Song.loadFromJson(poop, songLowercase);
                PlayState.storyDifficulty = difficulty;

                progress(1);
                trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
            });
        }

        loadingState.loadingFunctions.push(function(progress:Float->Void) {
            var directory:String = 'shared';
            var weekDir:String = StageData.forceNextDirectory;
            StageData.forceNextDirectory = null;

            if(weekDir != null && weekDir.length > 0 && weekDir != '') directory = weekDir;

            Paths.setCurrentLevel(directory);
            trace('Setting ZE FUCKING asset folder to ' + directory);

        });

        // NOTE ASSETS
        loadingState.loadingFunctions.push(function(progress:Float->Void) {
            // NOTE IMAGE
            var noteSkin:String = Note.defaultNoteSkin;
			if(PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) noteSkin = PlayState.SONG.arrowSkin;
            
            var customSkin:String = noteSkin + Note.getNoteSkinPostfix();
			if(Paths.fileExists('images/$customSkin.png', IMAGE)) noteSkin = customSkin;
			Paths.image(noteSkin);
            progress(0.5);

            var noteSplash:String = NoteSplash.defaultNoteSplash;
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) noteSplash = PlayState.SONG.splashSkin;
			else noteSplash += NoteSplash.getSplashSkinPostfix();
            Paths.image(noteSkin);
            progress(1);
        });

		loadingState.loadingFunctions.push(function(progress:Float->Void) {
            Sys.sleep(4);
            progress(1);
        });

        MusicBeatState.switchState(loadingState);
    }

	/**
     * The indexes to prioritize in `loadingFunctions`.
     * These will also temporarily stun any queued functions from running.
     */
    public var priorityLoading:Array<Int> = [];
    /**
     * Every loading function needed for this `instance` to do its job.
     * It works by calling the function in a thread, and finishing when `progress` updates to 100% of progress.
     * @param progress Updates the percentage of completion. 0-1 = 0%-100%
     */
    public var loadingFunctions:Array<(progress:Float->Void)->Void> = [];

    /**
     * The `MusicBeatState` `instance` to load when this is finished.
     */
    public var finishState:MusicBeatState;

    /**
     * The clipped loading bar to "simulate" a filled bar.
     */
    private var loadingBarClipped:FlxSprite;

    override public function create():Void
    {
        super.create();

        var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xffcaff4d);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

        var loadingPeople:FlxSprite = new FlxSprite();
        loadingPeople.antialiasing = ClientPrefs.data.antialiasing;
        loadRandomScreen(loadingPeople);
        add(loadingPeople);

        var loadingBar:FlxSprite = new FlxSprite(19, 491).loadGraphic(Paths.image('loading/bar'));
        loadingBar.antialiasing = ClientPrefs.data.antialiasing;
        add(loadingBar);

        loadingBarClipped = new FlxSprite(19, 491).loadGraphic(Paths.image('loading/bar'));
        loadingBarClipped.clipRect = new FlxRect(0, 0, 0, loadingBar.height);
        loadingBarClipped.antialiasing = ClientPrefs.data.antialiasing;
        add(loadingBarClipped);

        var loadText:FlxSprite = new FlxSprite(885, 423).loadGraphic(Paths.image('loading/load'));
        loadText.antialiasing = ClientPrefs.data.antialiasing;
        add(loadText);

        loadThingsPLEASE();
    }

    public function loadThingsPLEASE():Void
    {
        var funcProgresses:Array<Float> = [];
        var toLoad = loadingFunctions.copy();
        for(i=>func in toLoad)
        {
            funcProgresses[i] = 0;

            var progressFunc = function(?percentage:Float = 1) {
                funcProgresses[i] = percentage;
                updateProgresses(funcProgresses);
            };

            /*#if sys
            if(!priorityLoading.contains(i))
                Thread.create(func.bind(progressFunc));
            else
            #end*/
            func(progressFunc);
        }
    }

    private function updateProgresses(funcProgresses:Array<Float>):Void
    {
        var total:Float = 0;
        for(i in funcProgresses)
            total += i;

        total /= funcProgresses.length;

        trace('NEW PROGRESS! $total');

        loadingBarClipped.clipRect.width = loadingBarClipped.width * total;

        if(total >= 1)
            MusicBeatState.switchState(finishState);
    }

    // TODO: add logic
    public function loadRandomScreen(spr:FlxSprite):Void
    {
        spr.loadGraphic(Paths.image('loading/screen/cartre'));
    }
}