package com.metal.scene.bullet.support;

import com.haxepunk.Entity;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.config.ResPath;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.message.MsgEffect;
import com.metal.message.MsgItr;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.impl.BulletEntity;
import com.metal.unit.avatar.MTAvatar;
import motion.Actuate;

/**
 * ...
 * @author li
 */
class BulletMissile1 extends BulletEntity
{
	private var _bullet:Image;
	private var _bullet2:TextrueSpritemap;
	private var _warning:TextrueSpritemap;
	private var _warn:Entity;
	
	private var _req:BulletRequest;
	private var _speed:Float;
	private var _dir:String;
	
	private var count:Bool = false;

	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
		
	}
	
	override function onDispose():Void 
	{
		super.onDispose();
		//scene.remove(_warn);
		Actuate.stop(this);
		_bullet = null;
		_bullet2 = null;
		_warning = null;
		_warn = null;
		_req = null;
		_speed = 0;
		_dir = null;
	}
	
	override function onInit():Void 
	{
		//判断资源类型
		_dir = "up";
		canRemove = false;
		switch (info.buffMovieType) {
			case EffectAniType.Image:
				imageBullet();
			case EffectAniType.Texture:
				xmlBullet();
		}
	}
	
	private function imageBullet():Void
	{
		_bullet = new Image(ResPath.getBulletRes(info.img));
		_bullet.centerOrigin();
		var box = Image.createCircle(Std.int(_bullet.height * 0.25));
		box.centerOO();
		box.originX  += (_bullet.width / 2);
		setHitboxTo(box);
		graphic = _bullet; 
	}
	
	private function xmlBullet():Void
	{
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes(info.img));
		_bullet2 = new TextrueSpritemap(eff);
		_bullet2.add("blast", eff.getReginCount(), 25);
		_bullet2.animationEnd.add(onComplete);
		if (eff.ox != 0 || eff.oy != 0) {
			_bullet2.originX = eff.ox ;// - _bullet2.width * 0.5;
			_bullet2.originY = eff.oy;
			_bullet2.scale = eff.scale;
			_offset = true;
		}else {
			_bullet2.centerOrigin();
		}
		graphic = _bullet2;
		var box = Image.createCircle(Std.int(_bullet2.height * 0.15));
		if (eff.ox != 0 || eff.oy != 0) {
			box.originX = eff.ox;// -_bullet2.width * 0.5;
			box.originY = eff.oy;// -_bullet2.height * 0.5;
		}else {
			box.centerOO();
		}
		
		setHitboxTo(box);
		_bullet2.play("blast");
		Actuate.tween(this, 1, { } ).onComplete(createWarning);
	}
	
	private function onComplete(name:String):Void
	{
		//recycle();
	}
	
	override public function start(req:BulletRequest):Void 
	{
		//trace("req " + req);
		super.start(req);
		_req = req;
		_speed = req.info.speed;
		//x = req.x - HXP.camera.x + _bullet2.width / 2;
		x = req.x;
		//y = req.y - HXP.camera.y + _bullet2.height;
		y = req.y;
		
		if (_bullet2 != null) {
			_bullet2.angle = 90;
			_bullet2.centerOO();
		}
		
	}
	
	override public function update():Void 
	{
		if (isDisposed)
			return;
		super.update();
		if(_dir == "up")
			moveUp();
		else if (_dir == "down")
			moveDown();
		if (collideEntity != null) {
			onCollide();
			//scene.remove(_warn);
		}
	}
	
	private function moveUp():Void
	{
		//x += -_speed;
		y += -_speed;
	}
	
	private function moveDown():Void
	{
		//x += -_speed;
		//x += - _speed * (HXP.halfWidth - _warn.x) / (HXP.height + 10);
		y += _speed;
	}
	
	private function setPosition():Void
	{
		_dir = "down";
		//x = _tx + (100 * Math.random() - 50);
		x = _tx + (80 * Math.random() - 40);
		y = -10;
		//var _angle:Float = Math.atan2((_warn.y - y), (_warn.x - x));
		//_bullet2.angle = -_angle * (180 / Math.PI);
		_bullet2.angle = -90;
	}
	
	private function createWarning():Void
	{
		if (info != null)
		{
			_warn = new Entity();
			var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getEffectRes(info.warning, 4));
			_warning = new TextrueSpritemap(eff);
			_warning.add("warning", eff.getReginCount(), 25);
			_warning.animationEnd.add(onComplete);
			if (eff.ox != 0 || eff.oy != 0 ) {
				_warning.originX = eff.ox;
				_warning.originY = eff.oy;
				_warning.scale = eff.scale;
			}else{
				_warning.centerOrigin();
			}
			_warn.addGraphic(_warning);
			_warning.play("warning");
			//_warn.x = HXP.width * (Math.random()*0.3 + 0.1);
			_warn.x = _tx;
			_warn.y = HXP.height;
			
			if (_warn != null)
				scene.add(_warn);
			
			Actuate.tween(this, 1, { } ).onComplete(setPosition);
		}
	}
	
	override function onCheck():Void 
	{
		var vc:Float, i:Int, e:Entity;
		
		if (collideEntity != null) return;
		
		if ((e = collideTypes(_collideTypes, x, y)) != null) {
			//trace(e.type);
			collideEntity = e;
			_effectReq.angle = 90;
			y -= 150;
		}
	}
	
	override function onCollide():Void 
	{
		if(collideEntity.type != "solid")
		{
			//trace("collideEntity " + collideEntity);
			var avatar:MTAvatar = cast(collideEntity, MTAvatar);
			_hitInfo.target = avatar.owner;
			_hitInfo.renderType = BattleResolver.resolveAtk(_hitInfo.critPor);
			_owner.notify(MsgItr.BulletHit, _hitInfo);
		}
		commitEffect();
		//scene.remove(this);
		recycle();
	}
	/** 启动效果 */
	override function commitEffect():Void {
		_effectReq.Key = info.effId;
		_effectReq.x = x;
		_effectReq.y = y + 125;
		_owner.notify(MsgEffect.Create, _effectReq);
	}
	
	override function recycle():Void 
	{
		if(_warn != null && scene!=null)
			scene.remove(_warn);
		super.recycle();
	}
	
}