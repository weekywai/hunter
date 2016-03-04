package com.metal.scene.bullet.impl;

import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.config.UnitModelType;
import com.metal.message.MsgBullet;
import com.metal.message.MsgEffect;
import com.metal.message.MsgItr;
import com.metal.proto.impl.BulletInfo;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.bullet.api.BulletHitInfo;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.api.IBullet;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.board.view.ViewDisplay;
import com.metal.unit.avatar.MTAvatar;
import de.polygonal.core.sys.SimEntity;
import motion.Actuate;

/**
 * ...
 * @author weeky
 */
class BulletEntity extends ViewDisplay implements IBullet
{
	private var _owner:SimEntity;
	
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
	//private var isRecycle:Bool = false;
	
	private var _offset:Bool = false;
	
	/**有效射程*/
	private var _range:Float = HXP.width;
	private var _startX:Float;
	
	//private var _bulletGraphic:Null<Image, TextrueSpritemap>;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
		//_effectReq = new EffectRequest();
		//_hitInfo = new BulletHitInfo();
		_angle = 0;
		_tx = 0;
		_ty = 0;
	}
	
	override private function onDispose():Void 
	{
		//_owner.getComponent(BulletComponent).bullets.remove(this);
		_owner = null;
		info = null;
		_effectReq = null;
		_hitInfo = null;
		//_bulletGraphic = null;
		super.onDispose();
	}
	
	override public function removed():Void 
	{
		super.removed();
		if(_owner!=null)
			_owner.getComponent(BulletComponent).bullets.remove(this);
		_owner = null;
		info = null;
		_effectReq = null;
		_hitInfo = null;
	}
	
	public function init(body:SimEntity, info:BulletInfo):Void
	{
		if (info == null) throw "info is null";
		_offset = false;
		//isRecycle = false;
		this.info = info;
		_owner = body;
		_effectReq = new EffectRequest();
		_hitInfo = new BulletHitInfo();
		onInit();
		//_lifeSpan = _bulletInfo.BulletDistance / _bulletInfo.BulletSpeed;
	}
	/**继承*/
	private function onInit():Void
	{
		
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
		if (Math.abs(x-_startX)>_range) recycle();
	}
	/** 结束，循环再用 */
	public function recycle():Void {
		//已经回收
		//if (isRecycle) 
		if (_recycleNext!=null) 
			return;
		//isRecycle = true;
		if (scene != null)
			scene.recycle(this);
		//_owner.getComponent(BulletComponent).bullets.remove(this);
		_owner.notify(MsgBullet.Recycle, this);
	}
	
	/** 启动效果 */
	private function commitEffect():Void {
		_effectReq.Key = info.effId;
		_effectReq.x = x;
		_effectReq.y = y;
		_owner.notify(MsgEffect.Create, _effectReq);
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
			var avatar:MTAvatar = cast(collideEntity, MTAvatar);
			_hitInfo.target = avatar.owner;
			_hitInfo.renderType = BattleResolver.resolveAtk(_hitInfo.critPor);
			_owner.notify(MsgItr.BulletHit, _hitInfo);
		}
		commitEffect();
		//穿透判断
		if (info.isThrough==0)//不穿透
		{
		recycle();
		}
		else if (info.isThrough == 1) //----此处未使用到----
		{
			//穿透子弹
			recycle();
		}
	}
}