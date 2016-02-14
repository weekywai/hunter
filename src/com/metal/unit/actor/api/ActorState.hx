package com.metal.unit.actor.api;
/**
 * 行动者状态
 * @author weeky
 */
enum ActionType
{
	none;
	idle_1;
	idle_2;
	walk_1;
	attack_1;
	attack_2;
	attack_3;
	attack_4;
	attack_walk;
	attack_5;
	attack_6;
	attack_7;
	melee_1;
	dead_1;
	jump_1;
	jump_2;
	debut_1;
	victory_1;
	cut_1;
	relax_1;
	skill_1;
	jump_attack_1;
	teshu_1;
	teshu_2;
	injured_1;
	throwBomb_1;
}
class ActorState 
{
	public static inline var None:Int = 0;
	public static inline var Stand:Int = 1;
	public static inline var Jump:Int = 2;
	public static inline var DoubleJump:Int = 3;
	public static inline var Move:Int = 4;
	public static inline var Relax:Int = 5;
	public static inline var Squat:Int = 6;
	
	// 以上状态可以射击
	public static inline var Enter:Int = 7;
	public static inline var Attack:Int = 8;
	public static inline var Melee:Int = 9;
	public static inline var Skill:Int = 10;
	public static inline var Injured:Int = 11;
	
	
	// 以下都是无效状态 可以用 >= 来判断
	public static inline var Destroying:Int = 12;
	public static inline var Soul:Int = 13;
	public static inline var SoulWait:Int = 14;
	public static inline var Destroyed:Int = 15;
	public static inline var Victory:Int = 16;
	public static inline var Revive:Int = 17;
	
	public static inline var ThrowBomb:Int = 18;
	
	
	public static function CanShoot(state:Int):Bool {
		return state <= DoubleJump || state == Melee;
	}
	public static function CanMelee(state:Int):Bool {
		return state <= Attack;
	}
	public static function IsDestroyed(state:Int):Bool {
		return state >= Destroying;
	}
	
	public static function GetAction(state:Int):ActionType {
		switch(state) {
			case Stand:
				return ActionType.idle_1;
			case Jump:
				return ActionType.jump_1;
			case DoubleJump:
				return ActionType.jump_2;
			case Move:
				return ActionType.walk_1;
			case Enter:
				return ActionType.debut_1;
			case Relax:
				return ActionType.relax_1;
			case Attack:
				return ActionType.attack_1;
			case Melee:
				return ActionType.cut_1;
			case Skill:
				return ActionType.skill_1;
			case Victory:
				return ActionType.victory_1;
			case Destroying:
				return ActionType.dead_1;
			case ThrowBomb:
				return ActionType.throwBomb_1;
			default:
				return ActionType.none;
				//return ActionType.idle_1;
		}
	}
}