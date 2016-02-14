package com.metal.unit.ai.type;
import com.metal.unit.bevtree.BevNode;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.BevNodePreconditionOR;
import com.metal.unit.bevtree.BevNodePrioritySelector;
import com.metal.unit.bevtree.BevNodeSequence;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.node.Dead;
import com.metal.unit.bevtree.node.Attack;
import com.metal.unit.bevtree.node.Escape;
import com.metal.unit.bevtree.node.Follow;
import com.metal.unit.bevtree.node.Idle;
import com.metal.unit.bevtree.node.Patrol;
import com.metal.unit.bevtree.node.Skill;
import com.metal.unit.bevtree.node.Summon;
import com.metal.unit.bevtree.precondition.AppearTimes;
import com.metal.unit.bevtree.precondition.AttackRadius;
import com.metal.unit.bevtree.precondition.AttackTimes;
import com.metal.unit.bevtree.precondition.Hp;
import com.metal.unit.bevtree.precondition.IsNeedPatrol;
import com.metal.unit.bevtree.precondition.NotOnAttackStatus;
//import com.metal.unit.bevtree.precondition.IsOnAttackStatus;
import com.metal.unit.bevtree.precondition.Skill1;
import com.metal.unit.bevtree.precondition.Skill2;
import com.metal.unit.bevtree.precondition.Skill3;
import com.metal.unit.bevtree.precondition.Summon1;
import com.metal.unit.bevtree.precondition.Summon2;
import com.metal.unit.bevtree.precondition.Summon3;
import com.metal.unit.bevtree.precondition.WarnRadius;

/**
 * ...
 * @author li
 */
class Humanoid1 extends AbstractAI
{

	public function new() 
	{
		super();
	}
	
	override public function createAI():BevNode 
	{
		super.createAI();
		
		var arr:Array<BevNodePrecondition> = new Array();
		arr.push(new AppearTimes());
		arr.push(new AttackTimes());
		
		var _monsterRoot:BevNode = 
		new BevNodePrioritySelector("root")
		.addChild(
			new Dead(AIStatus.Dead).setPrecondition(new Hp(0, 0, false))	
		)
		//.addChild(
			//new Attack(AIStatus.Attack).setPrecondition(new AttackRadius())
			////.addChild( new Idle("Idle").setPrecondition(new IsOnAttackStatus()) )
			////new BevNodePrioritySelector("Attack").setPrecondition(new AttackRadius())
			////.addChild(new Skill("Skill1", 1).setPrecondition(new Skill1()))
			////.addChild(new Skill("Skill2", 2).setPrecondition(new Skill2()))
			////.addChild(new Skill("Skill3", 3).setPrecondition(new Skill3()))
			////.addChild(new Summon("Summon", 1).setPrecondition(new Summon1()))
			////.addChild(new Summon("Summon", 2).setPrecondition(new Summon2()))
			////.addChild(new Summon("Summon", 3).setPrecondition(new Summon3()))
			////.addChild(new Attack("Attack"))	
		//)
		.addChild(
			new BevNodeSequence("BaseAttack")
			//.addChild(
				//new BevNodePrioritySelector("Attack").setPrecondition(new VerticalAttack())
				//.addChild(new Skill("Skill1", 1).setPrecondition(new Skill1()))
				//.addChild(new Skill("Skill2", 2).setPrecondition(new Skill2()))
				//.addChild(new Skill("Skill3", 3).setPrecondition(new Skill3()))
				//.addChild(new Summon("Summon", 1).setPrecondition(new Summon1()))
				//.addChild(new Summon("Summon", 2).setPrecondition(new Summon2()))
				//.addChild(new Summon("Summon", 3).setPrecondition(new Summon3()))
				//.addChild(new Attack("Attack"))	
			//)
			.addChild( new Attack(AIStatus.Attack).setPrecondition(new AttackRadius()) )
			.addChild( new Idle(AIStatus.Idle).setPrecondition(new NotOnAttackStatus()) )
		);
		//.addChild(
			//new Idle(AIStatus.Idle).setPrecondition(new Hp())
		//);
		
		return _monsterRoot;
	}
	
}