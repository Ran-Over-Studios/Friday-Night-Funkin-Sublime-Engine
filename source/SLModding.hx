package;

import openfl.media.Sound;
import lime.app.Application;
import lime.system.System;
import flixel.FlxG;
import cpp.StdString;
import openfl.Assets;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
#if android
import com.player03.android6.Permissions;
#end

class SLModding {

    public static var modsArray:Array<String> = [];
    public static var curLoaded:String;

    public static var isInitialized:Bool = false;

    static public function init():Void{
        var validMods:Int = 0;

        if (modsArray != []){
            isInitialized = false;
            modsArray = [];
        }

        #if android
        var permission:String = Permissions.READ_EXTERNAL_STORAGE;

		if(!Permissions.hasPermission(permission) && FlxG.save.data.allowMods)
			FlxG.save.data.allowMods = !FlxG.save.data.allowMods;
        #end

        for (modFolder in readDirectory("mods/")){
            trace(modFolder);

            if (fileExists('mods/$modFolder/mod.json')){
                modsArray.push(modFolder);
                validMods++;
            }
            else{
                /* i was gonna originally do this but i didn't see a point plus it would be buggy as fuck
                File.saveContent('mods/$modFolder/mod.json', Json.stringify({
                    "name": modFolder,
                    "description": "",
                    "author": "",
                    "version": "1.0"
                }));*/
            }
        }
        
        if (validMods > 0)
            isInitialized = true;
        else
            isInitialized = false;

        trace('Mods loaded! ' + modsArray);
    }

    static public function generatePath(mod:String = '', directory:String = null){
        if (mod == '')
            mod = curLoaded;

        if (directory != null)
            return 'mods/$mod/$directory/';
        else
            return 'mods/$mod/';
    }

    static public function getContent(path:String){
        #if desktop
        return File.getContent(path);
        #elseif mobile
        return File.getContent(System.documentsDirectory + 'SublimeEngine/' + path);
        #end
    }

    static public function fileExists(path:String){
        #if desktop
        return FileSystem.exists(path);
        #elseif mobile
        return FileSystem.exists(System.documentsDirectory + 'SublimeEngine/' + path);
        #end
    }

    static public function readDirectory(path:String){
        #if desktop
        return FileSystem.readDirectory(path);
        #elseif mobile
        trace(System.documentsDirectory + 'SublimeEngine/' + path);
        return FileSystem.readDirectory(System.documentsDirectory + 'SublimeEngine/' + path);
        #end
    }

    static public function getBitmap(path:String){
        #if desktop
        return openfl.display.BitmapData.fromFile(path);
        #elseif mobile
        return openfl.display.BitmapData.fromFile(System.documentsDirectory + 'SublimeEngine/' + path);
        #end
    }

    static public function getSound(path:String){
        #if desktop
        return Sound.fromFile(path);
        #elseif mobile
        return Sound.fromFile(System.documentsDirectory + 'SublimeEngine/' + path);
        #end
    }

    static public function parseModValue(wanted:String, mod:String = ''){
        if (mod == '')
            mod = curLoaded;

        var jsonString:String = getContent('mods/$mod/mod.json');
        var actualJson = Json.parse(jsonString);

        switch (wanted){
            default:
                return 'invalid lmao';
            case 'name':
                return actualJson.name;
            case 'description':
                return actualJson.description;
            case 'author':
                return actualJson.author;
            case 'version':
                return actualJson.version;
        }
    }
}