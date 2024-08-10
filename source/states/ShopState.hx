package states;

import flixel.group.FlxGroup;
import objects.ChillinCursor;

class ShopState extends MusicBeatState
{
	var bg:FlxSprite;
	var wipText:FlxText;

	/**
	 * Whether the user is shopping rn. If they are in this state then they probably are.
	 *
	 * TODO: Make them give us their credit card information
	 */
	var isShopping:Bool = false;

	//
	// --OBJECTS SHIT-- \\
	//

	static inline final imageAssetsPath:String = 'shop';

	var jb:FlxSprite;
	var box:FlxSprite;
	var boombox:FlxSprite;
	var cat:FlxSprite;

	var stage:FlxGroup;

	//
	// --SONG SHIT-- \\
	//

	static inline final songAssetsPath:String = 'shop';

	final songAssetNames:Array<String> = ['idle', 'shopping'];

	/**
	 * The current song to play when playMusic() is called.
	 */
	var curSongState:String = 'idle';

	//
	// -- CURSOR SHIT -- \\
	//

	var shopCursor:ChillinCursor;

	//
	// -- CAMERAS -- \\
	//

	/**
	 * This is the main camera.
	 */
	var shopCam:FlxCamera;

	/**
	 * This is a camera specifically made for the cursor.
	 */
	var shopCursorCam:FlxCamera;

	override public function create():Void
	{
		for (sex in songAssetNames)
			Paths.music(songAssetsPath + sex); // preload

		shopCam = initPsychCamera();

		makeStage();
		makeDisclaimer();
		initCursor();
		playMusic();

		super.create();
	}

	function makeStage():Void
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
		add(bg);

		stage = new FlxGroup();
		add(stage);

		jb = new FlxSprite().loadGraphic(Paths.image('$imageAssetsPath/stage/jb'), true, 218, 300);
		jb.animation.add('idle', [0, 1], 5, true, false, false);
		jb.animation.add('talk', [2, 3], 5, false, false, false);
		jb.animation.play('idle', true);
		jb.scale.set(2.2, 2.2);
		jb.updateHitbox();
		jb.screenCenter(X);
		jb.y = (FlxG.height - jb.height) - (23 * jb.scale.y);
		stage.add(jb);

		box = new FlxSprite();
		box.frames = Paths.getSparrowAtlas('$imageAssetsPath/stage/box');
		box.animation.addByPrefix('idle', 'Idle', 0, true, false, false);
		box.animation.play('idle', true);
		box.scale.set(2.2, 2.2);
		box.updateHitbox();
		box.screenCenter(X);
		box.y = (FlxG.height - box.height);
		stage.add(box);

		boombox = new FlxSprite();
		boombox.frames = Paths.getSparrowAtlas('$imageAssetsPath/stage/boombox');
		boombox.animation.addByPrefix('idle', 'Idle', 0, true, false, false);
		boombox.animation.play('idle', true);
		boombox.scale.set(2.2, 2.2);
		boombox.updateHitbox();
		boombox.x = box.x + (155 * boombox.scale.x);
		boombox.y = (FlxG.height - boombox.height) - (81 * boombox.scale.y);
		stage.add(boombox);

		cat = new FlxSprite();
		cat.frames = Paths.getSparrowAtlas('$imageAssetsPath/stage/cat');
		cat.animation.addByPrefix('idle', 'Idle', 0, true, false, false);
		cat.animation.play('idle', true);
		cat.scale.set(2.2, 2.2);
		cat.updateHitbox();
		cat.x = box.x - cat.width;
		cat.y = (FlxG.height - box.height);
		stage.add(cat);
	}

	function makeDisclaimer():Void
	{
		var font:String = (FlxG.random.bool(25)) ? 'SpongeBoB Painting.ttf' : 'vcr.ttf';

		var disclaimer:FlxText = new FlxText(5, 0, 300, "(W.I.P)\nEVERYTHING HERE IS SUBJECT TO CHANGE\nPRESS ACCEPT TO TOGGLE JB TALK + CHANGE MUSIC", 16);
		disclaimer.setFormat(Paths.font(font), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		disclaimer.screenCenter(Y);
		add(disclaimer);
	}

	function initCursor():Void
	{
		shopCursorCam = new FlxCamera();
		shopCursorCam.bgColor.alpha = 0;
		FlxG.cameras.add(shopCursorCam, false);

		shopCursor = new ChillinCursor();
		shopCursor.camera = shopCursorCam;
		add(shopCursor);
	}

	function playMusic():Void
	{
		FlxG.sound.music.stop();
		FlxG.sound.playMusic(Paths.music('$songAssetsPath/$curSongState'), 0.95);
		Conductor.bpm = 106;
	}

	var isExitting:Bool = false;

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		Conductor.songPosition = FlxG.sound.music.time;

		if (isShopping)
			jb.animation.play('talk');
		else
			jb.animation.play('idle');

		if (shopCursor.overlaps(cat))
			shopCursor.switchMouseState(SLEEPING, false);
		else if (!shopCursor.overlaps(cat) && shopCursor.mouseState == SLEEPING)
			shopCursor.switchMouseState(NORMAL, false);

		if(isExitting)
			return;

		if(controls.ACCEPT)
		{
			isShopping = !isShopping;

			curSongState = (isShopping) ? 'shopping' : 'idle';

			playMusic();
		}

		if(controls.BACK)
		{
			isExitting = true;
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('sncTitle'));
		}
	}

	override public function beatHit():Void
	{
		for (bopper in [box, boombox, cat])
		{
			if (bopper != null)
			{
				if (bopper.animation.curAnim.curFrame < bopper.animation.curAnim.numFrames - 1)
					bopper.animation.curAnim.curFrame++;
				else
					bopper.animation.curAnim.curFrame = 0;
			}
		}

		super.beatHit();
	}
}