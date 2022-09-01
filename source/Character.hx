package;

import lime.utils.AssetType;
import openfl.Assets;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var isTxt:Bool = false;
	public var isMod:Bool = false;

	public var useAltIdle:Bool = false;

	var characterArray = [];

	var isLoaded:Bool = false;
	
	// offsets
	var idleOffsetX:Int = 0; var idleOffsetY:Int = 0; var singUPOffsetX:Int = 0; var singUPOffsetY:Int = 0;
	var singRIGHTOffsetX:Int = 0; var singRIGHTOffsetY:Int = 0; var singLEFTOffsetX:Int = 0; var singLEFTOffsetY:Int = 0;
	var singDOWNOffsetX:Int = 0; var singDOWNOffsetY:Int = 0;

	// animation
	var idleAnim:String = ""; var singUPAnim:String = ""; var singRIGHTAnim:String = ""; var singLEFTAnim:String = "";
	var singDOWNAnim:String = "";

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		var pathVar = 'mods/' + SLModding.curLoaded + '/images/characters/' + curCharacter;
		var daPlayer = curCharacter;

		trace('Attempting to load character: ' + curCharacter);

		if (Assets.exists('assets/shared/characters/$daPlayer.txt'))
		{
			characterArray = CoolUtil.coolTextFile(Paths.character(daPlayer));

			tex = Paths.getSparrowAtlas('characters/$daPlayer');
			frames = tex;

			loadCharacterData();
		}
		else if (SLModding.fileExists(pathVar + "/character.txt")){
			var daList:Array<String> = SLModding.getContent(pathVar + "/" + "/character.txt").trim().split('\n');

			tex = FlxAtlasFrames.fromSparrow(SLModding.getBitmap(pathVar + "/" + daPlayer + ".png"), SLModding.getContent(pathVar + "/" + daPlayer + ".xml"));
			frames = tex;
					
			for (i in 0...daList.length){
				daList[i] = daList[i].trim();
			}

			characterArray = daList;

			loadCharacterData();

			isMod = true;
		}

		if (isLoaded){
			isTxt = true;

			animation.addByPrefix("idle", idleAnim, 24, false);
			animation.addByPrefix("singUP", singUPAnim, 24, false);
			animation.addByPrefix("singRIGHT", singRIGHTAnim, 24, false);
			animation.addByPrefix("singLEFT", singLEFTAnim, 24, false);
			animation.addByPrefix("singDOWN", singDOWNAnim, 24, false);

			addOffset('idle', idleOffsetX, idleOffsetY);
			addOffset('singUP', singUPOffsetX, singUPOffsetY);
			addOffset('singRIGHT', singRIGHTOffsetX, singRIGHTOffsetY);
			addOffset('singLEFT', singLEFTOffsetX, singLEFTOffsetY);
			addOffset('singDOWN', singDOWNOffsetX, singDOWNOffsetY);

			playAnim('idle');

			dance();
		}
		else if (!isLoaded){
			trace('Not Loaded, Loading the Hardcoded version of ' + curCharacter);

			switch (curCharacter){
				case 'chart-dad':
					tex = Paths.getSparrowAtlas('characters/dad');
					frames = tex;
					animation.addByPrefix('idle', 'Dad idle dance', 24);
					animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
					animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
					animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
					animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

					setGraphicSize(Std.int(width * 0.6));
	
					addOffset('idle', -10);
					addOffset("singUP", -16, 33);
					addOffset("singRIGHT", -10, 17);
					addOffset("singLEFT", -16, 8);
					addOffset("singDOWN", -10, -17);
	
					playAnim('idle');

				case 'chart-bf':
					var tex = Paths.getSparrowAtlas('characters/bf');
					frames = tex;
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);

					setGraphicSize(Std.int(width * 0.6));
					flipX = true;

					addOffset('idle', -5);
					addOffset("singUP", -30, 18);
					addOffset("singRIGHT", -28, -7);
					addOffset("singLEFT", 1, -5);
					addOffset("singDOWN", -10, -33);

					playAnim('idle');

				case 'gf':
					tex = Paths.getSparrowAtlas('GF_assets');
					frames = tex;
					animation.addByPrefix('cheer', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);
	
					addOffset('cheer');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);
	
					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);
	
					addOffset('scared', -2, -17);
	
					playAnim('danceRight');
				
				case 'spooky':
					tex = Paths.getSparrowAtlas('characters/spooky', 'week2');
					frames = tex;
					animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
					animation.addByPrefix('singLEFT', 'note sing left', 24, false);
					animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
					animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
					animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);
	
					addOffset('danceLeft');
					addOffset('danceRight');
	
					addOffset("singUP", -20, 26);
					addOffset("singRIGHT", -130, -14);
					addOffset("singLEFT", 130, -10);
					addOffset("singDOWN", -50, -130);
	
					playAnim('danceRight');

				case 'gf-car':
					tex = Paths.getSparrowAtlas('characters/gfCar', 'week4');
					frames = tex;
					animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
						false);

					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);

					playAnim('danceRight');

				case 'gf-christmas':
					tex = Paths.getSparrowAtlas('characters/gfChristmas', 'week5');
					frames = tex;
					animation.addByPrefix('cheer', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);
		
					addOffset('cheer');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);
		
					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);
	
					addOffset('scared', -2, -17);
		
					playAnim('danceRight');

				case 'bf-christmas':
					var tex = Paths.getSparrowAtlas('characters/bfChristmas', 'week5');
					frames = tex;
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
		
					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
		
					playAnim('idle');
	
					flipX = true;

				case 'parents-christmas':
					frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets', 'week5');
					animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
					animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
					animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
					animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
					animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);
	
					animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);		
					animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
					animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
					animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);
	
					addOffset('idle');
					addOffset("singUP", -47, 24);
					addOffset("singRIGHT", -1, -23);
					addOffset("singLEFT", -30, 16);
					addOffset("singDOWN", -31, -29);
					addOffset("singUP-alt", -47, 24);
					addOffset("singRIGHT-alt", -1, -24);
					addOffset("singLEFT-alt", -30, 15);
					addOffset("singDOWN-alt", -30, -27);

					playAnim('idle');
				
				case 'monster-christmas':
					tex = Paths.getSparrowAtlas('characters/monsterChristmas', 'week5');
					frames = tex;
					animation.addByPrefix('idle', 'monster idle', 24, false);
					animation.addByPrefix('singUP', 'monster up note', 24, false);
					animation.addByPrefix('singDOWN', 'monster down', 24, false);
					animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
					animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);
		
					addOffset('idle');
					addOffset("singUP", -20, 50);
					addOffset("singRIGHT", -51);
					addOffset("singLEFT", -30);
					addOffset("singDOWN", -40, -94);
					playAnim('idle');

				case 'gf-pixel':
					tex = Paths.getSparrowAtlas('characters/gfPixel', 'week6');
					frames = tex;
					animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
					animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		
					addOffset('danceLeft', 0);
					addOffset('danceRight', 0);
		
					playAnim('danceRight');
		
					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
					antialiasing = false;

				case 'bf-pixel':
					frames = Paths.getSparrowAtlas('characters/bfPixel', 'week6');
					animation.addByPrefix('idle', 'BF IDLE', 24, false);
					animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
					animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);
		
					addOffset('idle');
					addOffset("singUP");
					addOffset("singRIGHT");
					addOffset("singLEFT");
					addOffset("singDOWN");
					addOffset("singUPmiss");
					addOffset("singRIGHTmiss");
					addOffset("singLEFTmiss");
					addOffset("singDOWNmiss");
		
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
		
					playAnim('idle');
					width -= 100;
					height -= 100;
		
					antialiasing = false;
		
					flipX = true;

				case 'bf-pixel-dead':
					frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD', 'week6');
					animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
					animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
					animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
					animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
					animation.play('firstDeath');
		
					addOffset('firstDeath');
					addOffset('deathLoop', -37);
					addOffset('deathConfirm', -37);
					playAnim('firstDeath');
					// pixel bullshit
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					antialiasing = false;
					flipX = true;

				case 'senpai':
					frames = Paths.getSparrowAtlas('characters/senpai', 'week6');
					animation.addByPrefix('idle', 'Senpai Idle', 24, false);
					animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);
		
					addOffset('idle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);
		
					playAnim('idle');
		
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
		
					antialiasing = false;

				case 'senpai-angry':
					frames = Paths.getSparrowAtlas('characters/senpai', 'week6');
					animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
					animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
					animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
					animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
					animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);
		
					addOffset('idle');
					addOffset("singUP", 5, 37);
					addOffset("singRIGHT");
					addOffset("singLEFT", 40);
					addOffset("singDOWN", 14);
					playAnim('idle');
		
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
		
					antialiasing = false;
		
				case 'spirit':
					frames = Paths.getPackerAtlas('characters/spirit', 'week6');
					animation.addByPrefix('idle', "idle spirit_", 24, false);
					animation.addByPrefix('singUP', "up_", 24, false);
					animation.addByPrefix('singRIGHT', "right_", 24, false);
					animation.addByPrefix('singLEFT', "left_", 24, false);
					animation.addByPrefix('singDOWN', "spirit down_", 24, false);
		
					addOffset('idle', -220, -280);
					addOffset('singUP', -220, -240);
					addOffset("singRIGHT", -220, -280);
					addOffset("singLEFT", -200, -280);
					addOffset("singDOWN", 170, 110);
		
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
		
					playAnim('idle');
		
					antialiasing = false;
				
				case 'none':
					// lol
			}

			dance();
		}

		if (isPlayer)
			flipX = !flipX;
	}

	function loadCharacterData() {
		for (char in characterArray){
			var SplitChar = char.split(":");

			// animations and offsets
			if (SplitChar[0] == "danceLeft"){
				var animArray = SplitChar[2].split(",");
				var animIntArray:Array<Int> = [];
				for (val in animArray){
					animIntArray.push(Std.parseInt(val));
				}

				animation.addByIndices('danceLeft', SplitChar[1], animIntArray, "", 24, false);
			}

			// animations and offsets
			if (SplitChar[0] == "danceRight"){
				var animArray = SplitChar[2].split(",");
				var animIntArray:Array<Int> = [];
				for (val in animArray){
					animIntArray.push(Std.parseInt(val));
				}

				animation.addByIndices('danceRight', SplitChar[1], animIntArray, "", 24, false);
			}

			if (SplitChar[0] == "anim.idle"){
				idleAnim = SplitChar[1];
				idleOffsetX = Std.parseInt(SplitChar[2]);
				idleOffsetY = Std.parseInt(SplitChar[3]);
			}

			if (SplitChar[0] == "anim.singUP"){
				singUPAnim = SplitChar[1];
				singUPOffsetX = Std.parseInt(SplitChar[2]);
				singUPOffsetY = Std.parseInt(SplitChar[3]);
			}

			if (SplitChar[0] == "anim.singRIGHT"){
				singRIGHTAnim = SplitChar[1];
				singRIGHTOffsetX = Std.parseInt(SplitChar[2]);
				singRIGHTOffsetY = Std.parseInt(SplitChar[3]);
			}

			if (SplitChar[0] == "anim.singLEFT"){
				singLEFTAnim = SplitChar[1];
				singLEFTOffsetX = Std.parseInt(SplitChar[2]);
				singLEFTOffsetY = Std.parseInt(SplitChar[3]);
			}

			if (SplitChar[0] == "anim.singDOWN"){
				singDOWNAnim = SplitChar[1];
				singDOWNOffsetX = Std.parseInt(SplitChar[2]);
				singDOWNOffsetY = Std.parseInt(SplitChar[3]);
			}

			if (SplitChar[0] == "multiplyGraphicSize"){
				setGraphicSize(Std.int(width * Std.parseFloat(SplitChar[1])));
			}

			if (SplitChar[0] == "flipX"){
				if (SplitChar[1] == "true"){
					flipX = true;
				}
				else{
					flipX = false;
				}
			}

			// get custom animations from SplitChar[0] that start with "custom-anim."
			if (SplitChar[0].indexOf("custom-anim.") == 0){
				animation.addByPrefix(SplitChar[0].substring(12), SplitChar[1], 24, false);
				addOffset(SplitChar[0].substring(12), Std.parseInt(SplitChar[2]), Std.parseInt(SplitChar[3]));
			}
		}

		isLoaded = true;
	}


	override function update(elapsed:Float)
	{
		if (!isPlayer && !PlayState.perfectMode || PlayState.perfectMode)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			if (holdTimer >= Conductor.stepCrochet * 4 * 0.001)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					dance();
				}

				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		FlxG.log.warn('Dancing, useAltIdle is currently: $useAltIdle');

		if (!debugMode)
		{
			// why the fuck did ninjamuffin not code it like this??
			if (animation.exists('danceLeft') && animation.exists('danceRight'))
				{
					if (!animation.curAnim.name.startsWith('hair'))
						{
							danced = !danced;
		
							if (danced)
								playAnim('danceRight');
							else
								playAnim('danceLeft');
						}
					}
				else{
					if (useAltIdle && animation.exists('idle-alt')){
						playAnim('idle-alt');
						//FlxG.log.add('using alternative idle');
					}
					else
						playAnim('idle');
				}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
