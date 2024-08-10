package states.editors;

import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.ui.FlxButton;
import objects.Bar;
import objects.HealthIcon;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

class HealthIconEditorState extends MusicBeatState
{
    var healthBar:Bar;
    var healthTxt:FlxText;
    var icon:HealthIcon;

    var isPlayer(default, set):Bool;

    var health:Float = 1;
    var healthLerp(default, set):Float = 1;

    override function create():Void
    {
        addBG();
        addHealthbar();
        addEditorBox();
        addControlText();

        FlxG.mouse.visible = true;

        super.create();
    }

    function addBG():Void
    {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set();
		bg.color = 0xFF353535;
		add(bg);

        if (TitleState.titleJSON.checkerData.enabled)
		{
			var checkeredBG:Checkers = new Checkers({
				size: TitleState.titleJSON.checkerData.size,
				colors: [0x33FFFFFF, 0x0],
				speed: TitleState.titleJSON.checkerData.speed,
				alpha: 1
			});
			add(checkeredBG);
		}
    }

    function addHealthbar():Void
    {
        healthBar = new Bar(0, 0, 'healthBar', function() return healthLerp, 0, 2);
        healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
        healthBar.screenCenter();
		add(healthBar);

        healthTxt = new FlxText(0, healthBar.y + 40, FlxG.width, '', 20);
        healthTxt.setFormat(PlayState.textFont, 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		healthTxt.scrollFactor.set();
		healthTxt.borderSize = 1.25;
		add(healthTxt);

        loadIcon('face');
    }

    var ui_box:FlxUITabMenu;
    var blockPressWhileTypingOn:Array<FlxUIInputText> = [];

    function addEditorBox():Void
    {
        var tabs:Array<{name:String, label:String}> = [
			{
                name: 'Colors',
                label: 'Colors'
            },
            {
                name: 'Data',
                label: 'Data'
            }
		];

		ui_box = new FlxUITabMenu(null, tabs, true);
		ui_box.resize(300, 300);
		ui_box.x = FlxG.width - ui_box.width - 5;
		ui_box.y = 5;
		ui_box.scrollFactor.set();

		addDataUI();
        addColorsUI();

		ui_box.selected_tab_id = 'Data';
		add(ui_box);
    }

    var iconInputText:FlxUIInputText;
    var antialiasingCheckbox:FlxUICheckBox;
    var playerCheckbox:FlxUICheckBox;

    function addDataUI():Void
    {
        var tab_group:FlxUI = new FlxUI(null, ui_box);
        tab_group.name = "Data";

        iconInputText = new FlxUIInputText(10, 30, 100, 'face', 8);
        blockPressWhileTypingOn.push(iconInputText);

        antialiasingCheckbox = new FlxUICheckBox((iconInputText.x + iconInputText.width) + 5, iconInputText.y, null, null, "Antialiasing", 75);
		antialiasingCheckbox.checked = icon.healthFile.antialiasing;
		antialiasingCheckbox.callback = function() {
			icon.healthFile.antialiasing = !icon.healthFile.antialiasing;
            icon.antialiasing = icon.healthFile.antialiasing;
		};

        playerCheckbox = new FlxUICheckBox((antialiasingCheckbox.x + antialiasingCheckbox.width) + 5, antialiasingCheckbox.y, null, null, "Is Player", 75);
		playerCheckbox.checked = icon.healthFile.editor_isPlayer;
		playerCheckbox.callback = function() {
            isPlayer = !isPlayer;
            icon.healthFile.editor_isPlayer = isPlayer;
            reloadHealthBarColors();
		};

        var reloadIcon:FlxButton = new FlxButton(iconInputText.x, (iconInputText.y + iconInputText.height) + 5, "Reload Icon", function()
		{
            loadIcon(iconInputText.text);
		});

        var saveIcon:FlxButton = new FlxButton((reloadIcon.x + reloadIcon.width) + 5, reloadIcon.y, "Save Icon", function()
		{
            saveIcon();
		});

        tab_group.add(new FlxText(iconInputText.x, iconInputText.y - 18, 0, 'Icon:'));

        tab_group.add(iconInputText);
        tab_group.add(reloadIcon);
        tab_group.add(antialiasingCheckbox);
        tab_group.add(playerCheckbox);
        tab_group.add(saveIcon);

        ui_box.addGroup(tab_group);
    }

    var healthColorStepperR:FlxUINumericStepper;
    var healthColorStepperG:FlxUINumericStepper;
    var healthColorStepperB:FlxUINumericStepper;

    function addColorsUI():Void
    {
        var tab_group:FlxUI = new FlxUI(null, ui_box);
        tab_group.name = "Colors";

        healthColorStepperR = new FlxUINumericStepper(10, 30, 20, icon.healthFile.colors[0], 0, 255, 0);
        healthColorStepperG = new FlxUINumericStepper((healthColorStepperR.x + healthColorStepperR.width) + 5, healthColorStepperR.y, 20, icon.healthFile.colors[1], 0, 255, 0);
        healthColorStepperB = new FlxUINumericStepper((healthColorStepperG.x + healthColorStepperG.width) + 5, healthColorStepperR.y, 20, icon.healthFile.colors[2], 0, 255, 0);

        var decideIconColor:FlxButton = new FlxButton(healthColorStepperR.x, (healthColorStepperR.y + healthColorStepperR.height) + 5, "Get Icon Color", function()
		{
			var determinedHealthColor:FlxColor = FlxColor.fromInt(CoolUtil.dominantColor(icon));
			healthColorStepperR.value = icon.healthFile.colors[0] = determinedHealthColor.red;
			healthColorStepperG.value = icon.healthFile.colors[1] = determinedHealthColor.green;
			healthColorStepperB.value = icon.healthFile.colors[2] = determinedHealthColor.blue;
            reloadHealthBarColors();
		});

        var reloadHealthbar:FlxButton = new FlxButton((decideIconColor.x + decideIconColor.width) + 5, decideIconColor.y, "Reload Bar", function()
		{
            reloadHealthBarColors();
		});

        tab_group.add(healthColorStepperR);
        tab_group.add(healthColorStepperG);
        tab_group.add(healthColorStepperB);
        tab_group.add(decideIconColor);
        tab_group.add(reloadHealthbar);

        ui_box.addGroup(tab_group);
    }

    var _file:FileReference = null;

    function saveIcon():Void
    {
		var data:String = haxe.Json.stringify(icon.healthFile, "\t");

		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, icon.getCharacter() + ".json");
		}
	}

	function onSaveComplete(listener:Event):Void
	{
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	function onSaveCancel(listener:Event):Void
	{
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(listener:Event):Void
	{
		_file.removeEventListener(#if desktop Event.SELECT #else Event.COMPLETE #end, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}

    var controlText:FlxText;

    function addControlText():Void
    {
        controlText = new FlxText(5, 0, FlxG.width / 4, '', 20);
        controlText.text = 'CONTROLS:\n[ - ${(isPlayer) ? 'Add' : 'Remove'} Health\n] - ${(isPlayer) ? 'Remove' : 'Add'} Health';
        controlText.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        controlText.y = (FlxG.height - controlText.height) - 5;
        add(controlText);
    }

    override public function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
    {
        super.getEvent(id, sender, data, params);

        if (sender is FlxUINumericStepper)
        {
            // switch (sender) doesn't work on this bullshit.
            if (sender == healthColorStepperR)
                icon.healthFile.colors[0] = Math.round(healthColorStepperR.value);
            else if (sender == healthColorStepperG)
                icon.healthFile.colors[1] = Math.round(healthColorStepperG.value);
            else if (sender == healthColorStepperB)
                icon.healthFile.colors[2] = Math.round(healthColorStepperB.value);
        }
    }

    var holdTime:Float = 0;

    override public function update(elapsed:Float):Void
    {
        if (healthBar != null)
        {
            if (healthBar.bounds.max != null && health > healthBar.bounds.max)
                health = healthBar.bounds.max;

            if (healthBar.bounds.min != null && health < healthBar.bounds.min)
                health = healthBar.bounds.min;
        }

        healthLerp = FlxMath.lerp(healthLerp, health, 0.15);

        var blockInput:Bool = false;

		for (inputText in blockPressWhileTypingOn)
        {
			if(inputText.hasFocus)
            {
				ClientPrefs.toggleVolumeKeys(false);
				blockInput = true;

                if(FlxG.keys.justPressed.ENTER)
                    inputText.hasFocus = false;

				break;
			}
		}

        if (!blockInput)
        {
            if (FlxG.keys.pressed.LBRACKET || FlxG.keys.pressed.RBRACKET)
            {
                holdTime += elapsed;

                if ((FlxG.keys.justPressed.LBRACKET || FlxG.keys.justPressed.RBRACKET) || holdTime > 0.5)
                {
                    if (FlxG.keys.pressed.LBRACKET)
                        health += 0.023;

                    if (FlxG.keys.pressed.RBRACKET)
                        health -= 0.0475;
                }
            }

            if (FlxG.keys.justReleased.LBRACKET || FlxG.keys.justReleased.RBRACKET)
                holdTime = 0;

            if (FlxG.keys.justPressed.ESCAPE)
            {
                MusicBeatState.switchState(new states.editors.MasterEditorMenu());
                FlxG.sound.playMusic(Paths.music('sncTitle'));
            }
        }

        super.update(elapsed);
    }

    function loadIcon(iconName:String):Void
    {
        if (icon == null)
        {
            icon = new HealthIcon(iconName, false, true);
            icon.y = healthBar.y - 75;
            add(icon);
        }
        else
        {
            icon.changeIcon(iconName);
        }

        #if DISCORD_ALLOWED
		DiscordClient.changePresence("Health Icon Editor", icon.getCharacter());
		#end

        if (icon.healthFile.editor_isPlayer == null)
            icon.healthFile.editor_isPlayer = false;

        isPlayer = icon.healthFile.editor_isPlayer;

        if (antialiasingCheckbox != null)
            antialiasingCheckbox.checked = icon.healthFile.antialiasing;

        if (playerCheckbox != null)
            playerCheckbox.checked = icon.healthFile.editor_isPlayer;

        if (healthColorStepperR != null)
            healthColorStepperR.value = icon.healthFile.colors[0];

        if (healthColorStepperG != null)
            healthColorStepperG.value = icon.healthFile.colors[1];

        if (healthColorStepperB != null)
            healthColorStepperB.value = icon.healthFile.colors[2];

        reloadHealthBarColors();
    }

    inline function reloadHealthBarColors():Void
    {
		healthBar.setColors(grabLeftColors(), grabRightColors());
	}

    function grabLeftColors():FlxColor
    {
        if (isPlayer)
            return FlxColor.RED;

        return FlxColor.fromRGB(icon.healthFile.colors[0], icon.healthFile.colors[1], icon.healthFile.colors[2]);
    }

    function grabRightColors():FlxColor
    {
        if (!isPlayer)
            return FlxColor.LIME;

        return FlxColor.fromRGB(icon.healthFile.colors[0], icon.healthFile.colors[1], icon.healthFile.colors[2]);
    }

    function set_isPlayer(value:Bool):Bool
    {
        isPlayer = value;

        if (icon != null)
        {
            if (healthBar != null)
                reloadHealthBarColors();

            icon.animation.curAnim.flipX = isPlayer;
            icon.animation.play(icon.getCharacter());
        }

        if (controlText != null)
            controlText.text = 'CONTROLS:\n[ - ${(isPlayer) ? 'Add' : 'Remove'} Health\n] - ${(isPlayer) ? 'Remove' : 'Add'} Health';

        return isPlayer;
    }

    function set_healthLerp(value:Float):Float
    {
        healthLerp = value;

        if (healthBar != null)
        {
            var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
            healthBar.percent = (newPercent != null ? newPercent : 0);

            if (icon != null)
            {
                if (isPlayer)
                    icon.x = healthBar.barCenter + (150 * icon.scale.x - 150) / 2 - 26;
                else
                    icon.x = healthBar.barCenter - (150 * icon.scale.x) / 2 - 26 * 2;

                icon.animation.curAnim.curFrame = (isPlayer && healthBar.percent < 20 || !isPlayer && healthBar.percent > 80) ? 1 : 0;
            }
        }

        if (healthTxt != null)
            healthTxt.text = 'Health: ${FlxMath.roundDecimal((isPlayer) ? healthLerp * 50 : (healthBar.bounds.max * 50) - (healthLerp * 50), 2)}%';

        return healthLerp;
    }
}