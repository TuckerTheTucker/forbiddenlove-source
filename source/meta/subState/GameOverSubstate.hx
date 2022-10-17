package meta.subState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import gameObjects.Boyfriend;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.Conductor.BPMChangeEvent;
import meta.data.Conductor;
import meta.state.*;
import meta.state.menus.*;

class GameOverSubstate extends MusicBeatSubState
{
	//
	var bf:FlxSprite;
	var camFollow:FlxObject;
	var stageSuffix:String = "";

	var musicStart:FlxSound;
	var musicLoop:FlxSound;

	var bg:FlxSprite;
	var gameOver:FlxSprite;
	var hover:FlxSprite;
	var menu:FlxSprite;
	var retry:FlxSprite;

	var goTex = Paths.getSparrowAtlas('menus/base/gameOverASSETS');
	var stopGlitching:Bool = false;

	var goArray:Array<Dynamic> = [];
	var curSelect:Int = 0;

	var deathSound:FlxSound;

	public function new(x:Float, y:Float)
	{
		super();

		Conductor.songPosition = 0;

		bf = new FlxSprite(x, y);
		bf.frames = Paths.getSparrowAtlas('characters/kyledeath');
		bf.setGraphicSize(Std.int(bf.width * 0.9));
		bf.animation.addByPrefix('kiss', 'eric kiss gay', 24, false);
		add(bf);

		PlayState.boyfriend.destroy();

		bg = new FlxSprite(0, 0);
		bg.frames = goTex;
		bg.animation.addByPrefix('idle', 'bg0', 24, false);
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.45));
		bg.screenCenter();
		bg.alpha = 0;
		goArray.push(bg);
		bg.animation.play('idle');

		gameOver = new FlxSprite(430, 100);
		gameOver.frames = goTex;
		gameOver.animation.addByPrefix('idle', 'gameOver0', 24, false);
		gameOver.scrollFactor.set();
		gameOver.setGraphicSize(Std.int(gameOver.width * 1.45));
		gameOver.alpha = 0;
		goArray.push(gameOver);
		gameOver.animation.play('idle');

		hover = new FlxSprite(510, 550);
		hover.frames = goTex;
		hover.animation.addByPrefix('idle', 'hover0', 24, false);
		hover.scrollFactor.set();
		hover.setGraphicSize(Std.int(hover.width * 1.45));
		hover.alpha = 0;
		goArray.push(hover);
		hover.animation.play('idle');

		retry = new FlxSprite(625, 550);
		retry.frames = goTex;
		retry.animation.addByPrefix('idle', 'retryButton0', 24, false);
		retry.animation.addByPrefix('select', 'retryButton-select0', 24, false);
		retry.scrollFactor.set();
		retry.setGraphicSize(Std.int(retry.width * 1.45));
		retry.alpha = 0;
		goArray.push(retry);
		retry.animation.play('idle');

		menu = new FlxSprite(625, 660);
		menu.frames = goTex;
		menu.animation.addByPrefix('idle', 'menuButton0', 24, false);
		menu.animation.addByPrefix('select', 'menuButton-select0', 24, false);
		menu.scrollFactor.set();
		menu.setGraphicSize(Std.int(menu.width * 1.45));
		menu.alpha = 0;
		goArray.push(menu);
		menu.animation.play('idle');

		musicStart = new FlxSound().loadEmbedded(Paths.music('gameOverShit/start'), false, false);
		musicLoop = new FlxSound().loadEmbedded(Paths.music('gameOverShit/loop'), true, false);
		
		FlxG.sound.list.add(musicStart);
		FlxG.sound.list.add(musicLoop);

		for (assets in goArray){
			add(assets);
		}

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y- 160, 1, 1);
		add(camFollow);

		deathSound = FlxG.sound.load(Paths.sound('Waterphone' + stageSuffix));
		deathSound.persist = true;
		Conductor.changeBPM(95);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.animation.play('kiss');
	}

	var loop:Bool = false;
	var hasBeenPlayed:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!deathSound.playing && !hasBeenPlayed) {
			deathSound.play();
			hasBeenPlayed = true;
		}

		if (musicLoop.playing)
			Conductor.songPosition = musicLoop.time;
		else if (musicStart.playing)
			Conductor.songPosition = musicStart.time;

		FlxTween.tween(gameOver, {angle: gameOver.angle + 1}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.camera.zoom = FlxMath.lerp(PlayState.defaultCamZoom, FlxG.camera.zoom, 0.95);

		if (controls.UI_UP_P) {
			changeSel(-1);
		}

		if (controls.UI_DOWN_P) {
			changeSel(1);
		}

		if (controls.ACCEPT)
			endBullshit();

		if (bf.animation.curAnim.name == 'kiss' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim.name == 'kiss' && bf.animation.curAnim.finished) {
			new FlxTimer().start(1.2, function(timer:FlxTimer) {
				if (!stopGlitching) {
					showUI();
					stopGlitching = true;
				}
			});
		}
	}

	override function beatHit()
	{
		super.beatHit();		
		
		FlxG.camera.zoom += 0.015;

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!uiShown)
			return;
		
		if (!isEnding)
		{
			if (curSelect == 0) {
				FlxG.sound.play(Paths.music('gameOverShit/end'));
				musicStart.stop();
				musicLoop.stop();
			}
			else {
				musicStart.fadeOut((curSelect == 0 ? 2.9 : 1.8), 0);
				musicLoop.fadeOut((curSelect == 0 ? 2.9 : 1.8), 0);
			}
			isEnding = true;
			FlxG.camera.fade(FlxColor.BLACK, (curSelect == 0 ? 2.9 : 1.8), false, function()
			{
				if (curSelect == 0) {
					Main.switchState(this, new PlayState());
				}
				else {
					if (PlayState.isStoryMode)
						Main.switchState(this, new StoryMenuState());
					else
						Main.switchState(this, new FreeplayState());
				}
			});
			//
		}
	}

	var uiShown:Bool = false;

	function showUI():Void
	{
		uiShown = true;
		bf.visible = false;
		for (assets in goArray){
			FlxTween.tween(assets, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut});
		}
		musicStart.play();
		musicStart.onComplete = () -> musicLoop.play();
		changeSel(0, false);
	}

	function changeSel(penis:Int, includeSound:Bool = true)
	{
		if (!uiShown || isEnding)
			return;

		curSelect += penis;
		if (curSelect >= 2) {
			curSelect = 0;
		}
		if (curSelect < 0) {
			curSelect = 1;
		}

		if (includeSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.8);

		if (curSelect == 0) {
			menu.animation.play('idle');
			retry.animation.play('select');
			FlxTween.tween(hover, {y: retry.y}, 0.1, {ease: FlxEase.quadOut});
		}
		if (curSelect == 1) {
			menu.animation.play('select');
			retry.animation.play('idle');
			FlxTween.tween(hover, {y: menu.y}, 0.1, {ease: FlxEase.quadOut});
		}
	}
}
