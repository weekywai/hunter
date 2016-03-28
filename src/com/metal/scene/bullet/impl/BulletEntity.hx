package com.metal.scene.bullet.impl;

import com.haxepunk.HXP;
import com.metal.config.UnitModelType;
import com.metal.message.MsgEffect;
import com.metal.message.MsgItr;
import com.metal.proto.impl.BulletInfo;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.bullet.api.BulletHitInfo;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.api.IBullet;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.render.ViewDisplay;
import com.metal.unit.render.ViewPhysics;
import de.polygonal.core.sys.SimEntity;
import signals.Signal1;

/**
 * ...
 * @author weeky
 */
class BulletEntity extends ViewPhysics implements IBullet
{
	public var info(default, null):BulletInfo;
	
	/** 目标X */
	public var _tx:Float;
	/** 目标Y */
	public var _ty:Float;
	/** 旋转角度 */
	private var _angle:Float;
	/** 存在时间 */
	private var _age:Int = 0;
	
	private var _effectReq:EffectRequest;
	
	private var _attackerType:String;
	
	private var _hitInfo:BulletHitInfo;
	/**子弹速率*/
	private var _rate:Float = 2;
	
	public var canRemove:Bool = true;
	public var removeCall:Signal1<IBullet>;
	
	private var _offset:Bool = false;
	
	/**有效射程*/
	private var _range:Float = HXP.width;
	private var _startX:Float;
	
	//private var _bulletGraphic:Null<Image, TextrueSpritemap>;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
		removeCall = new Signal1<IBullet>();
		//_effectReq = new EffectRequest();
		//_hitInfo = new BulletHitInfo();
		_angle = 0;
		_tx = 0;
		_ty = 0;
	}
	
	override private function onDispose():Void 
	{
		//trace("bullect dispose");
		if (scene != null)
			scene.clearRecycled(Type.getClass(this));
		removeCall.removeAll();
		removeCall = null;
		info = null;
		_effectReq = null;
		_hitInfo = null;
		//_bulletGraphic = null;
		super.onDispose();
	}
	
	override public function removed():Void 
	{
		super.removed();
		if(removeCall!=null)
			removeCall.dispatch(this);
		owner = null;
		info = null;
		_effectReq = null;
		_hitInfo = null;
	}
	
	override public function init(body:SimEntity):Void
	{
		super.init(body);
		
		_offset = false;
		_effectReq = new EffectRequest();
		_hitInfo = new BulletHitInfo();
		
		//_lifeSpan = _bulletInfo.BulletDistance / _bulletInfo.BulletSpeed;
	}
	public function setInfo(info:BulletInfo):Void
	{
		if (info == null) throw "info is null";
		this.info = info;
	}
	
	public function start(req:BulletRequest):Void 
	{
		//trace("bulletEntity " + req);
		//trace("hitinfo " + _hitInfo);
		x = req.x;
		y = req.y;
		_startX = req.x;
		_tx = req.targetX;
		_ty = req.targetY;
		_rate = req.rate;
		_hitInfo.atk = req.atk;
		_hitInfo.fix = req.fix.copy();
		_hitInfo.buffId = req.buffId;
		_hitInfo.buffTarget = req.buffTarget;
		_hitInfo.buffTime = req.buffTime;
		_hitInfo.critPor = req.critPor;
		
		
		_angle = HXP.angle(x, y, _tx, _ty);
		_attackerType = req.attacker.name;
		validateCollide(_attackerType);
		HXP.scene.add(this);
	}
	
	override public function update():Void 
	{
		super.update();
		/**超出射程回收*/
		if (!onCamera)
			recycle();
		//TODO actor move range change
		//if (Math.abs(x-_startX)>_range) recycle();
	}
	/** 结束，循环再用 */
	public function recycle():Void {
		//已经回收
		if (_recycleNext!=null) 
			return;
		if (scene != null)
			scene.recycle(this);
		//owner.notify(MsgBullet.Recycle, this);
	}
	
	/** 启动效果 */
	private function commitEffect():Void {
		_effectReq.Key = info.effId;
		_effectReq.x = x;
		_effectReq.y = y;
		owner.notify(MsgEffect.Create, _effectReq);
	}
	
	private function computeInCamera():Bool
	{
		var dx:Float = x - HXP.camera.x;
		var dy:Float = y - HXP.camera.y;
		//trace(x + ":" + y+"  "+dx +":"+dy);
		if (dx < -10 || dx > HXP.screen.width + 10 ||
			dy < -10 || dy > HXP.screen.height + 10)
		{
			return true;
		}
		return false;
	}
	/**
	 * 验证物体是否可攻击
	 * @param	$boardItem
	 * @return
	 */
	private function validateCollide(type:String):Void {
		_collideTypes = BoardFaction.collideType.copy();
		if (type == UnitModelType.Unit || type == UnitModelType.Boss || type == UnitModelType.Elite){
			_collideTypes.remove(UnitModelType.Block);
			_collideTypes.remove(UnitModelType.Unit);
			_collideTypes.remove(UnitModelType.Boss);
			_collideTypes.remove(UnitModelType.Elite);
		}
		_collideTypes.remove(type);
		//trace(type+" : "+_collideTypes);
	}
	
	private function onCollide():Void
	{
		if(collideEntity.type != "solid")
		{
			//trace("collideEntity " + collideEntity.type);
			var avatar:ViewDisplay = cast(collideEntity, ViewDisplay);
			_hitInfo.target = avatar.owner;
			_hitInfo.renderType = BattleResolver.resolveAtk(_hitInfo.critPor);
			owner.notify(MsgItr.BulletHit, _hitInfo);
		}
		commitEffect();
		//穿透判断
		switch(info.isThrough) {
			case 0://不穿透
			case 1://穿透
		}
		recycle();
	}
}