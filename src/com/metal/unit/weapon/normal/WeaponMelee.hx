package com.metal.unit.weapon.normal;
import com.metal.config.PlayerPropType;
import com.metal.message.MsgActor;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.manager.SkillManager;
import com.metal.unit.weapon.impl.BaseWeapon;

/**
 * ...
 * @author weeky
 */
class WeaponMelee extends BaseWeapon
{
	private var _meleeSkillInfo:SkillInfo;
	public function new() 
	{
		isMelee = true;
		super();	
	}
	
	override public function initInfo(info:SkillInfo):Void 
	{
		//重置技能信息
		super.initInfo(info);
		_meleeSkillInfo = SkillManager.instance.getInfo(1211);
		bulletCount = maxBulletCount = _meleeSkillInfo.num;
	}
	
	override public function onTick(timeDelta:Float) 
	{
		
		super.onTick(timeDelta);
		if (isShooting) {
			//trace("isShooting"+bulletCount+"::"+maxBulletCount);
			if (bulletCount <= 0)
				notify_ShootStop(null);
			shootTime--;
			if (shootTime <= 0) {
				//shootTime = skillInfo.CDTime * 60;
				shootTime = _meleeSkillInfo.CDTime * 60;
				notify(MsgActor.Melee);
				trace("notify(MsgActor.Melee)");
				bulletCount--;
			}
		}
		if (shootTime > 0) {
			shootTime--;
		}
	}
	override function notify_ShootStart(userData:Dynamic):Void 
	{
		trace("notify_ShootStart");
		super.notify_ShootStart(userData);
		isShooting = true;
		bulletCount = maxBulletCount;
		//trace(maxBulletCount+"::"+bulletCount);
	}
}