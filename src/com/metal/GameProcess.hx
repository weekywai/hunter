package com.metal;
import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.Sfx;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.metal.component.BagpackSystem;
import com.metal.component.BattleSystem;
import com.metal.component.GameSchedual;
import com.metal.component.RewardSystem;
import com.metal.component.TaskSystem;
import com.metal.component.TriggerSystem;
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
import de.polygonal.core.sys.SimEntity;
import de.polygonal.core.time.Timebase;
import motion.actuators.SimpleActuator;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
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
class GameProcess extends MainLoop
{
	public static var instance(get, null):GameProcess;// = new GameProcess();
	
	public static var rootStage(default, null):Sprite;
	public static var gameStage(default, null):Sprite;
	
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
	
	private var _debugTxt:TextField;
	private var _fps:FPS;
	private var _board:SimEntity;
	private var _render:Bool = false;
	
	static private function get_instance() {
		if (instance == null)
			instance = new GameProcess();
		return instance;
	}
	
	public function new() {
		super();
	}
	
	public function onInit(container:Sprite)
	//public function init(stage:Stage, container:Sprite)
	{
		//console = new DevCheat();
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
		UIRoot = new UIManager();
		addComponent(new GameSchedual());
		
		add(UIRoot);
		outgoingMessage.o = rootStage;
		sendMessageToChildren(MsgView.SetParent, true);
		
		//#if !mobile
		_debugTxt = new TextField();
		_debugTxt.defaultTextFormat = new TextFormat(null, 18, 0xffffff);
		_debugTxt.y = 40;
		_debugTxt.autoSize = TextFieldAutoSize.LEFT;
		rootStage.stage.addChild(_debugTxt);
		_fps = new FPS(10, 65, 0xffffff);
		rootStage.stage.addChild(_fps);
		
		#if actuate_manual_time
		SimpleActuator.getTime = function() { return Timebase.stamp(); }
		#end
	}
	
	/** after login */
	public function initGame():Void
	{
		addComponent(new BagpackSystem());
		addComponent(new GameFactory());
		addComponent(new TaskSystem());
		addComponent(new BattleSystem());
		addComponent(new RewardSystem());
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
		gameStage.addChild(render);
		render.updateEngine();
	}
	override function propagateTick(dt:Float) 
	{
		super.propagateTick(dt);
		//rootStage.stage.setChildIndex(_debugTxt, rootStage.stage.numChildren - 1);
		//rootStage.stage.setChildIndex(_fps, rootStage.stage.numChildren - 1);
		_debugTxt.text = "fps: " + Timebase.fps + " Mem:" + HXP.round(System.totalMemory / 1024 / 1024, 2) + "MB";
		//+ "\nrealDelta:" + TimeBase.timeDelta + "\ngameDelta:" +Timebase.gameTimeDelta;
		//+ "\nRealTime::" + Timebase.realTime + "\nGameTime:" +Timebase.gameTime;
		#if actuate_manual_update
			SimpleActuator.stage_onEnterFrame (null);
		#end
		#if telemetry
		HXT.advance_frame();
		#end
		//Input.update();
	}
	
	override function propagateDraw(alpha:Float) 
	{
		super.propagateDraw(alpha);
		//if (_render){
			render.updateEngine();
		//}
	}
	
	public function startGame():Void
	{
		_render = true;
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
		add(_board);
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
		_render = false;
		//var gamebord:Entity = findChild("GameBoard");
		//remove(_board);
	}
	
	public function pauseGame(pause:Bool)
	{
		//render.paused = pause;
		this.paused = pause;
		//if(!pause)
			//render.updateEngine();
	}
	public function isPausing():Bool
	{
		return paused;
	}
	
	private function preload():Void 
	{
		new SfxManager();
		RandomNameManager.instance;
	}
}