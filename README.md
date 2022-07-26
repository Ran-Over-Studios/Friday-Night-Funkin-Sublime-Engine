# Friday Night Funkin - Friday Night Funkin' Sublime Engine

This is the repository for FNFSL Engine.

![alt text](https://github.com/SpunBlue/Friday-Night-Funkin-Sublime-Engine/blob/master/assets/shared/images/sublimeengine.png?raw=true)

## About FNFSL
FNFSL is a Friday Night Funkin' engine designed to not change everything about Friday Night Funkin' but still having new options and new features, Good for Modders who prefer a smaller engine that isn't terribly bloated with unnecessary options and features. Please keep in mind that this is being programmed by someone who isn't great at Haxe and can't do everything.
 
You can find it on GameJolt here: https://gamejolt.com/games/Friday-Night-Funkin-Sublime-Engine/702060

You can also find it on GameBanana here: https://gamebanana.com/mods/382076

## But why should you use this engine?
Well let me list out a few reasons why:
* We listen to the users who use ths Engine and try to add whatever cool features you recommend us adding.
* We try to not give up while fixing bugs and adding features.
* We have Cutscene Support (Windows & Linux Only).
* We have a pretty good Input System.

If this hasn't convinced you, Then i don't mind. You really don't have to use this engine.
 
## Special Thanks
Special Thanks to ThePercentageGuy for giving me Ownership of NUFNF which started this Engine.
I also want to thank everyone who has helped me make this Engine better, Thank you.

## Building
First, you need to install Haxe and HaxeFlixel.
1. [Install Haxe 4.2.5](https://haxe.org/download/) (Make sure you are on the most recent version of Haxe)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe

Other installations you'd need are the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:
```
flixel
flixel-addons
flixel-ui
hscript
newgrounds
```
So for each of those type `haxelib install [library]` so shit like `haxelib install newgrounds`

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
3. Run `haxelib git polymod https://github.com/larsiusprime/polymod.git` to install Polymod, However this is not required and can be removed from Project.xml.
4. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` to install Discord RPC.
5. Run `haxelib git hxCodec https://github.com/polybiusproxy/hxCodec` to install Video Cutscene Support.

You should have everything ready for compiling the game! Follow the guide below to continue!

At the moment, you can optionally fix the transition bug in songs with zoomed-out cameras.
- Run `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons` in the terminal/command-prompt.

you should be done after all of those steps are completed.

Once you have all those installed, it's pretty easy to compile the game. You just need to run `lime test html5 -debug` in the root of the project to build and run the HTML5 version. (command prompt navigation guide can be found here: [https://ninjamuffin99.newgrounds.com/news/post/1090480](https://ninjamuffin99.newgrounds.com/news/post/1090480))
To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run `lime test linux -debug` and then run the executable file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2022. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2022 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)

Once that is done you can open up a command line in the project's directory and run `lime test windows -debug`. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin
As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.

## Wiki & Discord
 [Wiki](https://github.com/SpunBlue/Friday-Night-Funkin-Sublime-Engine/wiki) | [Discord Server](https://discord.gg/wdNrAPxcHN)
