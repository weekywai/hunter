package com.metal.unit.weapon.api;
import com.metal.proto.impl.BulletInfo;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.impl.WeaponInfo;

/**
 * @author weeky
 */

interface IWeapon 
{
	/**
	 * 是否近战
	 */
	var isMelee(default, null):Bool;
	/**
	 * 是否正在射击
	 */
	var isShooting(default, null):Bool;
	/**
	 * 射击时间间隔，0代表可以射击，>0代表剩余时间
	 */
	var shootTime(default, null):Float;
	/**
	 * 武器信息
	 */
	var weaponID(default, null):Int;
	/**
	 * 子弹信息
	 */
	var bulletInfo(default, null):BulletInfo;
	/**技能信息*/
	var skillInfo(default, null):SkillInfo;
}