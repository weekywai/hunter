package com.metal.unit.ai.type;
import com.metal.unit.bevtree.BevNode;
import com.metal.unit.bevtree.BevNodePrioritySelector;
import com.metal.unit.bevtree.BevNodeSequence;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.node.Dead;
import com.metal.unit.bevtree.node.Attack;
import com.metal.unit.bevtree.node.Enter;
import com.metal.unit.bevtree.node.Idle;
import com.metal.unit.bevtree.precondition.AttackRadius;
import com.metal.unit.bevtree.precondition.Hp;
import com.metal.unit.bevtree.precondition.NotOnAttackStatus;
import com.metal.unit.bevtree.precondition.IsOnBornPos;

/**
 * 直升飞机ai类型1
 * @author li
 */
class HelicopterAI1 extends AbstractAI
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
			new BevNodeSequence("BaseAttack")
			.addChild( new Attack(AIStatus.Attack).setPrecondition(new AttackRadius()) )
			.addChild( new Idle(AIStatus.Idle).setPrecondition(new NotOnAttackStatus()) )
		)
		.addChild(
			new Idle(AIStatus.Idle).setPrecondition(new NotOnAttackStatus())
		);
		
		return _monsterRoot;
	}
	
}