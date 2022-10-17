package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import gameObjects.userInterface.menu.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;

using StringTools;

class CreditState extends MusicBeatState
{
	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var bg:FlxSprite;
	var bingus:FlxSprite;
	var frontRow:FlxSprite;
	var midRow:FlxSprite;
	var backRow:FlxSprite;
	var sideBar:FlxSprite;
	var nameText:FlxText;
	var descText:FlxText;
	var pauseText:FlxText;
	var red:FlxSprite;

	var curSelected:Int = 0;
	var inView:Bool = false;
	var camFollow:FlxObject;
	var mm:Int = 1;
	var defaultCamZoom:Float = 1.00;

	var peopleArray:Array<Dynamic> = [
		['SilentJheck', 'Director, Artist, & Animator'],
		["TuckerTheTucker", "Coder & Animator"],
		["Fidget Spinners Animations", "Main Week & Credits Composer"],
		["CarlosisST", "Charter & Lifeless Playtester"],
		["thriftysoles", "Main Menu Composer"],
		["HowToAvenge101", "Game Over Composer"],
		["LuciDin", "Opening Cutscene Voice Actor"],
		["Kahpot Vanilla", "Gave us his Jew Blessing"]
	];

	var font = Paths.font('southpark.ttf');

	override function create()
	{		
		super.create();

		// create the game camera
		camGame = new FlxCamera();

		// create the hud camera (separate so the text stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
	
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/base/credits/Credit_bg'));
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.screenCenter();
		add(bg);
		
		bingus = new FlxSprite(1120, 172);
		bingus.frames = Paths.getSparrowAtlas('menus/base/credits/bingus');
		bingus.animation.addByPrefix('blink', 'bingusblink', 24, false);
		bingus.setGraphicSize(Std.int(bingus.width * 0.8));
		add(bingus);
		bingus.animation.play('blink');

		backRow = new FlxSprite(0, 355).loadGraphic(Paths.image('menus/base/credits/BackRow'));
		backRow.screenCenter(X);
		add(backRow);

		midRow = new FlxSprite(0, 295);
		midRow.frames = Paths.getSparrowAtlas('menus/base/credits/MidRow');
		midRow.animation.addByPrefix('idle', 'mid no blink', 24, false);
		midRow.animation.addByPrefix('blink1', 'Luci blink', 24, false);
		midRow.animation.addByPrefix('blink2', 'avenge blink', 24, false);
		midRow.animation.addByPrefix('blink3', 'thirft blink', 24, false);
		midRow.animation.addByPrefix('blink4', 'vanilla blink', 24, false);
		midRow.screenCenter(X);
		add(midRow);
		midRow.animation.play('idle');

		frontRow = new FlxSprite(0, 300);
		frontRow.frames = Paths.getSparrowAtlas('menus/base/credits/FrontRow');
		frontRow.animation.addByPrefix('idle', 'Frontblink0', 24, false);
		frontRow.animation.addByPrefix('blink1', 'Frontblink1', 24, false);
		frontRow.animation.addByPrefix('blink2', 'Frontblink2', 24, false);
		frontRow.animation.addByPrefix('blink3', 'Frontblink3', 24, false);
		frontRow.animation.addByPrefix('blink4', 'Frontblink4', 24, false);
		frontRow.screenCenter(X);
		add(frontRow);
		frontRow.animation.play('idle');

		sideBar = new FlxSprite(FlxG.width + 200).loadGraphic(Paths.image('menus/base/credits/sideBar'));
		sideBar.scrollFactor.set();
		sideBar.cameras = [camHUD];
		add(sideBar);
		
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		nameText = new FlxText(400, 100, 512, 'penis', 36);
		nameText.cameras = [camHUD];
		nameText.font = font;
		nameText.color = FlxColor.BLACK;
		nameText.alignment = FlxTextAlign.CENTER;
		nameText.angle = -1;
		nameText.scrollFactor.set();
		add(nameText);

		descText = new FlxText(400, 170, 512, 'penis', 32);
		descText.cameras = [camHUD];
		descText.font = font;
		descText.color = FlxColor.BLACK;
		descText.alignment = FlxTextAlign.CENTER;
		descText.scrollFactor.set();
		add(descText);

		pauseText = new FlxText(5, FlxG.height - 25, 0, "Press LEFT or RIGHT to view Characters.", 16);
		pauseText.cameras = [camHUD];
		pauseText.font = font;
		pauseText.borderStyle = FlxTextBorderStyle.OUTLINE;
		pauseText.borderSize = 2;
		pauseText.scrollFactor.set();
		add(pauseText);

		red = new FlxSprite().makeGraphic(25, 25, FlxColor.RED);
		red.visible = false;
		add(red);
		//red
		changeChar(0);

		FlxG.sound.playMusic(Paths.music('creditsMusic'), 0);
		FlxG.sound.music.fadeIn(2, 0, 0.6);
	}

