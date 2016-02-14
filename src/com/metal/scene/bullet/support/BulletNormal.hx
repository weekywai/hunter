package com.metal.scene.bullet.support;

import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.config.ResPath;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.impl.BulletEntity;

/**
 * ...
 * @author weeky
 */
class BulletNormal extends BulletEntity
{
	private var _bullet:Image;
	private var _bullet2:TextrueSpritemap; 
	private var _spark:Dynamic;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
	}
	override private function onDispose():Void 
	{
		//_bullet.destroy();
		_bullet = null;
		_bullet2 = null;
		_spark = null;
		super.onDispose();
	}
	
	override function onInit():Void 
	{
		//判断资源类型
		switch (info.buffMovieType) {
			case EffectAniType.Image:
				imageBullet();
			case EffectAniType.Texture://2
				xmlBullet();
		}
	}
	
	
	private function imageBullet():Void
	{
		_bullet = new Image(ResPath.getBulletRes(info.img));
		_bullet.centerOrigin();
		var box = Image.createCircle(Std.int(_bullet.height * 0.25));
		box.centerOO();
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
			//_bullet2.x = -eff.ox;
			//_bullet2.y = -eff.oy;
			_bullet2.originX = eff.ox;
			_bullet2.originY = eff.oy;
			_offset = true;
		}else {
			_bullet2.centerOrigin();
		}
		
		graphic = _bullet2;
		_bullet2.play("blast");
	}
	
	private function onComplete(name):Void
	{
		//recycle();
	}
	
	
	override public function start(req:BulletRequest):Void 
	{
		super.start(req);
		if(_bullet != null){
			_bullet.centerOrigin();
			_bullet.angle = _angle;
		}
		
		if (_bullet2 != null) {
			if(!_offset)
				_bullet2.centerOrigin();
			_bullet2.angle = _angle;
		}
	}
	override public function update():Void 
	{
		if (info == null ||_collideTypes==null)
			return;
		super.update();
		//moveAtAngle(_angle, info.speed*_rate, _collideTypes);
		moveAngle(_angle, info.speed * _rate);
		collideEntity = collideTypes(_collideTypes, x, y);
		if (collideEntity != null) {
			//_effectReq.angle = _angle-90;
			_effectReq.angle = _angle;
			//trace("hit: "+ node.getList().size());
			onCollide();
		}
		if (computeInCamera()) {
			//trace("not in camera: "+ node.getList().size());
			if (scene != null) 
				recycle();
		}
	}
	
	private function moveAngle(angle:Float, amount:Float)
	{
		var moveX:Float = 0;
		var moveY:Float = 0;
		angle *= HXP.RAD;
		moveX += Math.round(Math.cos(angle) * amount);
		moveY += Math.round(Math.sin(angle) * amount);
		x += moveX;
		y += moveY;
	}
}