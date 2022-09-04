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

	var optionDetails:FlxText;

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

		optionDetails = new FlxText(0, 0, FlxG.width, "");
		optionDetails.setFormat("PhantomMuff 1.5", 32, 0xFF000000, "center");
		optionDetails.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFFFFFFFF, 2, 1);
		optionDetails.scrollFactor.set();
		add(optionDetails);

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

		switch (optionsGroup.members[curSelected].text.toLowerCase().substr(0, optionsGroup.members[curSelected].text.toLowerCase().indexOf(" ", 0))){
			case 'ghost-tapping':
				optionDetails.text = "Disables missing for when you don't hit a note";
			case 'downscroll':
				optionDetails.text = "Puts the Strumline at the bottom";
			case 'middlescroll':
				optionDetails.text = "Centers the Strumline";
			case 'hurtful':
				optionDetails.text = "If the Note Rating is below \"Sick\" you will loose health"; // look i had trouble thinking of a good option name, take it or leave it.
			case 'classic':
				optionDetails.text = "Use the original FNFSL Rating System (Easier, Not Recommended)";
			case 'botplay':
				optionDetails.text = "Plays the game for you";
			case 'allow': //allow modding
				optionDetails.text = "Toggle Mods";
			case 'lane-underlay':
				optionDetails.text = "Puts a underlay on the Strumline";
			case 'distractions':
				optionDetails.text = "Toggle Distractions";
			case 'epilepsy':
				optionDetails.text = "Disables most flashing lights";
			case 'show':
				optionDetails.text = "Show the Outdated Screen";
			default:
				optionDetails.text = "";
		}
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
					'Hurtful Ratings ${FlxG.save.data.advanceJudement ? 'ON' : 'OFF'}',
					'Classic Rating System ${FlxG.save.data.useClassicRating ? 'ON' : 'OFF'}',
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
					'Show Outdated Screen ${FlxG.save.data.disableOutdatedScreen ? 'OFF' : 'ON'}'
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
					case 'hurtful':
						FlxG.save.data.advanceJudement = !FlxG.save.data.advanceJudement;
					case 'classic':
						FlxG.save.data.useClassicRating = !FlxG.save.data.useClassicRating;
					// graphics
					case 'lane-underlay':
						FlxG.save.data.laneUnderlay = !FlxG.save.data.laneUnderlay;
					case 'distractions':
						FlxG.save.data.noDistractions = !FlxG.save.data.noDistractions;
					case 'epilepsy':
						FlxG.save.data.epilepsyMode = !FlxG.save.data.epilepsyMode;
					case 'show': // show outdated screen
						FlxG.save.data.disableOutdatedScreen = !FlxG.save.data.disableOutdatedScreen;
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
