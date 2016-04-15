package com.metal.unit.weapon.impl;
import com.metal.proto.impl.WeaponInfo;
import com.metal.unit.weapon.normal.WeaponAuto;
import com.metal.unit.weapon.normal.WeaponMelee;
import com.metal.unit.weapon.skill.SkillBuff;
import com.metal.unit.weapon.skill.SkillClear;
import com.metal.unit.weapon.skill.SkillGrenade;
import com.metal.unit.weapon.skill.SkillRegen;
import com.metal.unit.weapon.skill.SkillUpgradeBullet;
import haxe.ds.IntMap;

/**
 * ...
 * @author weeky
 */
enum WeaponType{
	Shoot;
	Melee;
	Grenade;
	Clear;
	Regen;
	AddBuff;
	BurstOut;
	UpgradeBullet;
	ChangeWeapon;
}

class WeaponFactory
{
	public static var instance(default, null):WeaponFactory = new WeaponFactory();
	
	private var _weaponClass:Map<WeaponType, String>;
	public function new() 
	{
		_weaponClass = new Map();
		_weaponClass.set(Shoot, Type.getClassName(WeaponAuto));
		_weaponClass.set(Melee, Type.getClassName(WeaponMelee));
		_weaponClass.set(Grenade, Type.getClassName(SkillGrenade));
		_weaponClass.set(Clear, Type.getClassName(SkillClear));
		_weaponClass.set(Regen, Type.getClassName(SkillRegen));
		_weaponClass.set(AddBuff, Type.getClassName(SkillBuff));
		_weaponClass.set(UpgradeBullet, Type.getClassName(SkillUpgradeBullet));
	}
	
	public function createWeapon(temp:WeaponType):BaseWeapon {
		//var cls:Class<BaseWeapon> = _weaponClass.get(temp);
		var name:String = _weaponClass.get(temp);
		var cls = Type.resolveClass(name);
		if (cls == null) throw "Weapon teamplete not found : " + temp;
		return Type.createInstance(cls, []);
	}
	
	//public function CreateWeaponByProto(info:WeaponInfo):BaseWeapon {
		//var cls:Class = _weaponClass.get(temp);
		//if (cls == null) throw "Weapon teamplete not found : " + temp;
		//var weapon = Type.createInstance(cls, []);
		//weapon.initInfo(info);
		//return weapon;
	//}
}