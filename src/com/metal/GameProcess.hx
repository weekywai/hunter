package com.metal;
import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.Sfx;
import com.metal.component.BagpackSystem;
import com.metal.component.BattleSystem;
import com.metal.component.GameSchedual;
import com.metal.component.RewardSystem;
import com.metal.component.TaskSystem;
import com.metal.component.TriggerSystem;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.manager.ResourceManager;
import com.metal.manager.UIManager;
import com.metal.message.MsgUI;
import com.metal.message.MsgView;
import com.metal.proto.manager.RandomNameManager;
import com.metal.scene.GameFactory;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.board.impl.GameBoard;
import com.metal.scene.board.impl.GameMap;
import com.metal.scene.board.support.GameScene;
import com.metal.scene.board.view.Camera;
import com.metal.scene.board.view.ViewBoard;
import com.metal.scene.bullet.impl.BulletComponent;
import com.metal.scene.effect.impl.EffectComponent;
import de.polygonal.core.es.MainLoop;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.sys.SimEntity;
import de.polygonal.core.time.Timebase;
import motion.actuators.SimpleActuator;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
#if telemetry
import hxtelemetry.HxTelemetry;
#end
/**
 * ...
 * @author weeky
 */
class GameProcess implements IObserver
{
	public static var instance(default, null):GameProcess = new GameProcess();
	
	public var tick(default, null):MainLoop;
	
	public static var rootStage(default, null):Sprite;
	public static var gameStage(default, null):Sprite;
	
	public static var root(default, null):SimEntity;
	public static var UIRoot(default, null):SimEntity;
	/** send message to UIManager */
	public static function SendUIMsg(type:Int, userData:Dynamic = null)
	{
		UIRoot.sendMMsg(type, userData);
	}
	/** notify UIManager compent */
	public static function NotifyUI(type:Int, userData:Dynamic = null)
	{
		UIRoot.notify(type, userData);
	}
	
	public static var render(default, null):Engine;
	
	public static var console(default, null):DevCheat;
	#if telemetry
	public static var HXT:HxTelemetry;
	#end
	
	//private var onDrawId:Int = 0;
	private var _debugTxt:TextField;
	private var _fps:FPS;
	private var _loop:MainLoop;
	private var _board:SimEntity;
	private var _render:Bool = false;
	public function new() {}
	
	public function init(stage:Stage, container:Sprite)
	{
		console = new DevCheat();
		preload();
		rootStage = container;
		gameStage = new Sprite();
		rootStage.addChild(gameStage);
		
		#if telemetry
		var cfg = new hxtelemetry.HxTelemetry.Config();
		cfg.host = "192.168.1.100";
		cfg.allocations = false;
		HXT = new HxTelemetry(cfg);
		#end
		
		initEngine();
		root = new SimEntity("Game", true, true);
		UIRoot = new UIManager();
		root.addComponent(new GameSchedual());
		
		root.add(UIRoot);
		_loop = new MainLoop();
		_loop.add(root);
		root.outgoingMessage.o = rootStage;
		//trace(StringTools.hex(MsgView.SetParent)+"-"+ (MsgView.SetParent>>8));
		root.sendMessageToChildren(MsgView.SetParent, true);
		
		//#if !mobile
		_debugTxt = new TextField();
		_debugTxt.defaultTextFormat = new TextFormat(null, 18, 0xffffff);
		_debugTxt.y = 40;
		_debugTxt.autoSize = TextFieldAutoSize.LEFT;
		stage.addChild(_debugTxt);
		_fps = new FPS(10, 65, 0xffffff);
		stage.addChild(_fps);
		Timebase.attach(this);
		
		#if actuate_manual_time
		SimpleActuator.getTime = function() { return Timebase.stamp(); }
		#end
	}
	
	/** after login */
	public function initGame():Void
	{
		root.addComponent(new BagpackSystem());
		root.addComponent(new GameFactory());
		root.addComponent(new TaskSystem());
		root.addComponent(new BattleSystem());
		root.addComponent(new RewardSystem());
		//TODO 发送启动
		trace("initGame");
		new LoadSource();
		UIRoot.sendMMsg(MsgUI.MainPanel, true);
	}
	
	private function initEngine():Void
	{
		var _stageWidth:Int = Lib.current.stage.stageWidth;
		var _stageHeight:Int = Lib.current.stage.stageHeight;
		//trace(_stageWidth + "::" + _stageHeight+">> scale:"+Main.Scale);
		var baseGameWidth = Std.int(_stageWidth / Main.Scale);
		var baseGameHeight = Std.int(_stageHeight /  Main.Scale);
		render = new Engine(baseGameWidth, baseGameHeight);
		//render.scaleX = render.scaleY = Main.Scale;
		//DC.log("scale :" + render.scaleX + " : " +_stageWidth +":"+ baseGameWidth+" h:"+_stageHeight +":"+ baseGameHeight);
		HXP.scene = new GameScene();
		//rootStage.addChildAt(render, 0);
		gameStage.addChild(render);
		_render = true;
	}
	public function onUpdate(type:Int, source:IObservable, userData:Dynamic)
	{
		rootStage.stage.setChildIndex(_debugTxt, rootStage.stage.numChildren - 1);
		rootStage.stage.setChildIndex(_fps, rootStage.stage.numChildren - 1);
		_debugTxt.text = "fps: " + Timebase.fps + " Mem:" + HXP.round(System.totalMemory / 1024 / 1024, 2) + "MB";
		//+ "\nrealDelta:" + TimeBase.timeDelta + "\ngameDelta:" +Timebase.gameTimeDelta;
		//+ "\nRealTime::" + Timebase.realTime + "\nGameTime:" +Timebase.gameTime;
		#if actuate_manual_update
		//if (onDrawId == 0)
			SimpleActuator.stage_onEnterFrame (null);
		#end
		if (_render)
			update();
	}
	private function update()
	{
		render.updateEngine();
		//#if actuate_manual_update
		//SimpleActuator.stage_onEnterFrame (null);
		//#end
		
		#if telemetry
		HXT.advance_frame();
		#end
	}
	
	public function startGame():Void
	{
		_board = new SimEntity("GameBoard");
		_board.addComponent(new GameBoard());
		_board.addComponent(new GameMap());
		_board.addComponent(new ViewBoard());
		_board.addComponent(new Camera());
		_board.addComponent(new TriggerSystem());
		_board.addComponent(new BulletComponent());
		_board.addComponent(new EffectComponent());
		_board.addComponent(new BattleResolver());
		_board.drawable = true;
		root.add(_board);
		//onDrawId = 1;
		
		#if debug
        HXP.console.enable();
		#end
	}
	
	public function endGame():Void 
	{
		trace("endGame");
		_board.free();
		Sfx.stopAllSound();
		HXP.scene.end();
		ResourceManager.instance.unLoadAll();
		
		//var gamebord:Entity = root.findChild("GameBoard");
		//root.remove(_board);
	}
	
	public function pauseGame(pause:Bool)
	{
		render.paused = pause;
		_loop.paused = pause;
		if(!pause)
			render.updateEngine();
	}
	public function isPausing():Bool
	{
		return render.paused;
	}
	
	private function preload():Void 
	{
		new SfxManager();
		RandomNameManager.instance.appendXml(Xml.parse(Assets.getText(ResPath.getProto("randomlynamed"))));
	}
}