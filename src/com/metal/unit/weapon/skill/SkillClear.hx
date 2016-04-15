package com.metal.unit.weapon.skill;
import com.metal.config.MsgType.GameMsgType;
import com.metal.config.PlayerPropType;
import com.metal.message.MsgBullet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI2;
import com.metal.unit.actor.api.ActorState;

/**
 * 消除子弹
 * @author weeky
 */
class SkillClear extends BaseSkill
{

	public function new() 
	{
		super();
	}
	override function onShoot():Void 
	{
		notifyParent(MsgBullet.Create, bulletReq);
	}
	override function notify_ShootStart(userData:Dynamic):Void 
	{
		super.notify_ShootStart(userData);
		if (shootTime > 0) { // 
			GameProcess.SendUIMsg(MsgUI2.ScreenMessage, GameMsgType.SkillFreeze);
			return;
		}
		//trace("clear shoot "+maxBulletCount);
		if(!isItem)
			isShooting = true;
		if (_avatar == null){
			bulletReq.x = _actor.x;
			bulletReq.y = _actor.y - _actor.halfHeight;
		}else {
			bulletReq.x = _avatar.x;
			bulletReq.y = _avatar.y - _avatar.halfHeight;
		}
		bulletReq.dir = _actor.dir;
		bulletCount = maxBulletCount;
		if (_actor.stateID == ActorState.Enter) {
			//bulletReq.targetX = bulletReq.x;
			bulletReq.y = _avatar.y - _avatar.height;
		}
		consume();
	}
}