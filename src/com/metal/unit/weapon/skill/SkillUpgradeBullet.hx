package com.metal.unit.weapon.skill;
import com.metal.config.MsgType.GameMsgType;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStat;
import com.metal.message.MsgUI2;
import com.metal.unit.weapon.impl.WeaponController;

/**
 * 升级子弹
 * @author weeky
 */
class SkillUpgradeBullet extends BaseSkill
{

	public function new() 
	{
		super();
		
	}
	
	override function notify_ShootStart(userData:Dynamic):Void 
	{
		if (shootTime > 0) { // 
			GameProcess.SendUIMsg(MsgUI2.ScreenMessage, GameMsgType.SkillFreeze);
			return;
		}
		if(!isItem)
			isShooting = true;
		var weapon:WeaponController = owner.getComponent(WeaponController);
		var lv = weapon.bulletLevel + 1;
		if (lv < 5) {
			//trace("level up:"+lv);
			notify(MsgPlayer.ChangeWeaponLevel, { "lv":lv, "runaway":false } );
		} else {
			//trace("runaway:"+lv);
			notify(MsgStat.AddSubStatus, { "id":skillInfo.buffId, "time":skillInfo.buffTime } );
		}
	}
}