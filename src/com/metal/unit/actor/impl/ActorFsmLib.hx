package com.metal.unit.actor.impl;
import com.metal.fsm.FStateMachine;
import com.metal.unit.actor.api.ActorState;
/**
 * 行动者状态机库
 * @author weeky
 */
class ActorFsmLib 
{
	private static var _instance:ActorFsmLib = new ActorFsmLib();
	public static var instance(get, null):ActorFsmLib;
	private static function get_instance():ActorFsmLib { return _instance; }
	
	
	private var _actorFsm:FStateMachine;
	
	public function new() {
		_actorFsm = new FStateMachine();
		_actorFsm.addState(new ActorStateStand(), ActorState.Stand, false, [ActorState.Move, ActorState.Jump, ActorState.Attack, ActorState.Melee,ActorState.Skill, ActorState.Destroying,ActorState.Destroyed,  ActorState.Soul]);
		_actorFsm.addState(new ActorStateMove(), ActorState.Move, false, [ActorState.Stand, ActorState.Jump, ActorState.Attack, ActorState.Melee, ActorState.Skill,ActorState.Destroying,ActorState.Destroyed, ActorState.Soul]);
		_actorFsm.addState(new ActorStateEnter(), ActorState.Enter, false, [ActorState.Move, ActorState.Stand]);
		_actorFsm.addState(new ActorStateDoubleJump(), ActorState.DoubleJump, false, [ActorState.Attack, ActorState.Melee, ActorState.Destroying, ActorState.Destroyed, ActorState.Skill]);
		_actorFsm.addState(new ActorStateJump(), ActorState.Jump, false, [ActorState.Attack, ActorState.Melee, ActorState.Destroying, ActorState.Destroyed, ActorState.Skill]);
		_actorFsm.addState(new ActorStateAttack(), ActorState.Attack, false, [ActorState.Move, ActorState.Stand, ActorState.Jump, ActorState.Melee, ActorState.Skill,ActorState.Destroying,ActorState.Destroyed, ActorState.Soul]);
		_actorFsm.addState(new ActorStateMelee(), ActorState.Melee, false, [ActorState.Stand,ActorState.Skill,ActorState.Destroying,ActorState.Destroyed, ActorState.Soul]);
		_actorFsm.addState(new ActorStateThrowBomb(), ActorState.ThrowBomb, false, [ActorState.Stand,ActorState.Skill,ActorState.Destroying,ActorState.Destroyed, ActorState.Soul]);
		_actorFsm.addState(new ActorStateSkill(), ActorState.Skill, false, [ActorState.Move, ActorState.Stand, ActorState.Jump, ActorState.Injured, ActorState.Destroying,ActorState.Destroyed, ActorState.Soul]);
		_actorFsm.addState(new ActorStateDestroying(), ActorState.Destroying, false, [ActorState.Soul, ActorState.Destroyed, ActorState.Stand, ActorState.Revive]);
		_actorFsm.addState(new ActorStateDestroyed(), ActorState.Destroyed, false);
		_actorFsm.addState(new ActorStateVictory(), ActorState.Victory, false);
		_actorFsm.addState(new ActorStateSoul(), ActorState.Soul, false,[ActorState.Revive, ActorState.Stand]);
		_actorFsm.addState(new ActorStateRevive(), ActorState.Revive, false,[ActorState.Stand, ActorState.Move, ActorState.Jump, ActorState.Attack, ActorState.Melee,ActorState.Skill, ActorState.Destroying,ActorState.Destroyed, ActorState.Soul]);
	}
	
	public function getActorFsm():FStateMachine {
		return _actorFsm;
	}
}