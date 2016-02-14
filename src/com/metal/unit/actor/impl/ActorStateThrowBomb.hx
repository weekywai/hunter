package com.metal.unit.actor.impl;
/**
 * ...
 * @author weeky
 */

class ActorStateThrowBomb extends BaseActorState 
{
	
	public function new() {
		super();
	}
	
	/*
	override public function stateEnter(instance:Dynamic):Void {
		var actor:UnitActor = cast instance;
		actor.stateTime = 0;
	}
	
	override public function update(instance:Dynamic):Void {
		var actor:UnitActor = cast instance;
		
		actor.stateTime++;
		
		//if (actor.stateTime == 8) {
			DoMelee(actor);
		//} else if (actor.stateTime >= actor.UnitNumeric.MeleeSpeed) {
			//actor.CheckUpdatePos();
			//actor.MyEntity.RequestNotify(new Unit_O_Stand(actor.Dir), SimEventPolicy.BcValidateOn);
			////讲给主机/控制者知，处理队列中的事件
			//actor.myBody.sendMessage(this, MsgActor.OnFree);
		//}
	}
	
	private function DoMelee(actor:UnitActor):Void {
		//actor.
		//var cx:Float = actor.X + actor.HalfWidth + offset.u * actor.HalfWidth * 2; // 2 : 将判定盒再外推少少
		//var cy:Float = actor.Y + actor.HalfHeight + offset.v * actor.HalfHeight * 2;
		
		//var hits:Array = board.UnitIntersectRect(cx - actor.HalfWidth * 3, cy - actor.HalfHeight * 3, cx + actor.HalfWidth * 3, cy + actor.HalfHeight * 3, true);
		//for (hit in hits) {
			//var entity:ISimEntity = cast hit.value;
			//if (entity == actor.myEntity) continue;
			//var targetActor:IActor = cast(entity, ISimBody).getComponent(MTActor);
			//if (BoardFaction.IsOpponent(targetActor.faction, actor.faction)) {
				//actor.myEntity.ParentBody.sendMessage(actor.myEntity, MsgItr.Melee, entity);
				//测试
				//EffectReq1.Key = "MeleeHit";
				//EffectReq1.X = cx;
				//EffectReq1.Y = cy;
				//CommitEffect1(actor.MyEntity.ParentBody);
			//}
		//}
	}
	*/
}