package com.metal.scene.board.view;
import com.haxepunk.HXP;
import com.haxepunk.tmx.TmxMap;
import com.metal.message.MsgBoard;
import com.metal.message.MsgCamera;
import com.metal.message.MsgInput;
import com.metal.message.MsgStartup;
import com.metal.scene.board.support.Bounds;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.impl.BaseActor;
import com.metal.unit.actor.impl.MTActor;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.SimEntity;
import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Quart;
import openfl.tiled.TiledMap;

/**
 * ...
 * @author weeky
 */
class Camera extends Component
{
	private var _limitBoundary:Bounds;
	private var _actor:MTActor;
	private var _lockBounds:Bounds;
	private var _lockKey:Bool;
	private var _autoKey:Bool = false;
	#if spriteTileMap
	private var _viewMap:TiledMap;
	#end
	private var _roll:Bool;
	
	private var _isShaking:Bool = false;
	private var _isTweening:Bool;
	
	public function new() 
	{
		super();
		_lockBounds = new Bounds();
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
	}
	
	override function onDispose():Void 
	{
		_limitBoundary = null;
		_lockBounds = null;
		_actor = null;
		#if spriteTileMap
		_viewMap = null;
		#end
		super.onDispose();
	}
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type){
			case MsgStartup.Reset:
				cmd_Reset();
			case MsgStartup.Start:
				cmd_Start();
			case MsgStartup.AssignMap:
				cmd_AssignMap(userData);
			case MsgBoard.AssignPlayer:
				cmd_AssignPlayer(userData);
			case MsgBoard.AddViewMap:
				cmd_AddViewMap(userData);
			case MsgCamera.Lock:
				cmd_lock(userData);
			case MsgCamera.SetCameraPos:
				cmd_SetCameraPos(userData);
			case MsgCamera.ShakeCamera:
				cmd_ShakeCamera(userData);
		}
	}
	private function cmd_ShakeCamera(userData:Dynamic):Void
	{
		_isShaking = userData;
		//trace("cmd_ShakeCamera");
		ShakeCamera();
	}
	/**震屏效果*/
	private function ShakeCamera()
	{
		if (!_isShaking || _isTweening) return;
		_isTweening = true;
		Actuate.tween(HXP.camera,0.1,{y:HXP.camera.y-5}).onComplete(function ()
		{
			Actuate.tween(HXP.camera,0.3,{y:HXP.camera.y+5}).ease(Bounce.easeOut).onComplete(function ()
			{
				_isTweening = false;
				ShakeCamera();
			});
		});
	}
	
	private function cmd_lock(userData:Dynamic):Void
	{
		if (userData) {
			_limitBoundary.left = Std.int(HXP.camera.x);
			_limitBoundary.top = Std.int(HXP.camera.y);
			_limitBoundary.right = Std.int(HXP.camera.x + HXP.screen.width);
			_limitBoundary.bottom = Std.int(HXP.camera.y + HXP.screen.height);
		}else {
			_lockKey = true;
			_limitBoundary.setBonds(0, _lockBounds.right, 0, _lockBounds.bottom);
		}
	}
	private function cmd_SetCameraPos(userData:Dynamic):Void
	{
		HXP.setCamera(userData.x, userData.y);
	}
	override public function onDraw() 
	{
		if (_actor != null) {
			if (_lockKey) {
				if(!_autoKey)showAutoRun();
			}else {
				if (!_isShaking) HXP.camera.y = _actor.y - HXP.halfHeight*1.4;// Set camera on y-axis
				HXP.camera.x = _actor.x - HXP.halfWidth;// Set camera on x-axis		
			}
			if(!_actor.isVictory)
				checkBounds();
		}
		
		/**镜头可移动范围*/
		if (_limitBoundary != null)
			_limitBoundary.camera();
		#if spriteTileMap
			if (_viewMap!=null && !_roll){
				_viewMap.x = -HXP.camera.x * HXP.screen.fullScaleX;
				_viewMap.y = -HXP.camera.y * HXP.screen.fullScaleY;		
			}
		#end
	}
	/**检测角色超出屏幕*/
	private function checkBounds():Bool
	{
		var gridSize:Int = 32;
		var rangeX:Float = _actor.halfWidth + gridSize;
		var rangeY:Float = _actor.halfHeight + gridSize;
		var direction:Collision = _limitBoundary.check(_actor.x, _actor.y, rangeX, rangeY);
		if (direction == NONE) return false;
		
		switch(direction) {
			case LEFT:
				_actor.x = _limitBoundary.left + rangeX;
			case RIGHT:
				_actor.x = _limitBoundary.right - rangeX;
			case TOP:
				_actor.y = _limitBoundary.top + rangeY;
			case BOTTOM://掉沟里
				_actor.y = _limitBoundary.bottom - rangeY;
			default:
		}
		return true;
	}
	
	/**自动修正镜头**/
	private function showAutoRun():Void
	{
		GameProcess.NotifyUI(MsgInput.SetInputEnable, false);
		_autoKey = true;//, y:_actor.y - HXP.halfHeight
		if(!checkBounds())
			Actuate.tween(HXP.camera, 0.5, { x:_actor.x - HXP.halfWidth }).ease(Quart.easeOut).onComplete(changeLock);
		//changeLock();
	}
	
	private function changeLock():Void
	{
		GameProcess.NotifyUI(MsgInput.SetInputEnable, true);
		_autoKey = false;
		this._lockKey = false;
	}
	
	private function cmd_Reset():Void
	{
		HXP.resetCamera();
		_lockBounds = new Bounds();
	}
	private function cmd_Start():Void
	{
		
	}
	private function cmd_AssignMap(userData:Dynamic):Void
	{
		var tmx:TmxMap = userData.map;
		_limitBoundary = new Bounds();
		_lockKey = false;
		_roll = userData.runKey;
		if (_roll) {
			var offset = tmx.tileWidth * 5;
			_limitBoundary.setBonds(offset, HXP.screen.width + offset, 0, HXP.screen.height);
		} else {
			//缩小屏幕边距 3 grid
			setCameraBounds((tmx.width -3) * tmx.tileWidth, tmx.height * tmx.tileHeight);
		}
		_lockBounds.setBonds(_limitBoundary.left, _limitBoundary.right, _limitBoundary.top, _limitBoundary.bottom);
	}
	
	private function cmd_AssignPlayer(userData:Dynamic):Void
	{
		trace(userData);
		var player:SimEntity = userData;
		_actor = cast player.getComponent(MTActor);
		HXP.camera.y = _actor.y - HXP.halfHeight;
	}
	
	private function cmd_AddViewMap(userData:Dynamic):Void
	{
		#if spriteTileMap
		_viewMap = userData;
		#end
	}
	
	private function setCameraBounds(right:Int, bottom:Int)
	{
		_limitBoundary.right = right;
		_limitBoundary.bottom = bottom;
	}
	
	/**判断是否在屏幕内*/
	public static function isInCamera(x:Float,y:Float,extendWidth:Float=0,extendHeight:Float=0):Bool
	{
		return (x > HXP.camera.x-extendWidth && x < HXP.camera.x + HXP.width+extendWidth && y < HXP.camera.y+extendHeight + HXP.height && y > HXP.camera.y-extendHeight);
	}
}