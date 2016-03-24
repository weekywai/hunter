package com.metal.scene.bullet.impl;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.metal.scene.bullet.api.IBullet;
import com.metal.scene.bullet.support.BulletBallLightning;
import com.metal.scene.bullet.support.BulletFire;
import com.metal.scene.bullet.support.BulletFire1;
import com.metal.scene.bullet.support.BulletGrenade;
import com.metal.scene.bullet.support.BulletLaser;
import com.metal.scene.bullet.support.BulletMissile;
import com.metal.scene.bullet.support.BulletMissile1;
import com.metal.scene.bullet.support.BulletMissile2;
import com.metal.scene.bullet.support.BulletNormal;
import com.metal.scene.bullet.support.BulletSkillShiny;
import haxe.ds.IntMap;

/**
 * ...
 * @author weeky
 */
class BulletFactory
{
	/**无状态*/
	inline public static var None:Int = 0;
	/**常态*/
	inline public static var Normal:Int = 1;
	/**贯穿*/
	inline public static var Pierce:Int = 2;
	/**手雷*/
	inline public static var Grenade:Int = 3;
	/**爆炸*/
	inline public static var Explode:Int = 4;
	/**导弹(抛物线)**/
	inline public static var Missile:Int = 5;
	inline public static var Missile1:Int = 10;
	/**喷火*/
	inline public static var Fire:Int = 6;
	inline public static var Fire1:Int = 9;
	
	inline public static var WarningMissle:Int = 7;
	
	/**全屏技能1**/
	inline public static var SkillShiny:Int = 8;
	
	/**球形闪电*/
	inline public static var BallLightning:Int = 11;
	
	/**镭射光*/
	inline public static var Laser:Int = 12;
	
	public static var instance(default, null):BulletFactory = new BulletFactory();
	
	private var _class:IntMap<Class<Entity>>;
	public function new() 
	{
		_class = new IntMap();
		_class.set(Normal, BulletNormal);
		_class.set(Grenade,BulletGrenade );//
		_class.set(Missile, BulletMissile);
		_class.set(Fire, BulletFire);
		_class.set(Fire1, BulletFire1);
		_class.set(WarningMissle, BulletMissile1);
		_class.set(Missile1, BulletMissile2);
		_class.set(SkillShiny, BulletSkillShiny);
		_class.set(BallLightning, BulletBallLightning);
		_class.set(Laser, BulletLaser);
	}
	
	public function createBullet(type:Int):IBullet
	{
		var cls = _class.get(type);
		if (cls == null) throw ("Bullet teamplate not found : " + type);
		var entity = HXP.scene.create(cls, false);
		return untyped entity;
	}
}