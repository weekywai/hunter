package com.metal.unit.weapon.skill;
import com.metal.config.MsgType.GameMsgType;
import com.metal.message.MsgActor;
import com.metal.message.MsgBullet;
import com.metal.message.MsgUI2;
import com.metal.proto.impl.SkillInfo;
import com.metal.unit.actor.api.ActorState;

/**
 * ...
 * @author weeky
 */
class SkillGrenade extends BaseSkill
{

	public function new() 
	{
		super();
	}
	
	override function onShoot():Void 
	{		
			
	}
	
	override function notify_ShootStart(userData:Dynamic):Void 
	{
		super.notify_ShootStart(userData);
		if (shootTime > 0) {
			GameProcess.SendUIMsg(MsgUI2.ScreenMessage, GameMsgType.SkillFreeze);
			return;
		}
		isShooting = true;
		bulletReq.x = _avatar.x;
		bulletReq.y = _avatar.y - _avatar.halfHeight;
		bulletReq.dir = _actor.dir;
		bulletCount = maxBulletCount;
		//trace("bulletReq: "+bulletReq.renderType);
		//trace("onShoot");
		notify(MsgActor.ThrowBomb);	
		if (_actor.stateID == ActorState.Enter) {
			//bulletReq.targetX = bulletReq.x;
			bulletReq.y = _avatar.y - _avatar.height;
		}
		consume();
	}
	override public function onTick(timeDelta:Float) 
	{
		//trace("clear :"+shootTime);
		super.onTick(timeDelta);
		if (_actor.throwBomb) 
		{
			trace("bulletReq: "+shootTime);
			notifyParent(MsgBullet.Create, bulletReq);
			_actor.throwBomb = false;
		}
	}
}