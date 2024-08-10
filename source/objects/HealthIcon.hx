package objects;

import haxe.Json;

typedef HealthFile =
{
	var colors:Array<Int>;
	var antialiasing:Bool;

	@:optional var editor_isPlayer:Null<Bool>;
}

class HealthIcon extends FlxSprite
{
	public var healthFile:HealthFile;

	public var sprTracker:FlxSprite;
	public var sprOffsetX:Float = 12;
	public var sprOffsetY:Float = -30;

	var isOldIcon:Bool = false;
	var isPlayer:Bool = false;
	var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + sprOffsetX, sprTracker.y + sprOffsetY);
	}

	public function switchOldIcon(currentChar:String):Void
	{
		isOldIcon = !isOldIcon;
		changeIcon(isOldIcon ? 'bf-old' : currentChar);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/face';

			#if MODS_ALLOWED
			healthFile = cast Json.parse(File.getContent(Paths.getSharedPath('images/$name.json')));
			#else
			healthFile = cast Json.parse(Assets.getText(Paths.getSharedPath('images/$name.json')));
			#end

			var graphic = Paths.image(name, allowGPU);
			loadGraphic(graphic, true, Math.floor(graphic.width / 2), Math.floor(graphic.height));
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (height - 150) / 2;
			updateHitbox();

			animation.add(char, [0, 1], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			antialiasing = (ClientPrefs.data.antialiasing) ? healthFile.antialiasing : false;
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
