package com.metal.unit.weapon.skill;
import com.metal.config.MsgType.GameMsgType;
import com.metal.message.MsgStat;
import com.metal.message.MsgUI2;

/**
 * 加buff
 * @author weeky
 */
class SkillBuff extends BaseSkill
{

	public function new() 
	{
		super();
	}
	override function onCDTime():Void 
	{
		dispose();
	}
	override function notify_ShootStart(userData:Dynamic):Void 
	{
		if (shootTime > 0) { // 
			GameProcess.root.notify(MsgUI2.ScreenMessage, GameMsgType.SkillFreeze);
			return;
		}
		if(!isItem)
			isShooting = true;
		notify(MsgStat.AddSubStatus, { "id":skillInfo.buffId, "time":skillInfo.buffTime } );
		consume();
	}
}