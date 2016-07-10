package com.metal.scene.bullet.support;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.config.UnitModelType;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.proto.impl.BulletInfo;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.impl.BulletEntity;
import openfl.geom.Point;

/**
 * 导弹(抛物线)
 * @author 3D
 */
class BulletMissile extends BulletEntity
{

	private var _bulletImg:Image;
	private var _bulletTex:TextrueSpritemap;
	private var _bullectAngle:Float;
	private var _speed:Int;
	/**运动轨迹辅助参数**/
	private var xSpeed:Float;
	private var ySpeed:Float;
	private var t0:Float = 0;//x轴
	//private var t1:Float = 30;//y轴
	private var t1:Float = 20;//速率倍数
	private var g:Float = 0.8;//重力加速度
	//private var g:Float = 0.1;
	private var angel:Float = 0;
	private var dirKey:Bool;//默认向右
	private var _parabola:Int;//抛物线
	private var _fightPoint:Point;//丢出去的x,y
	//private var _box:Image;
	
	private inline static var groundY:Int = 704;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
	}

	override private function onDispose():Void 
	{
		if(_bulletImg!=null)
			_bulletImg.destroy();
		_bulletImg = null;
		if(_bulletTex!=null)
			_bulletTex.destroy();
		_bulletTex = null;
		_offset = false;
		super.onDispose();
	}
	
	override public function setInfo(info:BulletInfo):Void
	{
		super.setInfo(info);
		//判断资源类型
		canRemove = false;
		switch (info.fileType) {
			case EffectAniType.Image:
				imageBullet();
			case EffectAniType.Texture:
				xmlBullet();
		}
	}
	

	
	private function imageBullet():Void
	{
		if (_bulletImg != null)
			_bulletImg.destroy();
		_bulletImg = new Image(ResPath.getBulletRes(info.img));
		_bulletImg.centerOrigin();
		var box = Image.createCircle(Std.int(_bulletImg.height * 0.25));
		box.centerOO();
		box.originX  += (_bulletImg.width / 2);
		setHitboxTo(box);
		graphic = _bulletImg; 
	}
	
	private function xmlBullet():Void
	{
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes(info.img));
		if (_bulletTex == null){
			_bulletTex = new TextrueSpritemap(eff);
		}else {
			_bulletTex.resetTexture(eff);
			_bulletTex.x = _bulletTex.y = 0;
		}
		_bulletTex.add("blast", eff.getReginCount(), 25);
		//_bullet2.animationEnd.add(onComplete);
		if (eff.ox != 0 || eff.oy != 0) {
			_bulletTex.originX = eff.ox ;// - _bullet2.width * 0.5;
			_bulletTex.originY = eff.oy;
			_bulletTex.scale = eff.scale;
			_offset = true;
		}else {
			_bulletTex.centerOrigin();
		}
		graphic = _bulletTex;
		var box = Image.createCircle(Std.int(_bulletTex.height * 0.15));
		//if (eff.ox != 0 || eff.oy != 0) {
			//box.originX = eff.ox;// -_bullet2.width * 0.5;
			//box.originY = eff.oy;// -_bullet2.height * 0.5;
		//}else {
			box.centerOO();
		//}
		//_box = box;
		//trace("eff.ox: "+eff.ox);
		//trace("eff.oy: "+eff.oy);
		setHitboxTo(box);
		_bulletTex.play("blast", true);
		//addGraphic(_box);
	}
	
	override public function start(req:BulletRequest):Void 
	{
		//trace("missile");
		super.start(req);
		x = req.x ;// - HXP.camera.x;// - _bullet2.width;
		y = req.y ;// + HXP.camera.y;// - _bullet2.height;
		_parabola = HXP.width - req.info.param;// req.info.param;//从屏幕底部算起
		//判断目标 和 攻击者的相对位置
		dirKey = req.targetX >= req.x;// _attacker.getComponent(MTActor).dir == Direction.RIGHT;
		_speed = req.info.speed;
		_bullectAngle = req.bulletAngle;
		initRunInfo(dirKey);
		t0 = 0;
		if (_bulletImg != null) {
			_bulletImg.centerOrigin();
			_bulletImg.angle = _angle;
		}
		if (_bulletTex != null) {
			_bulletTex.angle = dirKey?65:155;
		}
		SfxManager.getAudio(AudioType.Missile).play(0.4);
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
	
	/**抛物线*/
	private function moveGrenade():Void{
		t0++;
		x = _fightPoint.x + t0 * xSpeed;
		y = _fightPoint.y + (( (t0 * -ySpeed)) + (((g * t0) * t0) / 2));
		if (dirKey) 
		{
			_bulletTex.angle = Math.atan(( ySpeed - g * t0) / Math.abs(xSpeed)) / Math.PI * 180 ;
		}else 
		{
			//水平翻转
			_bulletTex.angle =(180- Math.atan(( ySpeed - g * t0) / Math.abs(xSpeed)) / Math.PI * 180 );
		}
		//trace("_bullet2.angle: "+_bullet2.angle);
		//trace("_bullet2.originX: "+_bullet2.originX);
		//trace("_bullet2.originY: " + _bullet2.originY);
		
		//trace("_bullet2.angle: "+_bullet2.angle);
		//因角度偏转值修正弹头
		//_box.originX -= 100 ;
	}
	
	private function initRunInfo(dir:Bool):Void {
		////根据朝向
		//var pos:Point = new Point((dir?this.x + (Math.random()*200+300):this.x -Math.random()*200- 300),
			//_parabola-(groundY-y - HXP.camera.y));//704刚好是落地的Y
		//xSpeed = ((pos.x - this.x) / t1) * _rate;
		//ySpeed = ((((pos.y - this.y) - ((g * t1) * (t1 / 2))) / t1))* _rate;
		while (_bullectAngle < 0)_bullectAngle+= 360; 
		while (_bullectAngle >= 360)_bullectAngle-= 360;
		if (_bullectAngle < 90 || _bullectAngle > 270){
			//初始右			
		}else 
		{
			//初始左
			_bullectAngle = 180 - _bullectAngle;
		}
		xSpeed = _rate * Math.cos(_bullectAngle / 180*Math.PI) * t1 * (dir?1: -1);
		ySpeed = _rate * Math.sin(_bullectAngle / 180*Math.PI) * t1;
		
		//trace("Math.tan(ySpeed / xSpeed): "+(Math.atan(ySpeed /  Math.abs(xSpeed))/ Math.PI * 180));
		//trace("_req.bulletAngle: "+_req.bulletAngle);
		//trace("xSpeed: "+xSpeed);
		//trace("ySpeed: "+ySpeed);
		_fightPoint = new Point(x, y);
	}
	
	
	override function onCheck():Void 
	{
		var vc:Float, i:Int, e:Entity;
		
		if (collideEntity != null)
			return;
		
		if ((e = collideTypes(_collideTypes, x, y)) != null) {
			if(e.type == UnitModelType.Solid ||e.type == UnitModelType.Player || e.type == UnitModelType.Vehicle){
				_effectReq.angle = 90;
				if(!_offset)
					y -= 150;
				//_effectReq.y -= 50;
				collideEntity = e;
			}else {
				return;
			}
		}
	}
	
	override function commitEffect():Void 
	{
		HXP.screen.shake(3, 0.2);
		super.commitEffect();
	}
}