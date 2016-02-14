package com.metal.unit.weapon.normal;

import com.metal.config.SfxManager;
import com.metal.enums.Direction;
import com.metal.enums.GunType;
import com.metal.message.MsgBullet;
import com.metal.message.MsgPlayer;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.weapon.impl.BaseWeapon;
import spinehaxe.Bone;

/**
 * ...
 * @author weeky
 */
class WeaponAuto extends BaseWeapon
{
	private var _weaponSubId:Int;
	public function new() 
	{
		super();
	}
	
	override public function initInfo(info:SkillInfo):Void 
	{
		super.initInfo(info);
		_weaponSubId = GoodsProtoManager.instance.getSubID(weaponID);
		trace("initInfo");
	}
	override public function onTick(timeDelta:Float) 
	{
		super.onTick(timeDelta);
		if (isShooting) {
			//trace("isShooting"+bulletCount+"::"+maxBulletCount);
			if (!_stat.holdFire || bulletCount <= 0) {
				bulletCount = 0;	
				notify_ShootStop(null);
				return;
			}
			//shootTime--;
			if (shootTime <= 0) {
				
				switch(_weaponSubId){
					case GunType.Gun:		SfxManager.getAudio(AudioType.MachineGun).play(0.3);
					case GunType.MachineGun:SfxManager.getAudio(AudioType.ShotGun).play(0.3);
					case GunType.LaserGun:	SfxManager.getAudio(AudioType.LaserGun).play(0.3);
					case GunType.ShotGun:	SfxManager.getAudio(AudioType.Gun).play(0.3);
				}
				updateReq();
				if (!isDirWrong) 
				{
					notifyParent(MsgBullet.Create, bulletReq);
					bulletCount--;
					shootTime = skillInfo.CDTime * 60;
					//trace("weaponauto fire");
					notify(MsgPlayer.ConsumeBullet);
				}				
			}
		}
		if (shootTime > 0) {
			shootTime--;
		}
	}
	override function notify_ShootStart(userData:Dynamic):Void 
	{
		super.notify_ShootStart(userData);
		isShooting = true;
		bulletCount = maxBulletCount;
		//updateReq();
		bulletReq.spark = 6;
		//trace(maxBulletCount+"::"+bulletCount);
	}
	
	override function notify_ShootStop(userData:Dynamic):Void 
	{
		super.notify_ShootStop(userData);
	}
	var isDirWrong:Bool;
	/**更新角色坐标修正子弹发射点*/
	private function updateReq():Void 
	{
		//trace("updateReq");
		var gun:Bone =  _avatar.getBone("muzzle_1");
		bulletReq.x = _avatar.x + gun.worldX * _avatar.getScale();
		bulletReq.y = _avatar.y + gun.worldY * _avatar.getScale();
		//bulletReq.bulletAngle = gun.worldRotation;//保留，以后子弹发射用angle控制，不用target控制
		//trace("bulletReq.bulletAngle: "+bulletReq.bulletAngle);
		isDirWrong = false;
		if (!target) {
			if(_actor.dir== Direction.LEFT)
			bulletReq.targetX = bulletReq.x - 10;
			else
			bulletReq.targetX = bulletReq.x + 10;
			bulletReq.targetY = bulletReq.y;
		}else {
			if ((bulletReq.targetX<bulletReq.x && _actor.dir== Direction.RIGHT) ||(bulletReq.targetX>bulletReq.x && _actor.dir== Direction.LEFT))
			{
				//trace("wrong shooting dir!! It is a bug I can't find reasons yet.");
				//isDirWrong = true;
				target = false;
				if(_actor.dir== Direction.LEFT)
				bulletReq.targetX = bulletReq.x - 10;
				else
				bulletReq.targetX = bulletReq.x + 10;
				bulletReq.targetY = bulletReq.y;
			}
		}
	}
}