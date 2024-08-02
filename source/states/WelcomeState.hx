package states;

import flixel.addons.transition.FlxTransitionableState;
import objects.VideoSprite;

class WelcomeState extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var isWhatYoutuber(get, never):YouTuberSelection;

	var bg:FlxSprite;
	var displayText:FlxText;

	override public function create():Void
	{
		super.create();

		bg = new FlxSprite();
		add(bg);

		displayText = new FlxText(0, 0, FlxG.width/2, '', 35);
		displayText.setFormat(Paths.font('DigitalDisco.ttf'), 35);
		add(displayText);

		changeText();
	}

	#if debug
	static var stage:Int = 0;
	#end
	override public function update(elapsed:Float):Void
	{
		if(!leftState)
		{
			if (controls.ACCEPT)
			{
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(bg, {y: bg.y + 1000, x: bg.x + 30, angle: bg.angle + 5}, 2.5, {ease: FlxEase.backIn});
				FlxTween.tween(displayText, {y: displayText.y + 1000, x: displayText.x - 30, angle: displayText.angle - 5}, 3, { ease: FlxEase.backIn,
					onComplete: function (twn:FlxTween) {
						FlxG.save.data.sawWelcomeState = true;
						MusicBeatState.switchState(new TitleState());
					}
				});
			}
			#if debug
			else if(controls.RESET)
			{
				stage++;
				if(stage == 3)
					stage = 0;

				changeText();
			}
			#end
		}

		super.update(elapsed);
	}

	function changeText():Void
	{
		displayText.text = switch(isWhatYoutuber)
		{
			case COMMUNITYGAME:
				"Hey CommunityGame, thanks for playing this mod!\n" +
				"Before the mod starts...\n" +
				"I'll just be letting you know, please do NOT add your own skins.\n" +
				"We worked hard and don't want another \"problem\" like we had before.\n" +
				"Please and thank you.\n\n" +
				"From .json, the owner.\n\n\n" +
				"Anyways,\n\n" +
				"Smash that ENTER to play.";

			case SABER:
				"Thank you for downloading the demo for Sunday Night Chillin'\n\n" +
				"This mod took longer than expected but here is the demo!\n\n\n" +
				"Also, hi chat!\n" +
				"Anyways, I'm not gonna waste more time...\n" +
				"So Hit ENTER to play!";

			default:
				"Thank you for downloading the demo for Sunday Night Chillin'\n\n" +
				"This mod took longer than expected but here is the demo!\n\n\n" +
				"Anyways, I'm not gonna waste more time...\n\n" +
				"Hit ENTER to play!";
		}

		displayText.updateHitbox();
		displayText.screenCenter(Y);
		displayText.x = FlxG.width - displayText.width - 10;

		bg.loadGraphic(Paths.image(isWhatYoutuber == COMMUNITYGAME ? 'welcome/community' : 'welcome/thx'));
		bg.screenCenter(Y);
	}

	private static function get_isWhatYoutuber():YouTuberSelection
	{
		#if sys
		#if debug
		return stage;
		#else
		return switch(Sys.environment()["COMPUTERNAME"])
		{
			case 'DESKTOP-01HC5LO':
				COMMUNITYGAME;
			case 'LAPTOP-UHQMMRV6':
				SABER;
			default:
				NONE;
		}
		#end
		#else
		return NONE;
		#end
	}
}


enum abstract YouTuberSelection(Int) from Int
{
	var NONE = 0;
	var COMMUNITYGAME = 1;
	var SABER = 2;
}