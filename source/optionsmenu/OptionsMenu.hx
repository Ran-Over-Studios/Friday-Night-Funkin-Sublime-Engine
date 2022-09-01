package optionsmenu;

import Controls.Action;
import cpp.abi.Abi;
import haxe.ds.Option;
import openfl.system.System;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxSubState;
import optionsmenu.TextOption;

using StringTools;

class OptionsMenu extends MusicBeatState {
	var funnyOption:TextOption;
	var background:FlxSprite;
	var camFollow:FlxSprite;

	var curSelected:Int = 0;
	var curMenu:String = '';
	
	var optionsGroup:FlxTypedGroup<TextOption>;

	override function create() {
		background = new FlxSprite(0, 0, Paths.image('menuBGBlue'));
		background.scrollFactor.x = 0;
		background.scrollFactor.y = 0;
		background.updateHitbox();
		background.screenCenter();
		background.antialiasing = true;
		add(background);

		optionsGroup = new FlxTypedGroup<TextOption>();

		generateOptions();

		add(optionsGroup);

		camFollow = new FlxSprite(0, 0).makeGraphic(Std.int(optionsGroup.members[0].width), Std.int(optionsGroup.members[0].height), 0xAAFF0000);
		camFollow.y = optionsGroup.members[0].y;
		FlxG.camera.follow(camFollow, null, 0.06);

		super.create();
	}

	override function update(elapsed:Float) {
		if (optionsGroup.members[curSelected] != null){
			camFollow.y = optionsGroup.members[curSelected].y;
		}

		for (option in optionsGroup){
			if (option != null){
				if (optionsGroup.members[curSelected] != option)
					option.alpha = 0.6;
				else
					option.alpha = 1;
			}
		}

		if (controls.DOWN_P && curSelected < optionsGroup.members.length - 1 || controls.UP_P && curSelected > 0)
			FlxG.sound.play(Paths.sound('scrollMenu', 'preload'));

		if (controls.DOWN_P && curSelected < optionsGroup.members.length - 1)
			curSelected++;
		if (controls.UP_P && curSelected > 0)
			curSelected--;
		if (controls.ACCEPT)
			optionSelected();
		if (controls.BACK){
			curSelected = 0;

			if (curMenu != 'default')
				generateOptions();
			else
				FlxG.switchState(new MainMenuState());

			FlxG.sound.play(Paths.sound('cancelMenu', 'preload'));
		}

		#if desktop
		if (FlxG.save.data.allowMods == null)
			FlxG.save.data.allowMods = true;
		#end
	}

	function generateOptions(theOptionGroup:String = null){
		var optionArray:Array<String> = [];
		var optionSelectionProperties:Array<Int> = []; // 0 - on/off | 1 - New Menu | 2 - Switch State

		for (option in optionsGroup){
			if (option != null){
				option.destroy();
			}
		}

		optionsGroup.clear();

		switch (theOptionGroup.toLowerCase()){
			default:
				optionArray = [
					'Gameplay',
					'Graphics',
					'Modding'
				];

				optionSelectionProperties = [1, 1, 2];
				curMenu = 'default';
			case 'gameplay':
				optionArray = [
					"Keybinds",
					'Ghost-tapping ${FlxG.save.data.ghostTap ? 'ON' : 'OFF'}',
					'Downscroll ${FlxG.save.data.downScroll ? 'ON' : 'OFF'}',
					'Middlescroll ${FlxG.save.data.middleScroll ? 'ON' : 'OFF'}',
					'Botplay ${FlxG.save.data.botplay ? 'ON' : 'OFF'}',
					'Allow Modding ${FlxG.save.data.allowMods ? 'ON' : 'OFF'}'
				];

				optionSelectionProperties = [2, 0, 0, 0, 0, 0];
				curMenu = 'gameplay';
			case 'graphics':
				optionArray = [
				    'Lane-Underlay ${FlxG.save.data.laneUnderlay ? 'ON' : 'OFF'}',
				    'Distractions ${FlxG.save.data.noDistractions ? 'OFF' : 'ON'}',
				    'Epilepsy Mode ${FlxG.save.data.epilepsyMode ? 'ON' : 'OFF'}',
					'Show Outdated Screen ${FlxG.save.data.showOutdatedScreen ? 'ON' : 'OFF'}'
				];

				optionSelectionProperties = [0, 0, 0, 0];
				curMenu = 'graphics';
		}

		for (num in 0...optionArray.length){
			funnyOption = new TextOption(0, 0, optionArray[num], optionSelectionProperties[num]);
			funnyOption.screenCenter(Y);
			funnyOption.y = 78 * num;
			optionsGroup.add(funnyOption);
		}
	}

	function optionSelected(){
		trace('option type: ' + optionsGroup.members[curSelected].funnyOptionType + ' option text: '+ optionsGroup.members[curSelected].text);

		switch (optionsGroup.members[curSelected].funnyOptionType){ // messy but in my opinion it works better than the old system
			case 0:
				switch(optionsGroup.members[curSelected].text.toLowerCase().substr(0, optionsGroup.members[curSelected].text.toLowerCase().indexOf(" ", 0))){
					// gameplay
					case 'ghost-tapping':
						FlxG.save.data.ghostTap = !FlxG.save.data.ghostTap;
					case 'downscroll':
						FlxG.save.data.downScroll = !FlxG.save.data.downScroll;
					case 'middlescroll':
						FlxG.save.data.middleScroll = !FlxG.save.data.middleScroll;
					case 'botplay':
						FlxG.save.data.botplay = !FlxG.save.data.botplay;
					case 'allow': // allow modding
						FlxG.save.data.allowMods = !FlxG.save.data.allowMods;
					// graphics
					case 'lane-underlay':
						FlxG.save.data.laneUnderlay = !FlxG.save.data.laneUnderlay;
					case 'distractions':
						FlxG.save.data.noDistractions = !FlxG.save.data.noDistractions;
					case 'epilepsy':
						FlxG.save.data.epilepsyMode = !FlxG.save.data.epilepsyMode;
					case 'show': // show outdated screen
						FlxG.save.data.showOutdatedScreen = !FlxG.save.data.showOutdatedScreen;
				}

				generateOptions(curMenu); //reload the current menu
			case 1:
				generateOptions(optionsGroup.members[curSelected].text.toLowerCase());
				curSelected = 0;
			case 2:
				switch(optionsGroup.members[curSelected].text.toLowerCase()){
					case 'keybinds':
						FlxG.switchState(new KeybindsState());
					case 'modding':
						if (SLModding.isInitialized)
							FlxG.switchState(new ModsMenu());
						else 
							FlxG.sound.play(Paths.sound('badnoise3', 'shared'));
				}
			default:
				trace('error lmao');
		}
	}
}
