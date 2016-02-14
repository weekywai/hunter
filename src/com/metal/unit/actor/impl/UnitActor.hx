package com.metal.unit.actor.impl;
import com.metal.config.UnitModelType;
import com.metal.message.MsgActor;
import com.metal.message.MsgItr;
import com.metal.scene.board.api.BoardFaction;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.stat.UnitStat;
/**
 * ...
 * @author weeky
 */
class UnitActor extends BaseActor
{
	public function new() 
	{
		super();
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_stat = owner.getComponent(UnitStat);
			//trace(owner.name + " "+_stat);
	}
	
	override private function onComplete(i:Int,name:Dynamic):Void 
	{
		//判断攻击状态结束
		//if (name == Std.string(ActionType.attack_1) 
		//|| name == Std.string(ActionType.attack_2) 
		//|| name == Std.string(ActionType.creep_attack_1)
		//||name == Std.string(ActionType.skill_1)) {	
			//transition(ActorState.Stand);	
		//}
		
		if (name == Std.string(ActionType.dead_1)) {
			notify(MsgActor.Destroy);
		}
	}
	override function notify_ChangeSpeed(userData:Dynamic):Void 
	{
		//_speed = _speed * userData[0];
	}
	override function Notify_Attack(userData:Dynamic):Void 
	{
		transition(ActorState.Attack);
		velocity.x = 0;
		acceleration.x = 0;
		super.Notify_Attack(userData);
	}
	override function Notify_InitFaction(userData:Dynamic):Void 
	{
		super.Notify_InitFaction(userData);
		if (faction == BoardFaction.Boss1  || faction== BoardFaction.FlyEnemy)
			_collides = [];
		else
			_collides = [UnitModelType.Solid,UnitModelType.Block];
	}
	
	override function Notify_Destroying(userData:Dynamic):Void 
	{
		_collides = [UnitModelType.Solid];
		_gravity = 0.6;
		super.Notify_Destroying(userData);
	}
	override function Notify_Destroy(userData:Dynamic):Void 
	{
		//notifyParent(MsgItr.Destory, bindPlayerID);
		notifyParent(MsgItr.Destory, owner.keyId);
		if(faction != BoardFaction.Block)
			super.Notify_Destroy(userData);
	}
}