package com.metal.unit.weapon.skill;
import com.metal.config.MsgType.GameMsgType;
import com.metal.message.MsgEffect;
import com.metal.message.MsgStat;
import com.metal.message.MsgUI2;
import com.metal.player.utils.PlayerUtils;
import com.metal.unit.stat.IStat;

/**
 * 回血
 * @author weeky
 */
class SkillRegen extends BaseSkill
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
		var stat:IStat = PlayerUtils.getPlayerStat();
		var hp = stat.hpMax * skillInfo.Effect[0] / 10000 + skillInfo.Effect[1];
		//trace("SkillRegen: " + hp + " maxhp: " +stat.hpMax);
		if (stat.hp < stat.hpMax){
			owner.notify(MsgStat.RegenHp, hp);
			owner.notify(MsgEffect.EffectStart, "Z002");
		}
		consume();
	}
}