package com.metal.unit.ai.type;
import com.metal.unit.bevtree.BevNode;
import com.metal.unit.bevtree.BevNodePrioritySelector;
import com.metal.unit.bevtree.BevNodeSequence;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.node.Dead;
import com.metal.unit.bevtree.node.Enter;
import com.metal.unit.bevtree.node.Idle;
import com.metal.unit.bevtree.node.Move;
import com.metal.unit.bevtree.node.Skill;
import com.metal.unit.bevtree.precondition.Hp;
import com.metal.unit.bevtree.precondition.IsOnBornPos;

/**
 * b001
 * @author li
 */
class BossAI5 extends AbstractAI
{

	public function new() 
	{
		super();
	}
	
	override public function createAI():BevNode 
	{
		super.createAI();
		
		var _monsterRoot:BevNode = 
		new BevNodePrioritySelector("root")
		.addChild(
			new Dead(AIStatus.Dead).setPrecondition(new Hp(0, 0, false))
		)
		.addChild(
			new Enter(AIStatus.Enter).setPrecondition(new IsOnBornPos())
		)
		.addChild(
			new BevNodeSequence("BaseAttack").setPrecondition(new Hp(0.6, 1))
			.addChild( new Skill(AIStatus.Skill0, 0) )
			.addChild( new Idle(AIStatus.Idle) )
			.addChild( new Skill(AIStatus.Skill1, 1) )
			.addChild( new Idle(AIStatus.Idle) )
		)
		.addChild(
			new BevNodeSequence("BaseAttack").setPrecondition(new Hp(0, 0.6))
			.addChild( new Skill(AIStatus.Skill0, 0) )
			.addChild( new Idle(AIStatus.Idle) )
			//.addChild( new Move("MoveLeft", true) )
			.addChild( new Skill(AIStatus.Skill2, 2) )
			.addChild( new Idle(AIStatus.Idle) )
			//.addChild( new Move("MoveRight", false) )
			.addChild( new Skill(AIStatus.Skill1, 1) )
			.addChild( new Idle(AIStatus.Idle) )
		);
		
		return _monsterRoot;
	}
}