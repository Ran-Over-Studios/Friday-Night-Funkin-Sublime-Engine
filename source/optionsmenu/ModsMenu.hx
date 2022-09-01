package optionsmenu;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import SLModding; // holy shit?!/1 who would of guessed?
import flixel.FlxState;
import flixel.util.FlxTimer;

class ModsMenu extends MusicBeatState
{
    var inColorTimer:Bool = false;
    var bgColorArray:Array<FlxColor> = [FlxColor.RED, FlxColor.GREEN, FlxColor.BLUE];
    var curColor:Int;

    var uiGroup:FlxTypedGroup<FlxSprite>;
    var modStuff:FlxGroup;

    var reloadButton:FlxButton;

    var daBGcolor:FlxColor;
	var bg:FlxSprite;

    var modBG:FlxSprite;
    var modCounter:FlxText;

    var selectedMod:Int = 0;

    var modIcon:FlxSprite;
    var modTitle:FlxText;
    var modDescription:FlxText;
    var modAuthor:FlxText;
    var modVersion:FlxText;

    override public function create()
    {
        FlxG.mouse.visible = true;

        uiGroup = new FlxTypedGroup<FlxSprite>();
        modStuff = new FlxGroup();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = bgColorArray[0];
		uiGroup.add(bg);

        reloadButton = new FlxButton(0, 0, "Reload Mods", function() {
            SLModding.init();
            FlxG.resetState();
        });
        reloadButton.x = (FlxG.width - reloadButton.width) - 24;
        reloadButton.y = (FlxG.height - reloadButton.height) - 24;
        uiGroup.add(reloadButton);

        modBG = new FlxSprite().makeGraphic(1024, 512, FlxColor.BLACK);
        modBG.alpha = 0.6;
        modBG.screenCenter(XY);
        uiGroup.add(modBG);

        modCounter = new FlxText(0, 0, FlxG.width, "1 / 1");
        modCounter.setFormat("PhantomMuff 1.5", 64, FlxColor.WHITE, "center");
        modCounter.screenCenter(X);
        modCounter.y = 24;
        uiGroup.add(modCounter);

        for (members in uiGroup){
            members.scrollFactor.set(0, 0);
        }

        add(uiGroup);

        generateModShit(SLModding.modsArray[0]);
        add(modStuff);

        super.create();
    }

    function generateModShit(mod:String = ''){
        if (mod == '')
            mod = SLModding.curLoaded;

        for (stuff in modStuff){
            if (stuff != null){
                stuff.kill();
                modStuff.remove(stuff);
            }
        }

        modIcon = new FlxSprite().loadGraphic(SLModding.getBitmap(SLModding.generatePath(mod) + 'icon.png'));
        modIcon.setGraphicSize(256, 256);
        modIcon.updateHitbox();
        modIcon.antialiasing = true;
        modIcon.setPosition(modBG.x + 24, modBG.y + 24);
        modIcon.antialiasing = true;
        modStuff.add(modIcon);

        modTitle = new FlxText((modBG.x + 256) + 48, modBG.y + 24, SLModding.parseModValue('name', mod));
        modTitle.setFormat("PhantomMuff 1.5", 64, FlxColor.WHITE, "center");
        modTitle.antialiasing = true;
        modStuff.add(modTitle);

        modDescription = new FlxText((modBG.x + 256) + 48, modTitle.y + modTitle.height + 24, modBG.width * 0.7, SLModding.parseModValue('description', mod));
        modDescription.setFormat("PhantomMuff 1.5", 32, FlxColor.WHITE, "left");
        modDescription.antialiasing = true;
        modStuff.add(modDescription);

        modAuthor = new FlxText(modIcon.x, (modIcon.y + modIcon.height) + 72, 256, SLModding.parseModValue('author', mod));
        modAuthor.setFormat("PhantomMuff 1.5", 32, FlxColor.WHITE, "center");
        modAuthor.antialiasing = true;
        modStuff.add(modAuthor);

        modVersion = new FlxText(modIcon.x, (modAuthor.y + modAuthor.height) + 24, 256, SLModding.parseModValue('version', mod));
        modVersion.setFormat("PhantomMuff 1.5", 32, FlxColor.WHITE, "center");
        modVersion.antialiasing = true;
        modStuff.add(modVersion);

        if (modTitle.text.length > 16){
            modTitle.setFormat("PhantomMuff 1.5", 24, FlxColor.WHITE, "center");
        }

        if (modVersion.text.length > 8){
            modVersion.setFormat("PhantomMuff 1.5", 24, FlxColor.WHITE, "center");
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.BACK) {
			FlxG.switchState(new OptionsMenu());

			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

        if (controls.LEFT_P && selectedMod > 0){
            selectedMod--;
            generateModShit(SLModding.modsArray[selectedMod]);
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }
        else if(controls.RIGHT_P && selectedMod < SLModding.modsArray.length - 1){
            selectedMod++;
            generateModShit(SLModding.modsArray[selectedMod]);
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        modCounter.text = (selectedMod + 1) + " / " + SLModding.modsArray.length;

        if (!inColorTimer) {
            var timer:FlxTimer = new FlxTimer();
            timer.start(0.5, function(timer) {
                if (curColor < bgColorArray.length - 1) {
                    curColor++;
                } 
                else {
                    curColor = 0;
                }

                daBGcolor = bgColorArray[curColor];

                FlxTween.color(bg, 0.5, bg.color, daBGcolor, {ease: FlxEase.quadInOut, type: ONESHOT});
                bg.color = daBGcolor;
                
                inColorTimer = false;
            });

            inColorTimer = true;
        }
    }
}