	var camLerp = Main.framerateAdjust(0.10);
	
	override function update(elapsed:Float)
	{		
		super.update(elapsed);

		red.x = camFollow.x;
		red.y = camFollow.y;

		if (FlxG.keys.justPressed.G)
			trace(camFollow.x + ', ' + camFollow.y);

		nameText.x = sideBar.x + 50;
		descText.x = sideBar.x + 50;

		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, camLerp);

		if (controls.UI_LEFT_P)
		{
			if (inView) {
				changeChar(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else {	
				defaultCamZoom += 1;
				FlxTween.tween(sideBar, {x: (FlxG.width / 2) + 50}, 0.6, {ease: FlxEase.quadInOut});
				FlxG.camera.follow(camFollow, null, camLerp);
				changeChar(0);
				inView = true;
			}
		}

		if (controls.UI_RIGHT_P)
		{
			if (inView) {
				changeChar(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else {	
				defaultCamZoom += 1;
				FlxTween.tween(sideBar, {x: (FlxG.width / 2) + 50}, 0.6, {ease: FlxEase.quadInOut});
				FlxG.camera.follow(camFollow, null, camLerp);
				changeChar(0);
				inView = true;
				if (curSelected >= 4)
					FlxTween.tween(frontRow, {alpha: 0}, 0.6, {ease: FlxEase.quadInOut});
			}
		}
			
		if (FlxG.random.bool(0.6))
			bingus.animation.play('blink');
		if (FlxG.random.bool(0.8))
			frontRow.animation.play('blink' + FlxG.random.int(1, 4));
		if (FlxG.random.bool(0.3))
			midRow.animation.play('blink' + FlxG.random.int(1, 4));

		if (frontRow.animation.curAnim.name.startsWith('blink') && frontRow.animation.curAnim.finished)
			frontRow.animation.play('idle');
		if (midRow.animation.curAnim.name.startsWith('blink') && midRow.animation.curAnim.finished)
			midRow.animation.play('idle');
		
		if (controls.BACK) {
			if (inView) {
				defaultCamZoom -= 1;
				FlxTween.tween(sideBar, {x: FlxG.width + 200}, 0.6, {ease: FlxEase.quadInOut});
				camFollow.screenCenter();
				inView = false;
				FlxTween.tween(frontRow, {alpha: 1}, 0.6, {ease: FlxEase.quadInOut});
			}
			else {
				Main.switchState(this, new MainMenuState());
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
		}
	}

	function changeChar(gaysex:Int)
	{
		curSelected += gaysex;

		if (curSelected > 7)
			curSelected = 7;
		if (curSelected < 0)
			curSelected = 0;

		if (curSelected >= 4)
			FlxTween.tween(frontRow, {alpha: 0}, 0.6, {ease: FlxEase.quadInOut});
		else
			FlxTween.tween(frontRow, {alpha: 1}, 0.6, {ease: FlxEase.quadInOut});

		switch(curSelected)
		{
			case 0:
				camFollow.setPosition(350, 450);
			case 1:
				camFollow.setPosition(570, 450);
			case 2:
				camFollow.setPosition(820, 450);
			case 3:
				camFollow.setPosition(1070, 450);
			case 4:
				camFollow.setPosition(310, 420);
			case 5:
				camFollow.setPosition(450, 420);
			case 6:
				camFollow.setPosition(1000, 420);
			case 7:
				camFollow.setPosition(1170, 420);
		}
		nameText.text = peopleArray[curSelected][0];
		descText.text = peopleArray[curSelected][1];
	}
}