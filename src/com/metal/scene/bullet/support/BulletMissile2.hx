package com.metal.scene.bullet.support;
import com.haxepunk.HXP;
import com.metal.proto.impl.BulletInfo;
//import com.metal.particle.Explosion;
import openfl.geom.Point;

/**
 * ...
 * @author ...
 */
class BulletMissile2 extends BulletMissile
{
	//private var _particle:Explosion;

	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
	}
	
	override public function setInfo(info:BulletInfo):Void
	{
		super.setInfo(info);
		canRemove = false;
	}
	override function xmlBullet():Void 
	{
		super.xmlBullet();
		//createParticle();
	}
	
	//override function moveGrenade():Void 
	//{
		//t0++;
		////x轴要根据朝向
		////x = _fightPoint.x + (dirKey?(0 + (t0 * xSpeed)):(-_bullet2.width + (t0 * xSpeed)));
		//x = _fightPoint.x + t0 * xSpeed;// + (dirKey? -_bullet2.width:0);
		//y = _fightPoint.y + (( -120 + (t0 * ySpeed)) + (((g * t0) * t0) / 2));
		//_bullet2.angle = _bullet2.angle +(dirKey? -1.9:1.9);
		//
		//
		///*t0++;
		////x轴要根据朝向
		////x = _fightPoint.x + (dirKey?(0 + (t0 * xSpeed)):(0 + (t0 * xSpeed)));
		//x = _fightPoint.x + (dirKey?(_speed + (t0 )):(_speed + (t0 )));
		//y = _fightPoint.y + (( -120 + (t0 * ySpeed)) + (((g * t0) * t0) / 2));
		////_bullet2.angle = _bullet2.angle +(dirKey?-1.9:1.9);
		//_bullet2.angle = _bullet2.angle +(dirKey? -2.1:2.1);*/
	//}
	
	//override function initRunInfo(dir:Bool):Void 
	//{
		////super.initRunInfo(dir);
		////根据朝向
		//var pos:Point = new Point(_req.targetX, _parabola);//704刚好是落地的Y
		//xSpeed = ((pos.x - this.x) / t1) * _rate;
		//
		//ySpeed = ((((pos.y - this.y) - ((g * t1) * (t1 / 2))) / t1)) * _rate;
		////ySpeed = -5;
		//
		//_fightPoint = new Point(x, y + 100);
		//
		///*var pos:Point = new Point(_req.targetX, _parabola);//704刚好是落地的Y
		//xSpeed = ((pos.x - this.x) / t1) * _rate;
		//
		//ySpeed = ((((pos.y - this.y) - ((g * t1) * (t1 / 2))) / t1)) * _rate;
		////ySpeed = -5;
		//
		//_fightPoint = new Point(x, y+100);	*/
	//}
	
	
	private function createParticle():Void
	{
		//trace("create particle");
		//_particle = new Explosion("yan");
		//HXP.scene.add(_particle);
	}
	
	override function recycle():Void 
	{
		super.recycle();
		//HXP.scene.remove(_particle);
	}
	
	override public function update():Void 
	{
		super.update();
		//if (_particle != null)
			//_particle.updataPoition(x, y);
	}
	
}