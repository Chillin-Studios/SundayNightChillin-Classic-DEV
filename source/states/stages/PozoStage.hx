package states.stages;

import states.stages.objects.*;
import objects.Character;
import objects.Note;

class PozoStage extends BaseStage
{
	var leftBoppers:BGSprite;
	var rightBoppers:BGSprite;
	var ppno:BGSprite;
	var phoen:BGSprite;

	var deezNeets:Character;

	override function create():Void
	{
		var sky:BGSprite = new BGSprite('sky', -FlxG.width, -FlxG.height, 0, 0);
		add(sky);

		var sun:BGSprite = new BGSprite('thesun', -90, -200, 0.1, 0.1, ['sunnyfunny'], true);
		add(sun);

		var city:BGSprite = new BGSprite('city', -100, 0, 0.6, 0.9);
		add(city);

		var hills:BGSprite = new BGSprite('hills', 0, -100, 0.8, 0.8);
		add(hills);

		var grass:BGSprite = new BGSprite('grass', 0, 0, 1, 1);
		add(grass);

		leftBoppers = new BGSprite('bgboppers_LEFT', 164, 549, 1, 1, ['left boppers']);
		add(leftBoppers);

		rightBoppers = new BGSprite('bgbopper_RIGHT', 2132, 581, 1, 1, ['right boppers']);
		add(rightBoppers);
	}

	override function createPost():Void
	{
		if(true)
		{
			deezNeets = new Character(dadGroup.x + 317, dadGroup.y, 'dees');
			game.startCharacterPos(deezNeets);
			add(deezNeets);
		}

		ppno = new BGSprite('fgbopper1', 280, 250, 1.5, 0.1, ['peppinobopper']);
		ppno.setGraphicSize(Std.int(ppno.width * 0.7));
		add(ppno);

		phoen = new BGSprite('fgbopper2', 2770, 410, 1.5, 0.1, ['thisguybopper']);
		phoen.setGraphicSize(Std.int(phoen.width * 0.7));
		add(phoen);
	}

	override function beatHit():Void
	{
		for(i in [leftBoppers, rightBoppers, ppno, phoen])
		{
			if(i.animation.finished)
				i.dance();
		}

		if (deezNeets != null && curBeat % deezNeets.danceEveryNumBeats == 0 && !deezNeets.getAnimationName().startsWith('sing') && !deezNeets.stunned)
			deezNeets.dance();
	}
	
	override function opponentNoteHit(note:Note):Void
	{
		if(note.noteType == 'Second Character Note' && deezNeets != null)
		{
			var animToPlay:String = game.singAnimations[Std.int(Math.abs(Math.min(game.singAnimations.length-1, note.noteData)))];

			deezNeets.playAnim(animToPlay, true);
			deezNeets.holdTimer = 0;
		}
	}
}