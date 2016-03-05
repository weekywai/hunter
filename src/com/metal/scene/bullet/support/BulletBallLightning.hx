package com.metal.scene.bullet.support;

import com.haxepunk.Entity;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.config.ResPath;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.message.MsgEffect;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.impl.BulletEntity;
import openfl.geom.Point;

/**
 * 球形闪电
 * @author hyg
 */
class BulletBallLightning extends BulletEntity
{
	private var _bullet:Image;
	private var _bullet2:TextrueSpritemap;
	
	private var _speed:Int;
	/**运动轨迹辅助参数**/
	private var xSpeed:Float;
	private var ySpeed:Float;
	private var t0:Float = 0;//x轴
	private var t1:Float = 150;//y轴
	private var g:Float = 0.08;//重力加速度
	private var angel:Float = 0;
	private var dirKey:Bool;//默认向右
	private var _parabola:Int;//抛物线
	private var _fightPoint:Point;//丢出去的x,y
	private inline static var groundY:Int = 704;
	
	private var _req:BulletRequest;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
	}
	override private function onDispose():Void 
	{
		//_bullet.destroy();
		_bullet = null;
		_bullet2 = null;
		_req = null;
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
		if (eff.ox != 0 || eff.oy != 0 ) {
			
			_bullet2.originX = eff.ox;
			_bullet2.originY = eff.oy;
			
			_bullet2.scale = eff.scale;
			
			_offset = true;
		}else {
			_bullet2.centerOrigin();
		}
		
		graphic = _bullet2;
		_bullet2.play("blast");
		var box = Image.createCircle(Std.int(_bullet2.height * 0.2));
		box.centerOO();
		setHitboxTo(box);
		////this.setHitbox(90,90, 30,30);
	}
	
	private function onComplete(name):Void
	{
		//recycle();
	}
	
	/**抛物线*/
	private function moveGrenade():Void{
		t0++;
		//x轴要根据朝向
		x = _fightPoint.x + (t0 * (xSpeed));
		//x = _fightPoint.x + (_speed + (t0 ));
		y = _fightPoint.y + (( -120 + (t0 * (ySpeed))) + (((g * t0) * t0) / 2));
		//_bullet2.angle = _bullet2.angle +(dirKey?-1.9:1.9);
	}
	private function initRunInfo(dir:Bool):Void {
		//根据朝向
		var pos:Point = new Point((dir?_req.targetX:_req.targetX),
			_parabola);//704刚好是落地的Y
		
		xSpeed = ((pos.x - this.x) / t1) * _rate;
		ySpeed = ((((pos.y - this.y) - ((g * t1) * (t1 / 2))) / t1)) * _rate;
		
		_fightPoint = new Point(x, y);
	}
	override public function start(req:BulletRequest):Void 
	{
		super.start(req);
		_req = req;
		x = req.x ;// - HXP.camera.x;// - _bullet2.width;
		y = req.y ;// + HXP.camera.y;// - _bullet2.height;
		_parabola = HXP.width - req.info.param;// req.info.param;//从屏幕底部算起
		//判断目标 和 攻击者的相对位置
		dirKey = req.targetX >= req.x;// _attacker.getComponent(MTActor).dir == Direction.RIGHT;
		_speed = req.info.speed;
		initRunInfo(dirKey);
		t0 = 0;
		//_bullet.centerOrigin();
		//_bullet.centerOO();
		//if (_bullet != null) {
			//_bullet.centerOrigin();
			//_bullet.angle = _angle;
		//}
		//SfxManager.getAudio(AudioType.Missile).play();
	}
	override public function update():Void 
	{
		if (isDisposed)
			return;
		super.update();
		
		if (collideEntity != null) {
			onCollide();
		}
		moveGrenade();
		if (computeInCamera()){
			if (scene != null) 
				recycle();
		}
	}
	override function onCheck():Void 
	{
		var vc:Float, i:Int, e:Entity;
		
		if (collideEntity != null) return;
		
		if ((e = collideTypes(_collideTypes, x, y)) != null) {
			if(e.type == "solid" ||e.type == "player"){
				_effectReq.angle = 90;
				if(!_offset)
					y -= 150;
				_effectReq.y -= 50;
				collideEntity = e;
			}else {
				return;
			}
		}
	}
	//}/** 启动效果 */
	override function commitEffect():Void {
		_effectReq.Key = info.effId;
		_effectReq.x = x;
		_effectReq.y = y + 50;
		owner.notify(MsgEffect.Create, _effectReq);
	}
}