package com.metal.unit.weapon.skill;

import com.metal.config.PlayerPropType;
import com.metal.message.MsgStat;
import com.metal.message.MsgUI2;
import com.metal.player.utils.PlayerUtils;
import com.metal.unit.weapon.impl.BaseWeapon;

/**
 * ...
 * @author weeky
 */
class BaseSkill extends BaseWeapon
{
	private var _cdTime:Int;
	public var isItem:Bool = false;
	public function new() 
	{
		super();
		isShooting = false;
	}
	
	override public function onTick(timeDelta:Float) 
	{
		//trace("clear :"+shootTime);
		super.onTick(timeDelta);
		if (isShooting) {
			if (bulletCount <= 0)
				notify_ShootStop(null);
				//trace(shootTime);
			//shootTime--;
			if (shootTime <= 0) {
				shootTime = skillInfo.CDTime * 60;
				_cdTime = Std.int(skillInfo.CDTime);
				onShoot();
				bulletCount--;
			}
		}
		//trace(_reborn);
		if (shootTime > 0) {
			shootTime--;
			if(shootTime%60==0){
				_cdTime--;
				GameProcess.SendUIMsg(MsgUI2.SkillCD, { time:_cdTime, id:skillInfo.Id } );
			}
			if (shootTime<=0)
				onCDTime();
		} 
	}
	
	override function notify_Reborn(userData:Dynamic):Void 
	{
		super.notify_Reborn(userData);
		_cdTime = 0;
		GameProcess.SendUIMsg(MsgUI2.SkillCD, { time:_cdTime, id:skillInfo.Id } );
	}
	/**创建发射*/
	private function onShoot():Void { }
	private function onCDTime():Void{ }	
	private function consume()
	{
		if (isItem)
			return;
		var mp = PlayerUtils.getInfo().getProperty(PlayerPropType.MP) - skillInfo.Consume;
		if (mp < 0){
			throw "mp="+mp+" < 0";
		}
		if(Main.config.get("console")!="true")
			notify(MsgStat.UpdateMp, -skillInfo.Consume);
	}
}