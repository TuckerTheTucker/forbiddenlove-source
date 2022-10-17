package meta.state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import meta.state.menus.*;
import openfl.Assets;

using StringTools;

/**
	I hate this state so much that I gave up after trying to rewrite it 3 times and just copy pasted the original code
	with like minor edits so it actually runs in forever engine. I'll redo this later, I've said that like 12 times now

	I genuinely fucking hate this code no offense ninjamuffin I just dont like it and I don't know why or how I should rewrite it
**/
class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var disclaimerText:FlxSprite;

	var cutscene1:FlxSprite;
	var cutscene2:FlxSprite;
	var cutscene3:FlxSprite;

	var cutText:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var cacheMusic:Array<String> = [
		'start',
		'loop',
		'end'
	];

	override public function create():Void
	{
		controls.setKeyboardScheme(None, false);
		curWacky = FlxG.random.getObject(getIntroTextShit());
		super.create();

		startDisclaimer(); //first we start the disclaimer
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var move:Bool = false;
	var skippedCutscene:Bool = false;
	var curDialogue:Int = 1;

	function startDisclaimer()
		{
			// create the game camera
			camGame = new FlxCamera();

			// create the hud camera (separate so theres some depth with the logo and bg)
			camHUD = new FlxCamera();
			camHUD.bgColor.alpha = 0;
				
			FlxG.cameras.reset(camGame);
			FlxG.cameras.add(camHUD);
			FlxCamera.defaultCameras = [camGame];

			disclaimerText = new FlxSprite();
			disclaimerText.frames = Paths.getSparrowAtlas('menus/base/title/disclaimer');
			disclaimerText.animation.addByPrefix('idle', 'disclaimer0', 24);
			disclaimerText.screenCenter();
			disclaimerText.alpha = 0;
			add(disclaimerText);
			disclaimerText.animation.play('idle');
			
			FlxTween.tween(disclaimerText, {alpha: 1}, 0.3, {ease: FlxEase.quadInOut});
			
			new FlxTimer().start(8, function(tmr:FlxTimer)
			{
				if (!move) {
					disclaimerText.visible = false;
					startCutscene(); //then we start the CUTSCENE
					move = true;
				}
			});
		}
	
	function startCutscene() //i hate my life
	{
		FlxG.camera.fade(FlxColor.BLACK, 1, true);
		cutscene3 = new FlxSprite(0, 0).loadGraphic(Paths.image('cutscene/intro/frame_three'));
		add(cutscene3);

		cutscene2 = new FlxSprite(0, 0).loadGraphic(Paths.image('cutscene/intro/frame_two'));
		add(cutscene2);
		
		cutscene1 = new FlxSprite(0, 0).loadGraphic(Paths.image('cutscene/intro/frame_one'));
		add(cutscene1);

		cutText = new FlxSprite(200, 550);
		cutText.frames = Paths.getSparrowAtlas('cutscene/intro/text_sheet');
		cutText.animation.addByPrefix('text1', 'text1', 24);
		cutText.animation.addByPrefix('text2', 'text2', 24);
		cutText.animation.addByPrefix('text3', 'text3', 24);
		cutText.animation.addByPrefix('text4', 'text4', 24);
		cutText.animation.addByPrefix('text5', 'text5', 24);
		cutText.screenCenter(X);
		add(cutText);
		cutText.animation.play('text1', true);

		if (!skippedCutscene)
			FlxG.sound.play(Paths.sound('intro/dialogue' + curDialogue));

		FlxTween.tween(cutscene1, {x: cutscene1.x - 300}, 14, {ease: FlxEase.linear});
		new FlxTimer().start(3.5, function(tmr:FlxTimer)
		{
			cutText.animation.play('text2', true);
			curDialogue++;
			if (!skippedCutscene)
				FlxG.sound.play(Paths.sound('intro/dialogue' + curDialogue));

		});
		new FlxTimer().start(10, function(tmr:FlxTimer)
		{
			FlxTween.tween(cutscene1, {alpha: 0}, 1, {ease: FlxEase.linear});
			FlxTween.tween(cutscene2, {y: cutscene2.y - 270}, 14, {ease: FlxEase.linear});
			cutText.animation.play('text3', true);
			curDialogue++;
			if (!skippedCutscene)
				FlxG.sound.play(Paths.sound('intro/dialogue' + curDialogue));
			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				cutText.animation.play('text4', true);
				curDialogue++;
				if (!skippedCutscene)
					FlxG.sound.play(Paths.sound('intro/dialogue' + curDialogue));
			});
			new FlxTimer().start(12, function(tmr:FlxTimer)
			{
				FlxTween.tween(cutscene2, {alpha: 0}, 1, {ease: FlxEase.linear});
				cutText.setGraphicSize(Std.int(cutText.width * 0.6));
				cutText.animation.play('text5', true);
				curDialogue++;
				if (!skippedCutscene)
					FlxG.sound.play(Paths.sound('intro/dialogue' + curDialogue));
				new FlxTimer().start(12, function(tmr:FlxTimer)
				{
					if (!skippedCutscene) {
						cutscene3.alpha = 0;
						startIntro();
						skippedCutscene = true;
					}
				});
			});
		});
	}

	function startIntro()
	{
		if (!initialized)
		{
			///*
			#if !html5
			Discord.changePresence('TITLE SCREEN', 'Main Menu');
			#end
		}

		persistentUpdate = true;

		for (m in cacheMusic) { //im telling you its important to preload the game over stuff in the title screen for a seamless beginning to loop transition
			FlxG.sound.cache(Paths.music('gameOverShit/' + m));
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menus/base/title/bg"));
		add(bg);

		logoBl = new FlxSprite(0, 0);
		logoBl.frames = Paths.getSparrowAtlas('menus/base/title/logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByIndices('bump', 'logobump', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
		logoBl.animation.addByIndices('press', 'logobump', [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25], "", 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		logoBl.screenCenter();
		logoBl.cameras = [camHUD];
		add(logoBl);
		logoBl.alpha = 0;
		// logoBl.color = FlxColor.BLACK;

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('menus/base/title/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.cameras = [camHUD];
		add(titleText);
		titleText.alpha = 0;

		// var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/base/title/logo'));
		// logo.screenCenter();
		// logo.antialiasing = true;
		// add(logo);

		FlxTween.tween(logoBl, {y: logoBl.y + 5}, 1.2, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		credGroup.cameras = [camHUD];
		add(credGroup);
		textGroup = new FlxGroup();
		textGroup.cameras = [camHUD];

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.cameras = [camHUD];
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.cameras = [camHUD];
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('menus/base/title/newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});
		FlxTween.tween(titleText, {angle: titleText.angle + 1}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		ForeverTools.resetMenuMusic(true);
		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var swagGoodArray:Array<Array<String>> = [];
		if (Assets.exists(Paths.txt('introText')))
		{
			var fullText:String = Assets.getText(Paths.txt('introText'));
			var firstArray:Array<String> = fullText.split('\n');

			for (i in firstArray)
				swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (move && !skippedCutscene)
			cutText.screenCenter(X);

		if (FlxG.keys.justPressed.SPACE) {
			if (!move) {
				disclaimerText.visible = false;
				startCutscene();
				move = true;
			}
			else {
				if (!skippedCutscene) {
					cutscene1.alpha = 0;
					cutscene2.alpha = 0;
					cutscene3.alpha = 0;
					startIntro();
					skippedCutscene = true;
				}
			}
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		// camera stuffs
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.95);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.animation.play('press');
			logoBl.animation.play('press');
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				// Check if version is outdated

				var version:String = "v" + Application.current.meta.get('version');
				/*
					if (version.trim() != NGio.GAME_VER_NUMS.trim() && !OutdatedSubState.leftState)
					{
						FlxG.switchState(new OutdatedSubState());
						trace('OLD VERSION!');
						trace('old ver');
						trace(version.trim());
						trace('cur ver');
						trace(NGio.GAME_VER_NUMS.trim());
					}
					else
					{ */
				Main.switchState(this, new MainMenuState());
				// }
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		// hi game, please stop crashing its kinda annoyin, thanks!
		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (logoBl.animation.curAnim.name != 'press')
			logoBl.animation.play('bump');

		if(!Init.trueSettings.get('Reduced Movements'))
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:
				createCoolText(['the forbidden love crew']);

			// credTextShit.visible = true;
			case 3:
				addMoreText('present');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['and to everyone', 'in']);
			case 7:
				addMoreText('the fnfmc server');
			// credTextShit.text += '\nNewgrounds';

			case 8:
				deleteCoolText();
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('FNF');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Forbidden');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Love'); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 2);
			FlxTween.tween(logoBl, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
			FlxTween.tween(titleText, {alpha: 1}, 1, {ease: FlxEase.quadInOut});
			remove(credGroup);
			skippedIntro = true;
		}
		//
	}
}
