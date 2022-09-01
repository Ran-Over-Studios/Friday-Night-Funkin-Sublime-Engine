package;

import flixel.util.FlxTimer;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

class ModsStoryMenu extends MusicBeatState{
    
    var intendedScore:Int;

    var curSelected:Int = 0;
    var curDifficulty:Int = 1;

    var optionsArray = [];
    var modLocationArray = [];

    var option:FlxText;
    var songTextList:FlxText;
    var highScoreText:FlxText;
    
    var difficultyText:FlxText;

    var optionGroup = new FlxTypedGroup<FlxText>();

    var loadingWeek:Bool = false;

    var camFollow:FlxSprite;

	override function create()
    {
        super.create();

        for (mods in SLModding.modsArray){
            if (mods != '' && mods != null && SLModding.readDirectory("mods/" + mods +"/weeks/") != null){
                for (week in SLModding.readDirectory("mods/" + mods +"/weeks/").filter(function(file:String):Bool{return file.indexOf(".txt") != -1;}))
                    {
                        if (week != null){
                            var weekShit = week.toString();
                            optionsArray.push(weekShit.substring(0, weekShit.length - 4));
                            modLocationArray.push(mods);
                            trace('weekshit');
                        }
                    }
            }
        }

        if (optionsArray.length == 0)
        {
            trace('no weeks found');
            FlxG.switchState(new MainMenuState());
        }

        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        createOptions();

        // add a black bar at the top of the screen
        var blackBar:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 64, FlxColor.BLACK);
        blackBar.scrollFactor.x = 0;
        blackBar.scrollFactor.y = 0;
        blackBar.setGraphicSize(FlxG.width, 64);
        blackBar.antialiasing = true;
        add(blackBar);

        // difficulty text on the black bar
        difficultyText = new FlxText(0, 0, FlxG.width, "Difficulty: Normal");
        difficultyText.setFormat("PhantomMuff 1.5", Std.int(FlxG.height * 0.03), 0xffffffff, "center");
        difficultyText.scrollFactor.x = 0;
        difficultyText.scrollFactor.y = 0;
        difficultyText.antialiasing = true;
        add(difficultyText);

        // high score text on the black bar top right
        highScoreText = new FlxText(0, 0, FlxG.width, "");
        highScoreText.setFormat("PhantomMuff 1.5", Std.int(FlxG.height * 0.03), 0xffffffff, "right");
        highScoreText.setPosition(FlxG.width - highScoreText.width, 32);
        highScoreText.scrollFactor.x = 0;
        highScoreText.scrollFactor.y = 0;
        highScoreText.antialiasing = true;
        add(highScoreText);

        camFollow = new FlxSprite(0, 0).makeGraphic(Std.int(optionGroup.members[0].width), Std.int(optionGroup.members[0].height), 0xAAFF0000);
		FlxG.camera.follow(camFollow, null, 0.06);
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

    function getHighscore(){
        var songTXT = SLModding.getContent("mods/" + modLocationArray[curSelected] + "/weeks/" + optionsArray[curSelected] + ".txt");
        var songList = songTXT.split(':');

        var weekNumber:Int = Std.parseInt(songList[0]);

        intendedScore = Highscore.getWeekScore(weekNumber, curDifficulty);
        highScoreText.text = "High Score: " + intendedScore;
        trace('highscore: ' + intendedScore + ' week: ' + weekNumber + ' difficulty: ' + curDifficulty);
    }

    override function update(elapsed)
    {
        super.update(elapsed);

        camFollow.screenCenter();
		if (optionGroup.members[curSelected] != null) {
			camFollow.y = optionGroup.members[curSelected].y - camFollow.height / 2;
		}

        if (highScoreText.text == "" && optionsArray.length > 0){
            getHighscore();
        }

        if (controls.UP_P && !loadingWeek){
            curSelected--;
            if (curSelected < 0) {
                curSelected = optionGroup.length - 1;
            }
            optionAlpha();
            getHighscore();
        }
        else if (controls.DOWN_P && !loadingWeek){
            curSelected++;
            if (curSelected >= optionGroup.length) {
                curSelected = 0;
            }
            optionAlpha();
            getHighscore();
        }

        if (controls.LEFT_P && !loadingWeek){
            if (curDifficulty > 0) {
                curDifficulty--;
            }
            getHighscore();
        }
        else if (controls.RIGHT_P && !loadingWeek){
            if (curDifficulty < CoolUtil.difficultyArray.length - 1) {
                curDifficulty++;
            }
            getHighscore();
        }

        difficultyText.text = "Difficulty: " + CoolUtil.difficultyArray[curDifficulty];

        switch(curDifficulty){
            case 0:
                difficultyText.color = FlxColor.GREEN;
            case 1:
                difficultyText.color = FlxColor.YELLOW;
            case 2:
                difficultyText.color = FlxColor.RED;
        }


        if (controls.BACK && !loadingWeek){
            FlxG.switchState(new StorySelectionState());
        }
        
        if (controls.ACCEPT && !loadingWeek){
            loadingWeek = true;

            FlxG.sound.play(Paths.sound('confirmMenu'));

            var songTXT = SLModding.getContent("mods/" + modLocationArray[curSelected] + "/weeks/" + optionsArray[curSelected] + ".txt");
            var songList = songTXT.split(':');

            var weekNumber:Int = Std.parseInt(songList[0]);
            songList.shift();

            
            // if songList has a empty string at the end, remove it
            if (songList[songList.length - 1] == "" || songList[songList.length - 1] == null) {
                songList.pop();
            }

            // if a song in songlist has a new line at the end, remove the new line
            for (i in 0...songList.length){
                if (songList[i].charAt(songList[i].length - 1) == "\n") {
                    songList[i] = songList[i].substring(0, songList[i].length - 1);
                }
            }

            trace("week: " + weekNumber + " songs: " + songList);

            PlayState.storyPlaylist = songList;
			PlayState.isStoryMode = true;

            var diffic:String = "";

            if (CoolUtil.difficultyArray.contains("NORMAL") && CoolUtil.difficultyArray[curDifficulty] == "NORMAL") { //HOW MANY TIMES DO I HAVE TO DO THIS AGGHHGHGAHSGAHGAHG
                diffic = "";
            } else {
                diffic = '-' + CoolUtil.difficultyArray[curDifficulty].toLowerCase();
            }

			PlayState.storyDifficulty = curDifficulty;

            PlayState.SONG = Song.loadFromModJson(PlayState.storyPlaylist[0].toLowerCase() + "/" + PlayState.storyPlaylist[0].toLowerCase() + diffic, null, modLocationArray[curSelected]);
			PlayState.storyWeek = weekNumber;
			PlayState.campaignScore = 0;

            SLModding.curLoaded = modLocationArray[curSelected];

            new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                    LoadingState.loadAndSwitchState(new PlayState(), true);
                });
        }
    }
}
