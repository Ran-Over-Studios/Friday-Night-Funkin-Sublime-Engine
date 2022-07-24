package;

import sys.FileSystem;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		if (!FileSystem.exists("mods/images/characters/" + char + "/character.txt")){
			loadGraphic(Paths.image('iconGrid'), true, 150, 150);

			antialiasing = true;

			animation.add('bf', [0, 1], 0, false, isPlayer);
			animation.add('bf-car', [0, 1], 0, false, isPlayer);
			animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
			animation.add('bf-pixel', [21, 21], 0, false, isPlayer);
			animation.add('spooky', [2, 3], 0, false, isPlayer);
			animation.add('pico', [4, 5], 0, false, isPlayer);
			animation.add('mom', [6, 7], 0, false, isPlayer);
			animation.add('mom-car', [6, 7], 0, false, isPlayer);
			animation.add('tankman', [8, 9], 0, false, isPlayer);
			animation.add('face', [10, 11], 0, false, isPlayer);
			animation.add('dad', [12, 13], 0, false, isPlayer);
			animation.add('senpai', [22, 22], 0, false, isPlayer);
			animation.add('senpai-angry', [22, 22], 0, false, isPlayer);
			animation.add('spirit', [23, 23], 0, false, isPlayer);
			animation.add('bf-old', [14, 15], 0, false, isPlayer);
			animation.add('gf', [16], 0, false, isPlayer);
			animation.add('parents-christmas', [17], 0, false, isPlayer);
			animation.add('monster', [19, 20], 0, false, isPlayer);
			animation.add('monster-christmas', [19, 20], 0, false, isPlayer);

			if (!animation.exists(char)){
				char = 'bf';
			}

			animation.play(char);
			scrollFactor.set();
		}
		else{
			if (!FileSystem.exists("mods/images/characters/" + char + "/icons.png")){ //If Theres No Icons Then It Will Default To Face
				loadGraphic(Paths.image('iconGrid'), true, 150, 150);
				animation.add('face', [10, 11], 0, false, isPlayer);
				animation.play('face');
			} else {
				loadGraphic(openfl.display.BitmapData.fromFile("mods/images/characters/" + char + "/icons.png"), true, 150, 150);
				animation.add('anim', [0, 1], 0, false, isPlayer);
				animation.play('anim');
			}

			antialiasing = true;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
