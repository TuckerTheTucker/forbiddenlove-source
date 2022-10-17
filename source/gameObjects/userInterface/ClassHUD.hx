package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import meta.CoolUtil;
import meta.InfoHud;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	var infoBar:FlxText; // small side bar like kade engine that tells you engine info
	var scoreBar:FlxText;

	var scoreLast:Float = -1;
	var scoreDisplay:String;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var SONG = PlayState.SONG;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	private var stupidHealth:Float = 0;

	public static var bfSideText:FlxText;
	public static var dadSideText:FlxText;
	var autoText:FlxText;

	var isWinning:Bool = false;

	private var timingsMap:Map<String, FlxText> = [];

	var font = Paths.font('southpark.ttf');

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// fnf mods
		var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;

		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar :)
		add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
				
		//a modified version of the bouncing icon thing shown in performance in vs ourple guy, kiwiquest/Cold_Vee if youre seeing this, make your source code public!! (thx eyedalehim <3)
		//this was originally just a test for another mod but jay (silentjheck) wanted me to keep it in so here yall go
		var originalPos:Float = iconP2.y;
		var firstTween:Void->Void = null;
		firstTween = function()
		{
			FlxTween.tween(iconP2, {y: iconP2.y - 25, angle: -5}, Conductor.crochet / 2000, {
				ease: FlxEase.circOut,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(iconP2, {y: originalPos, angle: 5}, Conductor.crochet / 2000, {
						ease: FlxEase.circIn,
						onComplete: function(twn:FlxTween)
						{
							iconP2.flipX = !iconP2.flipX;
							firstTween();
						}
					});
				}
			});
		}

		firstTween();

		scoreBar = new FlxText(FlxG.width / 2, healthBarBG.y + 40, 0, scoreDisplay, 20);
		scoreBar.setFormat(font, 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		updateScoreText();
		scoreBar.scrollFactor.set();
		add(scoreBar);

		var textY:Int = (Init.trueSettings.get('Downscroll') ? FlxG.height - 225 : 150);

		bfSideText = new FlxText(240, textY, 0, "<YOU>", 48);
		bfSideText.setFormat(font, 48, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		bfSideText.scrollFactor.set();
		if (Init.trueSettings.get('Centered Notefield')) {bfSideText.screenCenter(X);}
		bfSideText.alpha = 0;
		add(bfSideText);
		
		dadSideText = new FlxText(865, textY, 0, "<ERIC>", 48);
		dadSideText.setFormat(font, 48, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		dadSideText.scrollFactor.set();
		if (Init.trueSettings.get('Centered Notefield')) {dadSideText.visible = false;}
		dadSideText.alpha = 0;
		add(dadSideText);
	
		autoText = new FlxText(FlxG.width / 2, (Init.trueSettings.get('Downscroll') ? healthBarBG.y + 55 : healthBarBG.y - 75), 0, 'AUTOPLAY', 48);
		autoText.setFormat(scoreBar.font, 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		autoText.scrollFactor.set();
		autoText.screenCenter(X);
		add(autoText);
		FlxTween.tween(autoText, {alpha: 0.5}, 1, {ease: FlxEase.quadInOut, type: PINGPONG});

		// small info bar, kinda like the KE watermark
		// based on scoretxt which I will set up as well
		var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song) + ' - ' + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
		var engineDisplay:String = (PlayState.isStoryMode ? "" : "Press 6 for Autoplay");
		var engineBar:FlxText = new FlxText(0, FlxG.height - 30, 0, engineDisplay, 16);
		engineBar.setFormat(font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineBar.updateHitbox();
		engineBar.x = FlxG.width - engineBar.width - 5;
		engineBar.scrollFactor.set();
		add(engineBar);

		infoBar = new FlxText(5, FlxG.height - 30, 0, infoDisplay, 20);
		infoBar.setFormat(font, 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoBar.scrollFactor.set();
		add(infoBar);

		// counter
		if (Init.trueSettings.get('Counter') != 'None') {
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length) {
				var textAsset:FlxText = new FlxText(5 + (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0,
					'', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(font, counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}
		updateScoreText();
	}

	var counterTextSize:Int = 18;

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	var left = (Init.trueSettings.get('Counter') == 'Left');

	override public function update(elapsed:Float)
	{
		autoText.visible = PlayState.autoplay;
		scoreBar.visible = !PlayState.autoplay;

		// pain, this is like the 7th attempt
		healthBar.percent = (PlayState.health * 50);

		//yea i ported psych engine code to forever engine, sue me.
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80) {
			iconP2.animation.curAnim.curFrame = 1;
			isWinning = true;
		}
		else {
			iconP2.animation.curAnim.curFrame = 0;
			isWinning = false;
		}
	}

	private final divider:String = ' ~ ';

	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.misses;
		scoreBar.text = 'Score: $importSongScore';
		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			scoreBar.text += divider + 'Accuracy: ' + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
			scoreBar.text += divider + 'Combo Breaks: ' + Std.string(PlayState.misses);
			scoreBar.text += divider + 'Rank: ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}

		scoreBar.x = ((FlxG.width / 2) - (scoreBar.width / 2));

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys()) {
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		// update playstate
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	var schwing:Bool = false;

	public function beatHit()
	{
		if (!Init.trueSettings.get('Reduced Movements'))
			{
				iconP1.scale.set(1.2, 1.2);
				iconP2.scale.set(1.2, 1.2);
	
				iconP1.updateHitbox();
				iconP2.updateHitbox();
				
				if (isWinning) {
					schwing = !schwing;
					
					iconP1.angle = (schwing ? 3 : -3);
					iconP2.angle = (schwing ? -3 : 3);
				}
				else {
					iconP1.angle = 0;
					iconP2.angle = 0;
				}
			}
		//
	}
}
