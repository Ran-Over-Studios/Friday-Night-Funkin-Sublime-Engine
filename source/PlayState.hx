package;

import sys.io.File;
import sys.FileSystem;
import openfl.media.Sound;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.filters.ShaderFilter;

// shaders
import shaders.CRT;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var noteSplashes:FlxTypedGroup<NoteSplash>;

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var cpuStrums:FlxTypedGroup<FlxSprite>;

	var specialNoteXOffset:Int = 0;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = [];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;
	var playedEndCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	var songLength:Float = 1;

	var sicks:Int = 0; var goods:Int = 0; var bads:Int = 0; var shits:Int = 0; var misses:Int = 0;

	var underlay:FlxSprite;

	var dadCharacterArray = [];
	var gfCharacterArray = [];
	var bfCharacterArray = [];

	var isCustomStage:Bool = false;
	var stageShit = [];

	var events = [];
	var songScrollSpeed:Float = 1;

	var hasDialogue:Bool = false;

	// shaders
	var curShader:String = '';

	var crt:CRT = new CRT();

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (SLModding.curLoaded != null)
			isMod = true;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (Paths.txt(SONG.song + "/shader") != null)
			curShader = Paths.txt(SONG.song + "/shader");

		if (FileSystem.exists(SLModding.generatePath(SLModding.curLoaded, "data/" + SONG.song) + "shader.txt"))
			curShader = File.getContent(SLModding.generatePath(SLModding.curLoaded, "data/" + SONG.song) + "shader.txt");

		switch(curShader.toLowerCase()){
			case 'crt':
				camGame.setFilters([new ShaderFilter(crt.shader)]);
		}

		if (FlxG.save.data.downScroll == null)
			FlxG.save.data.downScroll = false;

		if (FlxG.save.data.middleScroll == null)
			FlxG.save.data.middleScroll = false;

		if (FlxG.save.data.middleScroll == true)
			specialNoteXOffset = -279;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			case 'tutorial':
				dialogue = [":gf:Holy shit you're hot as funk" , ':bf:Holy shit you\'re also hot as funk', ':gf:... Wanna Funk?'];
			default:
				if (isMod && FileSystem.exists('mods/data/' + SONG.song.toLowerCase() + '/dialogue.txt')){
					var daList:Array<String> = File.getContent('mods/data/' + SONG.song.toLowerCase() + '/dialogue.txt').trim().split('\n');

					for (i in 0...daList.length)
					{
						daList[i] = daList[i].trim();
					}

					dialogue = daList;
					trace("Dialogue: " + dialogue);
					hasDialogue = true;
				}
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyArray[storyDifficulty];

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		noteSplashes = new FlxTypedGroup<NoteSplash>();
		var daSplash = new NoteSplash(100, 100, 0);
		daSplash.alpha = 0;
		noteSplashes.add(daSplash);
		
		if (SONG.player3 == null)
			SONG.player3 = 'gf';

		switch (PlayState.SONG.song.toLowerCase()){
			// change the stage and gf manually because im too lazy to modify every single chart
			case 'tutorial':
				SONG.player2 = 'none'; // no dad
				trace('Stage Changing not supported');

			case 'spookeez' | 'south' | 'monster':
				SONG.stage = 'halloween';
				trace('Stage Changing not supported');
			
			case 'pico' | 'philly' | 'blammed':
				SONG.stage = 'philly';
				trace('Stage Changing not supported');
			
			case 'satin-panties' | 'high' | 'milf':
				SONG.stage = 'limo';
				SONG.player3 = 'gf-car';
				trace('Stage & GF Changing not supported');
			
			case 'eggnog' | 'cocoa':
				SONG.stage = 'mall';
				SONG.player3 = 'gf-christmas';
				trace('Stage & GF Changing not supported');

			case 'winter-horrorland':
				SONG.stage = 'mallEvil';
				SONG.player3 = 'gf-christmas';
				trace('Stage & GF Changing not supported');

			case 'senpai' | 'roses':
				SONG.stage = 'school';
				SONG.player3 = 'gf-pixel';
				trace('Stage & GF Changing not supported');
			
			case 'thorns':
				SONG.stage = 'schoolEvil';
				SONG.player3 = 'gf-pixel';
				trace('Stage & GF Changing not supported');
		}

		if (FileSystem.exists('mods/' + SLModding.curLoaded + '/images/stages/' + SONG.stage + '/stage.txt') && !FileSystem.exists('mods/' + SLModding.curLoaded + '/images/stages/' + SONG.stage + '/do not use')){
			isCustomStage = true;

			var daList:Array<String> = File.getContent('mods/' + SLModding.curLoaded + '/images/stages/' + SONG.stage + '/stage.txt').trim().split('\n');
					
			for (i in 0...daList.length){
				daList[i] = daList[i].trim();
			}

			stageShit = daList;

			for (stage in stageShit){
				var SplitLines = stage.split(":");

				if (SplitLines[0] == "camZoom" && SplitLines[1] != "0"){
					defaultCamZoom = Std.parseFloat(SplitLines[1]);
				}

				if (SplitLines[6] == 'png' || SplitLines[6] == 'xml'){
					var daSprite = new FlxSprite(Std.parseInt(SplitLines[1]), Std.parseInt(SplitLines[2]));

					if (SplitLines[6] != 'png'){
						var texture = FlxAtlasFrames.fromSparrow(openfl.display.BitmapData.fromFile('mods/' + SLModding.curLoaded + '/images/stages/' + SONG.stage + '/' + SplitLines[0] + ".png"),
						File.getContent('mods/' + SLModding.curLoaded + '/images/stages/' + SONG.stage + '/' + SplitLines[0] + ".xml"));

						daSprite.frames = texture;
						daSprite.animation.addByPrefix('idle', SplitLines[7]);
						daSprite.animation.play('idle');
					}
					else{
						daSprite.loadGraphic(openfl.display.BitmapData.fromFile('mods/' + SLModding.curLoaded + '/images/stages/' + SONG.stage + '/' + SplitLines[0] + ".png"));
					}
					daSprite.scrollFactor.x = Std.parseInt(SplitLines[3]);
					daSprite.scrollFactor.y = Std.parseInt(SplitLines[4]);
					daSprite.alpha = Std.parseFloat(SplitLines[5]);
					add(daSprite);
				}
			}
		}
		else{
			switch (PlayState.SONG.stage){
				default:
					defaultCamZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					add(bg);
	
					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);
	
					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = true;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;
	
					add(stageCurtains);
				
				case 'halloween':
					curStage = 'halloween';
					halloweenLevel = true;
	
					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');
	
					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = true;
					add(halloweenBG);
					isHalloween = true;
	
				case 'philly':
					curStage = 'philly';
	
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);
	
					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);
	
					if (!FlxG.save.data.epilepsyMode){
					  phillyCityLights = new FlxTypedGroup<FlxSprite>();
					  add(phillyCityLights);
					}
	
					for (i in 0...5)
					{
						if (!FlxG.save.data.epilepsyMode){
							var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
							light.scrollFactor.set(0.3, 0.3);
							light.visible = false;
							light.setGraphicSize(Std.int(light.width * 0.85));
							light.updateHitbox();
							light.antialiasing = true;
							phillyCityLights.add(light);
						}
					}
	
					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
					add(streetBehind);
	
						phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					add(phillyTrain);
	
					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);
	
					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);
	
					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
						add(street);
				
				case 'limo':
					curStage = 'limo';
					defaultCamZoom = 0.90;
	
					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);
	
					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);
	
					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);
	
					for (i in 0...5)
					{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
					}
	
					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);
	
					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);
	
					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);
	
					// overlayShit.shader = shaderBullshit;
	
					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');
	
					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;
	
					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
					// add(limo);
	
				case 'mall':
					curStage = 'mall';
	
					defaultCamZoom = 0.80;
	
					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);
	
					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if (!FlxG.save.data.noDistractions)
						add(upperBoppers);
	
					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
	
					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					add(tree);
	
					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
						bottomBoppers.scrollFactor.set(0.9, 0.9);
						bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if (!FlxG.save.data.noDistractions)
						add(bottomBoppers);
	
					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = true;
					add(fgSnow);
	
					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;
					add(santa);
	
				case 'mallEvil':
					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);
	
					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					add(evilTree);
	
					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
						evilSnow.antialiasing = true;
					add(evilSnow);
	
				case 'school':
					curStage = 'school';
	
					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);
	
					var repositionShit = -200;
	
					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);
	
					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);
	
					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					add(fgTrees);
	
					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					add(bgTrees);
	
					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					add(treeLeaves);
	
					var widShit = Std.int(bgSky.width * 6);
	
					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);
	
					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();
	
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);
	
					if (SONG.song.toLowerCase().startsWith('roses'))
						{
							bgGirls.getScared();
						}
	
					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				
				case 'schoolEvil':
					curStage = 'schoolEvil';
	
					var posX = 400;
					var posY = 200;
	
					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				
				case 'void':
					// add nothing lol
			}
		}

		var gfVersion:String = SONG.player3;

		gf = new Character(400, 130, SONG.player3);
		trace('gf: ' + SONG.player3);
		gf.scrollFactor.set(0.95, 0.95);

		updateGirlfriend(SONG.player3);

		// still gotta add offsets for the gf
		switch (SONG.player3){
			case 'gf-pixel':
				gf.x += 180;
				gf.y += 300;
			default:
				if (gf.isTxt){
					for (char in gfCharacterArray){
						var SplitChar = char.split(":");
			
						if (SplitChar[0] == 'posYOffset-GF')
							gf.y += Std.parseFloat(SplitChar[1]);
						if (SplitChar[0] == 'posXOffset-GF')
							gf.x += Std.parseFloat(SplitChar[1]);
	
						trace('gf: ' + SplitChar[0] + ' ' + SplitChar[1]);
					}
				}
		}

		dad = new Character(100, 100, SONG.player2);
		updateCharacter(false);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			default:
				for (char in dadCharacterArray){
					var SplitChar = char.split(":");

					//trace('setting dad pos');
	
					if (SplitChar[0] == 'posYOffset-DAD')
						dad.y += Std.parseFloat(SplitChar[1]);
					if (SplitChar[0] == 'posXOffset-DAD')
						dad.x += Std.parseFloat(SplitChar[1]);
				}
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		updateCharacter(true);

		switch (SONG.player1)
		{
			case 'bf-pixel':
				boyfriend.x += 200;
				boyfriend.y += 220;
			default:
				for (char in bfCharacterArray){
					var SplitChar = char.split(":");

					//trace('setting bf pos');
	
					if (SplitChar[0] == 'posYOffset-BF')
						boyfriend.y += Std.parseFloat(SplitChar[1]);
					if (SplitChar[0] == 'posXOffset-BF')
						boyfriend.x += Std.parseFloat(SplitChar[1]);
				}
		}

		// REPOSITIONING PER STAGE
		if (!isCustomStage){
			switch (curStage)
			{
				case 'limo':
					boyfriend.y -= 220;
					boyfriend.x += 260;
	
					resetFastCar();
					add(fastCar);
	
				case 'mall':
					boyfriend.x += 200;
	
				case 'mallEvil':
					boyfriend.x += 320;
					dad.y -= 80;
				case 'schoolEvil':
					// trailArea.scrollFactor.set();
	
					var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					// evilTrail.changeValuesEnabled(false, false, false, false);
					// evilTrail.changeGraphic()
					add(evilTrail);
					// evilTrail.scrollFactor.set(1.1, 1.1);
			}
		}
		else{
			for (stage in stageShit){
				var SplitLines = stage.split(":");

				if (SplitLines[0] == 'xOffset-BF'){
					boyfriend.x += Std.parseFloat(SplitLines[1]);
				}

				if (SplitLines[0] == 'yOffset-BF'){
					boyfriend.y += Std.parseFloat(SplitLines[1]);
				}

				if (SplitLines[0] == 'xOffset-DAD'){
					dad.x += Std.parseFloat(SplitLines[1]);
				}

				if (SplitLines[0] == 'yOffset-DAD'){
					dad.y += Std.parseFloat(SplitLines[1]);
				}

				if (SplitLines[0] == 'xOffset-GF'){
					gf.x += Std.parseFloat(SplitLines[1]);
				}

				if (SplitLines[0] == 'yOffset-GF'){
					gf.y += Std.parseFloat(SplitLines[1]);
				}
			}
		}

		if (SONG.player3.toLowerCase() != 'none')
			add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(boyfriend);

		if (SONG.player2.toLowerCase() != 'none')
			add(dad);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		var underlayName:String = 'underlay';

		if (FlxG.save.data.middleScroll)
			underlayName = 'underlayMiddle';

		underlay = new FlxSprite(0, 0, Paths.image(underlayName, 'shared'));
		underlay.scrollFactor.set();
		underlay.alpha = 0.4;
		if (FlxG.save.data.downScroll)
			underlay.flipY = true;
		if (FlxG.save.data.laneUnderlay)
			add(underlay);

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		if (FlxG.save.data.downScroll)
			strumLine.y = FlxG.height - 130;
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		cpuStrums = new FlxTypedGroup<FlxSprite>();
		add(cpuStrums);

		add(noteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		if (isMod && FileSystem.exists("mods/" + SLModding.curLoaded + "/data/" + SONG.song.toLowerCase() + "/events.txt")){
			var daList:Array<String> = File.getContent("mods/" + SLModding.curLoaded + "/data/" + SONG.song.toLowerCase() + "/events.txt").trim().split('\n');
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}

			events = daList;
			trace(events);
		}
		else if (FileSystem.exists(Paths.file("data/" + SONG.song.toLowerCase() + "/events.txt")))
			events = CoolUtil.coolTextFile(Paths.file('data/' + SONG.song.toLowerCase() + '/events.txt'));

		if (songScrollSpeed != PlayState.SONG.speed) // if the song speed is different than the default speed due to a mod
			songScrollSpeed = PlayState.SONG.speed;

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, (FlxG.save.data.downScroll == false) ? FlxG.height * 0.9 : 50).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		var barColor:FlxColor = 0xFFFF0000;
		var barColor2:FlxColor = 0xFF66FF33;

		for (color in CoolUtil.coolTextFile(Paths.txt('healthcolors'))) {
			if (!color.startsWith('#')) {
				var eugh = color.split(':');

				if (dad.curCharacter.toLowerCase().startsWith(eugh[0])) {
					barColor = new FlxColor(Std.parseInt(eugh[1]));
				}
				if (boyfriend.curCharacter.toLowerCase().startsWith(eugh[0])) {
					barColor2 = new FlxColor(Std.parseInt(eugh[1]));
				}
			}
		}

		// mod shit
		if (boyfriend.isMod && FileSystem.exists('mods/' + SLModding.curLoaded + '/images/characters/' + PlayState.SONG.player1 + '/character.txt')){
			var characterStuff:Array<String> = File.getContent('mods/' + SLModding.curLoaded + '/images/characters/' + PlayState.SONG.player1 + '/character.txt').split('\n');

			for (color in characterStuff){
				if (!color.startsWith('#')) {
					var eugh = color.split(':');
	
					if (eugh[0] == 'healthColor') {
						barColor2 = new FlxColor(Std.parseInt(eugh[1]));
					}
				}
			}
		}

		if (dad.isMod && FileSystem.exists('mods/' + SLModding.curLoaded + '/images/characters/' + PlayState.SONG.player2 + '/character.txt')){
			var characterStuff:Array<String> = File.getContent('mods/' + SLModding.curLoaded + '/images/characters/' + PlayState.SONG.player2 + '/character.txt').split('\n');

			for (color in characterStuff){
				if (!color.startsWith('#')) {
					var eugh = color.split(':');
	
					if (eugh[0] == 'healthColor') {
						barColor = new FlxColor(Std.parseInt(eugh[1]));
					}
				}
			}
		}

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
		'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(barColor, barColor2);
		// healthBar
		add(healthBar);

		songBarBG = new FlxSprite(0, (FlxG.save.data.downScroll == false) ? FlxG.height * 0.85 : 150).makeGraphic(Std.int(healthBarBG.width), Std.int(healthBarBG.height), 0xFF000000);
		songBarBG.setGraphicSize(Std.int(songBarBG.width * 0.5), Std.int(songBarBG.height * 1.5));
		songBarBG.updateHitbox();
		songBarBG.screenCenter(X);
		songBarBG.scrollFactor.set();
		add(songBarBG);
		
		songBar = new FlxBar(songBarBG.x + 4, songBarBG.y + 4, LEFT_TO_RIGHT, Std.int(songBarBG.width - 8), Std.int(songBarBG.height - 8), this,
		'songTime', 0, songLength);
		songBar.scrollFactor.set();
		songBar.createFilledBar(FlxColor.fromRGB(0, 51, 0), FlxColor.fromRGB(0, 153, 51));
		add(songBar);

		songBarTimeTxt = new FlxText(songBarBG.x, songBarBG.y, songBarBG.width, "00:00");
		songBarTimeTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
		if (SONG.noteskin.toLowerCase() != 'pixel')
			songBarTimeTxt.setFormat("PhantomMuff 1.5", 24, FlxColor.WHITE, CENTER);
		songBarTimeTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 2, 1);
		songBarTimeTxt.scrollFactor.set();
		add(songBarTimeTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.setGraphicSize(20);
		iconP1.updateHitbox();
		add(iconP1);

		if (SONG.player2.toLowerCase() != 'none')
			iconP2 = new HealthIcon(SONG.player2, false);
		else
			iconP2 = new HealthIcon(SONG.player3, false); // lol
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.setGraphicSize(20);
		iconP2.updateHitbox();
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 46, FlxG.width, "", 24);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
		scoreTxt.scrollFactor.set();
		if (SONG.noteskin.toLowerCase() != 'pixel'){
			scoreTxt.setFormat("PhantomMuff 1.5", 16, FlxColor.WHITE, CENTER);
			scoreTxt.antialiasing = true;
		}
		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 2, 1);
		add(scoreTxt);

		rankTxt = new FlxText(16, 640 - 96, 512, "Sick's - 0\nGood's - 0\nBad's - 0\nShit's - 0", 24);
		rankTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
		rankTxt.scrollFactor.set();
		if (SONG.noteskin.toLowerCase() != 'pixel'){
			rankTxt.setFormat("PhantomMuff 1.5", 24, FlxColor.WHITE, LEFT);
			rankTxt.antialiasing = true;
		}
		rankTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 2, 1);
		add(rankTxt);
		
		noteSplashes.cameras = [camHUD];
		cpuStrums.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		underlay.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		songBar.cameras = [camHUD];
		songBarTimeTxt.cameras = [camHUD];
		songBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		rankTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);

				case 'example': //mp4 cutscene example
							// File name here					 
					playCutscene('example');
				
				case 'tutorial':
					schoolIntro(doof);
				default:
					if (!FileSystem.exists('mods/' + SLModding.curLoaded + '/cutscenes/' + curSong + '/start.mp4')){
							if (!isMod || isMod && !hasDialogue)
								startCountdown();
							else if (isMod && hasDialogue){
								schoolIntro(doof);
						}
					}
					else{
						playCutscene('mods/' + SLModding.curLoaded + '/cutscenes/' + curSong + '/start.mp4', true);
					}
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		if (!FlxG.save.data.middleScroll)
			generateStaticArrows(0);

		generateStaticArrows(1);

		// middle scroll offset
		if (FlxG.save.data.middleScroll){
			for (strumArrow in playerStrums){
				if (strumArrow != null)
					strumArrow.x += specialNoteXOffset;
			}
		}

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			var introLibrary:String = '';
			var altSuffix:String = "";

			switch(SONG.noteskin){
				case 'pixel':
					introAssets.set('default', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
					introLibrary = 'week6';
					altSuffix = '-pixel';
				default:
					introAssets.set('default', ['ready', "set", "go"]);
					introLibrary = 'shared';
					altSuffix = '';
			}

			var introAlts:Array<String> = introAssets.get('default');

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0], introLibrary));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (introLibrary == 'week6')
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1], introLibrary));
					set.scrollFactor.set();

					if (introLibrary == 'week6')
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2], introLibrary));
					go.scrollFactor.set();

					if (introLibrary == 'week6')
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused && !isMod)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		else if (!paused && isMod)
			FlxG.sound.playMusic(Sound.fromFile("mods/" + SLModding.curLoaded + "/songs/" + PlayState.SONG.song.toLowerCase() + "/Inst.ogg"), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		songBar.setRange(songTime, songLength);

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices && inCutscene == false && !isMod)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else if (SONG.needsVoices && inCutscene == false && isMod)
			vocals = new FlxSound().loadEmbedded(Sound.fromFile("mods/" + SLModding.curLoaded + "/songs/" + PlayState.SONG.song.toLowerCase() + "/Voices.ogg"));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					// noteplacement offset
					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += (702 - 48) + specialNoteXOffset;
					}
					else{
						sustainNote.x += (134 - 48) + specialNoteXOffset;

						if (FlxG.save.data.middleScroll == true)
							sustainNote.alpha = 0;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += (690 - 38) + specialNoteXOffset;
				}
				else {
					swagNote.x += (134 - 48) + specialNoteXOffset;

					if (FlxG.save.data.middleScroll == true)
						swagNote.alpha = 0;
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			//NoteSkin (Regular Notes - For Sustain, Open Note.hx)
			switch (SONG.noteskin)
			{
				 default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets();
			});

			if (player == 1)
			{
				playerStrums.add(babyArrow);
				babyArrow.x += 702;
			}
			else{
				babyArrow.x += 136;
			}

			babyArrow.animation.play('static');
			//babyArrow.x += 50;
			//babyArrow.x += ((FlxG.width / 2) * player);


			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		if (curShader.toLowerCase() == 'crt')
				crt.shader.uTime.value = [elapsed];

		scoreTxt.text = 'Score: $songScore • Misses: $misses • Accuracy: ${calculateRating()} • Combo: $combo';
		rankTxt.text = 'Sicks • $sicks\nGoods • $goods\nBads • $bads\nShits • $shits';

		//songBarTimeTxt.text = '${Math.floor((Conductor.songPosition / 1000) / 60)}:${Math.floor((Conductor.songPosition / 1000) % 60)}';
		songBarTimeTxt.text = '${(Math.floor((Conductor.songPosition / 1000) / 60))}:${(Math.floor((Conductor.songPosition / 1000) % 60) < 10 ? '0' : '') + Math.floor((Conductor.songPosition / 1000) % 60)}'.replace('\n', '');
		
		//trace(songBarTimeTxt.text + ' | ' + Conductor.songPosition);

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width - 50, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width - 50, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		var iconOffset:Int = 20;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (iconP1.overlaps(songBar)){
			iconP1.alpha = 0.65;
		}
		else{
			iconP1.alpha = 1;
		}

		if (iconP2.overlaps(songBar)){
			iconP2.alpha = 0.65;
		}
		else{
			iconP2.alpha = 1;
		}

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var gfCam:Bool = false;

				if (SONG.player2 != 'none' || !PlayState.SONG.notes[Std.int(curStep / 16)].gfSection)
					camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				else if (SONG.player2 == 'none' || PlayState.SONG.notes[Std.int(curStep / 16)].gfSection)
					gfCam = true;
				else
					camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				// dad camera offsets??!??/1/1
				if (SONG.player2 != 'none' || !PlayState.SONG.notes[Std.int(curStep / 16)].gfSection){
					switch (dad.curCharacter)
					{
						case 'mom':
							camFollow.y = dad.getMidpoint().y;
						case 'senpai':
							camFollow.y = dad.getMidpoint().y - 430;
							camFollow.x = dad.getMidpoint().x - 100;
						case 'senpai-angry':
							camFollow.y = dad.getMidpoint().y - 430;
							camFollow.x = dad.getMidpoint().x - 100;
						default:
							if (dadCharacterArray != []){
								for (char in dadCharacterArray){
									var SplitChar = char.split(":");
			
									if (SplitChar[0] == 'camYOffset')
										camFollow.y = dad.getMidpoint().y += Std.parseFloat(SplitChar[1]);
									if (SplitChar[0] == 'camXOffset')
										camFollow.x = dad.getMidpoint().x += Std.parseFloat(SplitChar[1]);
								}
							}
							
					}
				}

				if (gfCam)
					camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.notes[Math.floor(curStep / 16)] != null){
					if (SONG.song.toLowerCase() == 'tutorial' || SONG.notes[Math.floor(curStep / 16)].gfSection)
						{
							tweenCamIn();
						}
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (boyfriend.curCharacter)
				{
					case 'bf-car':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'bf-christmas':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'bf-pixel':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					default:
						if (bfCharacterArray != []){
							for (char in bfCharacterArray){
								var SplitChar = char.split(":");
		
								if (SplitChar[0] == 'camYOffset')
									camFollow.y = boyfriend.getMidpoint().y += Std.parseFloat(SplitChar[1]);
								if (SplitChar[0] == 'camXOffset')
									camFollow.x = boyfriend.getMidpoint().x += Std.parseFloat(SplitChar[1]);
							}
						}
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic){
			// interpolation
			notes.forEachAlive(function(daNote:Note){
				if (FlxG.save.data.downScroll == false)
					daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * songScrollSpeed));
				else
					daNote.y = (strumLine.y + (songTime - daNote.strumTime) * (0.45 * songScrollSpeed));
			});
		}

		if (generatedMusic && !paused)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!FlxG.save.data.downScroll)
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(songScrollSpeed, 2)));
				else
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(songScrollSpeed, 2)));

				// i am so fucking sorry for this if condition
				if (FlxG.save.data.downScroll == false ? daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) : daNote.isSustainNote
					&& daNote.y + daNote.offset.y >= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect;

					swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);

					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}
				
				if (FlxG.save.data.downScroll == false ? !daNote.mustPress && daNote.y <= strumLine.y : !daNote.mustPress && daNote.y >= strumLine.y)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim){
							if (dad.animation.exists('singLEFT-alt'))
								altAnim = '-alt';
						}
						if (!SONG.notes[Math.floor(curStep / 16)].gfSection){
							switch (Math.abs(daNote.noteData))
							{
								case 0:
									dad.playAnim('singLEFT' + altAnim, true);
								case 1:
									dad.playAnim('singDOWN' + altAnim, true);
								case 2:
									dad.playAnim('singUP' + altAnim, true);
								case 3:
									dad.playAnim('singRIGHT' + altAnim, true);
							}
						}
						else{
							switch (Math.abs(daNote.noteData))
							{
								case 0:
									gf.playAnim('singLEFT' + altAnim, true);
								case 1:
									gf.playAnim('singDOWN' + altAnim, true);
								case 2:
									gf.playAnim('singUP' + altAnim, true);
								case 3:
									gf.playAnim('singRIGHT' + altAnim, true);
							}
						}
					}
					else{
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
						}
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					//CPUSTRUM CONFIRM ANIMATION
					cpuStrums.forEach(function(spr:FlxSprite)
						{
							
							if (Math.abs(daNote.noteData) == spr.ID)
							{	
								spr.animation.play('confirm', true);
								
								if (!daNote.isSustainNote)
									noteSplash(daNote.x, daNote.y, daNote.noteData, true);										
							}

							//CPUSTRUM NoteSkin Confirm Offsets
							if (spr.animation.curAnim.name == 'confirm')
							{
								switch (SONG.noteskin){
									default:
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									case 'pixel':
										// not needed
									case 'circle':
										spr.centerOffsets();
								}
							}
							else{
								spr.centerOffsets();
							}
						});

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// if the player is late, miss.
				if ((FlxG.save.data.downScroll == false) ? daNote.y < -daNote.height : daNote.y > FlxG.height + daNote.height)
				{	
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.1;
						combo = 0;

						vocals.volume = 0;

						misses++;
						FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

						switch (Math.abs(daNote.noteData)){
							case 0:
								boyfriend.playAnim('singLEFTmiss', true);
							case 1:
								boyfriend.playAnim('singDOWNmiss', true);
							case 2:
								boyfriend.playAnim('singUPmiss', true);
							case 3:
								boyfriend.playAnim('singRIGHTmiss', true);
						}
					}
					

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished && spr.animation.curAnim.name == 'confirm')
				{
					spr.animation.play('static');
					spr.centerOffsets();
					// trace('confirm animation finished');
				}
			});

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		if (playedEndCutscene == false && isStoryMode == true){
			if (!FileSystem.exists('mods/' + SLModding.curLoaded + '/cutscenes/' + curSong + '/end.mp4')){
				switch (curSong.toLowerCase())
				{
					case 'pico':
						playEndCutscene("cock");
				}
			}
			else{
				playEndCutscene('mods/' + SLModding.curLoaded + '/cutscenes/' + curSong + '/end.mp4', true);
			}
		}

		if (inCutscene == false){
			canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		Highscore.saveScore(SONG.song.toLowerCase(), songScore, storyDifficulty);

		camHUD.fade(FlxColor.TRANSPARENT, 0.5, false, null, true);

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				if (!isMod)
					FlxG.switchState(new StoryMenuState());
				else{
					FlxG.switchState(new ModsStoryMenu());
					SLModding.curLoaded = null;
				}

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (CoolUtil.difficultyArray.contains("NORMAL") && CoolUtil.difficultyArray[storyDifficulty] == 'NORMAL') {
					difficulty = '';
				} else {
					difficulty = '-' + CoolUtil.difficultyArray[storyDifficulty].toLowerCase();
				}

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				if (!isMod){
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				}
				else{
					var modSong:String = PlayState.storyPlaylist[0].toLowerCase();

					if (modSong == "" || modSong == null){
						trace("OH SHIT THERES NO SONG... ATTEMPTING TO SET IT AGAIN");
						modSong = PlayState.storyPlaylist[0].toLowerCase();
					}

					PlayState.SONG = Song.loadFromModJson(modSong + "/" + modSong + difficulty);
				}

				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			SLModding.curLoaded = null;
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
		}
		
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			shits++;
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			bads++;
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			goods++;
			score = 200;
		}
		else{
			sicks++;
		}

		daNote.daRating = daRating;
		songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		var pixelShitLibrary:String = 'shared';

		// NoteSkin (pixelShit) it is multiple string's that is used to determine the asset path of the note skin.
		switch(SONG.noteskin){
			default:
				//not needed
			case 'pixel':
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
				pixelShitLibrary = 'week6';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2, pixelShitLibrary));
		rating.screenCenter();
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		add(rating);

		var offset:Float = 0;

		// Increase Graphic Size for NoteSkin (pixelShit)
		switch(SONG.noteskin){
			default:
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				offset = 16;
			case 'pixel':
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));

		}

		rating.updateHitbox();
		rating.y = FlxG.height * 0.3;
		rating.x = FlxG.width * 0.5 - rating.width * 0.5 + offset;
		rating.cameras = [camHUD];

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}


	private function keyShit():Void
		{
			// HOLDING
			var up = controls.UP;
			var right = controls.RIGHT;
			var down = controls.DOWN;
			var left = controls.LEFT;
	
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			var upR = controls.UP_R;
			var rightR = controls.RIGHT_R;
			var downR = controls.DOWN_R;
			var leftR = controls.LEFT_R;
	
			var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
	
			// FlxG.watch.addQuick('asdfa', upP);
			if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
			{
				boyfriend.holdTimer = 0;
	
				var possibleNotes:Array<Note> = [];
	
				var ignoreList:Array<Int> = [];
	
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					{
						// the sorting probably doesn't need to be in here? who cares lol
						possibleNotes.push(daNote);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	
						ignoreList.push(daNote.noteData);
					}
				});
	
				if (possibleNotes.length > 0)
				{
					var daNote = possibleNotes[0];
	
					if (perfectMode)
						noteCheck(true, daNote);
	
					// Jump notes
					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes)
							{
								if (controlArray[coolNote.noteData])
									goodNoteHit(coolNote);
							}
						}
						else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						{
							if (left || up || down || right) {
								noteCheck(controlArray[daNote.noteData], daNote);
							}
						}
						else
						{
							for (coolNote in possibleNotes)
							{
								if (left || up || down || right) {
									noteCheck(controlArray[coolNote.noteData], coolNote);
								}
							}
						}
					}
					else // regular notes?
					{
						if (left || up || down || right) {
							noteCheck(controlArray[daNote.noteData], daNote);
						}
					}
				}
				else
				{
					if (!FlxG.save.data.ghostTap){
						badNoteCheck();
					}
				}
			}
	
			if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote && !daNote.isIgnored)
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0:
								if ((left))
									goodNoteHit(daNote);
							case 1:
								if ((down))
									goodNoteHit(daNote);
							case 2:
								if ((up))
									goodNoteHit(daNote);
							case 3:
								if ((right))
									goodNoteHit(daNote);
						}
					}
				});
			}
	
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
	
			playerStrums.forEach(function(spr:FlxSprite)
			{
				switch (spr.ID)
				{
					case 0:
						if ((leftP) && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (leftR)
							spr.animation.play('static');
					case 1:
						if ((downP) && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (downR)
							spr.animation.play('static');
					case 2:
						if ((upP) && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (upR)
							spr.animation.play('static');
					case 3:
						if ((rightP) && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (rightR)
							spr.animation.play('static');
				}
				try {
					if (spr.animation.curAnim.name == 'confirm')
						{
							// Player NoteSkin Confirm Offsets
							switch (SONG.noteskin){
								default:
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								case 'pixel':
									// not needed
							}
						}
						else{
							spr.centerOffsets();
						}
				}
			});
		}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.1;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			misses++;
			

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (note.wasGoodHit && note.daRating == 'sick')
				noteSplash(note.x, note.y, note.noteData, false);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function calculateRating() {
		if (misses == 0) {
			if (goods < 1 && bads < 1 && shits < 1 && songScore != 0){
				return 'PERFECT! (MFC) (${calculateLetter()} | ${calcAcc()})';
			} else {
			   if (songScore == 0) {
				return 'N/A (${calculateLetter()} | ${calcAcc()})';
			   } else {
				return 'SICK! (FC) (${calculateLetter()} | ${calcAcc()})';
			   }
			}
		}
		else if (misses > 0 && misses <= 10) {
			return 'GOOD! (SDM) (${calculateLetter()} | ${calcAcc()})';
		}
		else {
			return 'BAD (Clear) (${calculateLetter()} | ${calcAcc()})';
		}
	}

	function calculateLetter() {
		if (sicks > 0 || goods > 0 || bads > 0 || shits > 0 || misses > 0)
			return '${sicks > goods ? 'A' : ''}${sicks > bads ? 'A' : ''}${sicks > shits ? 'A': ''}${sicks > misses ? 'A' : ''}';
		else
			return '?';
	}

	function calcAcc() {
		if (sicks > 0 || goods > 0 || bads > 0 || shits > 0 || misses > 0)
			return '${Math.floor((((sicks + goods + bads + shits) / 100) / ((misses + sicks + goods + bads + shits) / 100)) * 100)}%';
		else
			return '?';
	}

	function noteSplash(noteX:Float, noteY:Float, nData:Int, ?isDad = false)
		{
			var recycledNote = noteSplashes.recycle(NoteSplash);
			if (!isDad)    
				recycledNote.makeSplash(playerStrums.members[nData].x, playerStrums.members[nData].y, nData);
			else
				recycledNote.makeSplash(cpuStrums.members[nData].x, cpuStrums.members[nData].y, nData);
				noteSplashes.add(recycledNote);
		}
	
	function playCutscene(name:String, isPath:Bool = false)
	{
		inCutscene = true;
		trace(Paths.video(name));
		var video:VideoHandler = new VideoHandler();
		video.finishCallback = function()
		{
			startCountdown();
		}
		if (!isPath)
			video.playVideo(Paths.video(name));
		else
			video.playVideo(name);
	}
	
	function playEndCutscene(name:String, isPath:Bool = false)
	{
		//Doesn't check if the song is ending sense it gets called to play WHILE the song is ending.
		inCutscene = true;

		//KILL THE MUSIC!!!
		FlxG.sound.music.kill();
		vocals.kill();

		inCutscene = true;

		var video:VideoHandler = new VideoHandler();
		video.finishCallback = function()
		{
			inCutscene = false;
			playedEndCutscene = true;
			endSong();
		}
		if (!isPath)
			video.playVideo(Paths.video(name));
		else
			video.playVideo(name);
	}

	function updateCharacter(isBF:Bool = false){
		if (!isBF){
			if (dad.isTxt){
				var daList:Array<String>;

				if (dad.isMod)
					daList = File.getContent("mods/" + SLModding.curLoaded + "/images/characters/" + dad.curCharacter + "/character.txt").trim().split('\n');
				else
					daList = Paths.character(dad.curCharacter).trim().split('\n');
					
				for (i in 0...daList.length){
					daList[i] = daList[i].trim();
				}
	
				dadCharacterArray = daList;
			}
			else
				trace('dad is not hardcoded or modded');

			trace("dad:" + dad.curCharacter);
		}
		else{
			//same thing but for the boyfriend

			if (boyfriend.isTxt){
				var daList:Array<String>;

				if (boyfriend.isMod)
					daList = File.getContent("mods/" + SLModding.curLoaded + "/images/characters/" + boyfriend.curCharacter + "/character.txt").trim().split('\n');
				else
					daList = Paths.character(boyfriend.curCharacter).trim().split('\n');
					
				for (i in 0...daList.length){
					daList[i] = daList[i].trim();
				}
	
				bfCharacterArray = daList;
			}
			else
				trace('bf is not hardcoded or modded');

			trace('bf: ' + boyfriend.curCharacter);
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		for (event in events){
			var tempStep = event.split(":");

			//trace(event);
			//trace(tempStep[0] + " " + tempStep[1]);

			//curStep in 0, event in 1
			if (Std.parseInt(tempStep[0]) == curStep){
				switch(tempStep[1].toLowerCase()){
					case 'setsongspeed':
						songScrollSpeed = Std.parseFloat(tempStep[2]);
						trace("SET SPEED TO " + songScrollSpeed);
					case 'gfcheer':
						gf.playAnim('cheer', true);
						trace("GF CHEER");
					case 'playanimation.dad':
						dad.playAnim(tempStep[2], true);
						trace("DAD ANIM " + tempStep[2]);
					case 'playanimation.boyfriend':
						boyfriend.playAnim(tempStep[2], true);
						trace("BOYFRIEND ANIM " + tempStep[2]);
					case 'playanimation.girlfriend':
						gf.playAnim(tempStep[2], true);
						trace("GIRLFRIEND ANIM " + tempStep[2]);
					case 'replace.dad':
						remove(dad);
						dad = new Character(dad.x += Std.parseFloat(tempStep[3]),dad.y += Std.parseFloat(tempStep[4]), tempStep[2]);
						updateCharacter(false);
						add(dad);
					case 'replace.boyfriend':
						remove(boyfriend);
						boyfriend = new Boyfriend(boyfriend.x += Std.parseFloat(tempStep[3]),boyfriend.y += Std.parseFloat(tempStep[4]), tempStep[2]);
						updateCharacter(true);
						add(boyfriend);
					case 'replace.girlfriend':
						remove(gf);
						gf = new Character(gf.x += Std.parseFloat(tempStep[3]),gf.y += Std.parseFloat(tempStep[4]), tempStep[2]);
						updateGirlfriend(tempStep[2]);
						add(gf);
				}
			}
		}
		
		if (SONG.notes[Math.floor(curStep / 16)] != null){
			if (SONG.notes[Math.floor(curStep / 16)].altAnim)
				dad.useAltIdle = true;
			else
				dad.useAltIdle = false;
		}
	}

	function updateGirlfriend(type:String){
		if (gf.isTxt){
			var daList:Array<String>;

			if (!gf.isMod){
				daList = Paths.character(type).trim().split('\n');
					
				for (i in 0...daList.length){
					daList[i] = daList[i].trim();
				}
	
				gfCharacterArray = daList;
			}
			else{
				daList = File.getContent("mods/" + SLModding.curLoaded + "/images/characters/" + type + "/character.txt").trim().split('\n');

				for (i in 0...daList.length){
					daList[i] = daList[i].trim();
				}
	
				gfCharacterArray = daList;
			}
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			/*if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();*/
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf.curCharacter.toLowerCase() != 'none'){
			if (curBeat % gfSpeed == 0 && gf.animation.curAnim.name.startsWith("dance") || !gf.animation.curAnim.name.startsWith("dance") &&
				!gf.animation.curAnim.name.startsWith("sing") && gf.animation.curAnim.finished || gf.animation.curAnim.name.startsWith('scared') && curBeat % gfSpeed == 0)
			{
				gf.dance();
			}
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") || !boyfriend.animation.curAnim.name.startsWith("idle") &&
			!boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.curAnim.finished)
		{
			boyfriend.playAnim('idle');
		}

		if (dad.curCharacter != 'none' && dad.animation.curAnim.name.startsWith("idle") ||
			dad.curCharacter != 'none' && !dad.animation.curAnim.name.startsWith("idle") &&
			!dad.animation.curAnim.name.startsWith("sing") && dad.animation.curAnim.finished)
		{
			dad.dance();
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
					{
						if (!FlxG.save.data.epilepsyMode){
							phillyCityLights.forEach(function(light:FlxSprite)
								{
									light.visible = false;
								});
			
								curLight = FlxG.random.int(0, phillyCityLights.length - 1);
			
								phillyCityLights.members[curLight].visible = true;
								// phillyCityLights.members[curLight].alpha = 1;
						}
					}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8 && !FlxG.save.data.noDistractions)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset && !FlxG.save.data.noDistractions)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;

	var songBarBG:FlxSprite;

	var songBar:FlxBar;

	var isMod:Bool;

	var rankTxt:FlxText;

	var songBarTimeTxt:FlxText;
}
