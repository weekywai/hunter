package com.metal.unit.actor.view;
import com.haxepunk.HXP;
import com.metal.message.MsgActor;
import com.metal.proto.impl.GoldGoodInfo;
import com.metal.proto.impl.ItemBaseInfo;
import com.metal.proto.impl.ModelInfo;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.impl.UnitActor;
import motion.Actuate;
import openfl.errors.Error;
import openfl.geom.Rectangle;

/**
 * 掉落物品
 * @author li
 */
class ViewDropItem extends ViewObject
{
	private var vx:Float = 3;
	private var vy:Float = 4;
	private var _bounds:Rectangle;
	private var _dispear:Bool;
	public function new() 
	{
		super();
		_dispear = false;
	}
	override function onInit():Void 
	{
		super.onInit();
		_actor = owner.getComponent(UnitActor);
		_bounds = new Rectangle(HXP.camera.x, HXP.camera.y, HXP.width*0.8 + HXP.camera.x, HXP.height * 0.7 + HXP.camera.y);
	}
	
	override public function onDispose():Void 
	{
		Actuate.stop(this);
		_bounds = null;
		super.onDispose();
		
	}
	override public function update() 
	{
		if (isDisposed)
			return;
		super.update();
		// random fly icon
		if (_actor.isRunMap) {
			if (!_dispear){
				if (_actor.x <= _bounds.left) {
					_actor.x = _bounds.left;	
					vx=-vx;
				}else if (_actor.x >= _bounds.right) {
					_actor.x = _bounds.right;		
					vx=-vx;
				}
				if (_actor.y <= _bounds.top) {
					_actor.y = _bounds.top;
					vy=-vy;
				}else if (_actor.y >= _bounds.bottom) {
					_actor.y = _bounds.bottom;
					vy=-vy;
				}
			}else {
				if (!_bounds.contains(_actor.x, _actor.y))
					notify(MsgActor.Destroy);
			}
			_actor.x+=vx;
			_actor.y+=vy;
		}
	}
	
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		//判断加载类型
		//trace(owner.getProperty(ItemBaseInfo));
		var info = owner.getProperty(ItemBaseInfo);
		if (info == null)
			info = owner.getProperty(GoldGoodInfo);
		if (info == null)
			throw new Error("info is null" );
		//trace(source);
		_info = new ModelInfo();
		_info.res = info.SwfId;
		//记录碰撞类型
		preload();
		notify(MsgActor.PostLoad, this);
		
	}
	override function Notify_EnterBoard(userData:Dynamic):Void 
	{
		super.Notify_EnterBoard(userData);
		if (_actor.isRunMap){
			_actor._gravity = 0;
			//animateCircle();
			Actuate.tween(this,10,{}).onComplete(function() { 
				_dispear = true; 
				_bounds.inflate(400, 300);
			});
		}
	}
	
	override function setAction(action:ActionType, loop:Bool = true):Void 
	{
		//super.setAction(action, loop);
	}
	
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		//trace("drop item destorying");
		Actuate.tween(_actor, 1, { y:_actor.y-150 } ).onComplete(notify,[MsgActor.Destroy]);
		super.Notify_Destorying(userData);
		//notify( MsgActor.Destroy);
	}
}