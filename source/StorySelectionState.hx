package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

class StorySelectionState extends MusicBeatState{
    
    var curSelected:Int = 0;

    var optionsArray = ['Friday Night Funkin\'', 'Mods'];
    var option:FlxText;

    var optionGroup = new FlxTypedGroup<FlxText>();

	override function create()
    {
        
        super.create();

        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        createOptions();
    }

    function createOptions(){
        var lastY = (FlxG.height * 0.5) - (64 * optionsArray.length);

        for (i in 0...optionsArray.length){
            option = new FlxText(0, 0, FlxG.width, optionsArray[i]);
            option.setFormat("PhantomMuff 1.5", 32, FlxColor.WHITE, CENTER);
		    option.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 4, 1);
            option.antialiasing = true;
            option.y += lastY + option.height;
            add(option);
            optionGroup.add(option);

            lastY += Std.int(option.height);
        }

        optionAlpha();
    }

    function optionAlpha(){
        if (curSelected == -1 || curSelected >= optionGroup.length) {
			return;
		}
		else{
			for (option in 0...optionGroup.members.length) {
				if (option == curSelected && optionGroup.members[option] != null) {
					optionGroup.members[option].alpha = 1;
				}
	
				if (option != curSelected && optionGroup.members[option] != null) {
					optionGroup.members[option].alpha = 0.6;
				}
			}
		}
    }

    override function update(elapsed)
    {
        super.update(elapsed);

        if (controls.UP_P){
            curSelected--;
            if (curSelected < 0) {
                curSelected = optionGroup.length - 1;
            }
            optionAlpha();
        }
        else if (controls.DOWN_P){
            curSelected++;
            if (curSelected >= optionGroup.length) {
                curSelected = 0;
            }
            optionAlpha();
        }

        if (controls.BACK){
            FlxG.switchState(new MainMenuState());
        }

        if (controls.ACCEPT){
            switch (optionsArray[curSelected]) {
                case 'Friday Night Funkin\'':
                    FlxG.switchState(new StoryMenuState());
                case 'Mods':
                    FlxG.switchState(new ModsStoryMenu());
            }
        }
    }
}