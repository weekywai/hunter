package com.metal;
import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.Sfx;
import com.metal.component.BattleComponent;
import com.metal.component.GameSchedual;
import com.metal.component.RewardComponent;
import com.metal.component.TaskComponent;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.manager.ResourceManager;
import com.metal.manager.UIManager;
import com.metal.message.MsgUI;
import com.metal.message.MsgView;
import com.metal.proto.manager.RandomNameManager;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.board.impl.GameBoard;
import com.metal.scene.bullet.impl.BulletComponent;
import com.metal.scene.effect.impl.EffectComponent;
import com.metal.scene.GameFactory;
import com.metal.scene.GameScene;
import com.metal.scene.map.GameMap;
import com.metal.scene.view.Camera;
import com.metal.scene.view.ViewBoard;
import de.polygonal.core.es.Entity;
import de.polygonal.core.es.EntitySystem;
import de.polygonal.core.es.MainLoop;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.sys.SimEntity;
import de.polygonal.core.time.Timebase;
import motion.actuators.SimpleActuator;
import openfl.Assets;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.Lib;
import openfl.profiler.Telemetry;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
//import tweenx909.advanced.UpdateModeX;
//import tweenx909.TweenX;
import hxtelemetry.HxTelemetry;
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
	/** send message to UImanager */
	public static function SendUIMsg(type:Int, userData:Dynamic = null)
	{
		UIRoot.sendMMsg(type, userData);
	}
	/** notify UImanager compent */
	public static function NotifyUI(type:Int, userData:Dynamic = null)
	{
		UIRoot.notify(type, userData);
	}
	
	public static var render(default, null):Engine;
	
	public static var console(default, null):DevCheat;
	public var HXT:HxTelemetry;
	
	private var onDrawId:Int = 0;
	private var _debugTxt:TextField;
	private var _fps:FPS;
	private var _loop:MainLoop;
	private var _render:Bool = false;
	public function new() {}
	
	public function init(stage:Stage, container:Sprite)
	{
		console = new DevCheat();
		preload();
		rootStage = container;
		gameStage = new Sprite();
		rootStage.addChild(gameStage);
		
		initEngine();
		root = new SimEntity("Game");
		UIRoot = new UIManager();
		root.addComponent(new GameSchedual());
		root.add(UIRoot);
		_loop = new MainLoop();
		_loop.add(root);
		root.outgoingMessage.o = rootStage;
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
		//#end
		var cfg = new hxtelemetry.HxTelemetry.Config();
		cfg.host = "192.168.1.100";
		cfg.allocations = false;
		HXT = new HxTelemetry(cfg);
	}
	
	/** after login */
	public function initGame():Void
	{
		root.addComponent(new GameFactory());
		root.addComponent(new TaskComponent());
		root.addComponent(new BattleComponent());
		root.addComponent(new RewardComponent());
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
		if (onDrawId == 0)
			SimpleActuator.stage_onEnterFrame (null);
		#end
		if (_render)
			update();
	}
	private function update()
	{
		render.updateEngine();
		#if actuate_manual_update
		SimpleActuator.stage_onEnterFrame (null);
		#end
		HXT.advance_frame();
	}
	
	public function startGame():Void
	{
		var entity = new SimEntity("GameBoard");
		entity.addComponent(new GameBoard());
		entity.addComponent(new GameMap());
		entity.addComponent(new ViewBoard());
		entity.addComponent(new Camera());
		entity.addComponent(new BulletComponent());
		entity.addComponent(new EffectComponent());
		entity.addComponent(new BattleResolver());
		entity.drawable = true;
		root.add(entity);
		onDrawId = 1;
		
		#if debug
        HXP.console.enable();
		#end
	}
	
	public function endGame():Void 
	{
		trace("endGame");
		Sfx.stopAllSound();
		HXP.scene.end();
		HXP.scene.updateLists();
		ResourceManager.instance.unLoadAll();
		var gamebord:Entity = root.findChild("GameBoard");
		root.remove(gamebord);
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