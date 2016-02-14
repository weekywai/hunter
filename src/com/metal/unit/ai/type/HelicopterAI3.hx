package com.metal.unit.ai.type;
import com.metal.unit.bevtree.BevNode;
import com.metal.unit.bevtree.BevNodePrecondition;
import com.metal.unit.bevtree.BevNodePreconditionAND;
import com.metal.unit.bevtree.BevNodePrioritySelector;
import com.metal.unit.bevtree.BevNodeSequence;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.node.Attack;
import com.metal.unit.bevtree.node.Dead;
import com.metal.unit.bevtree.node.Enter;
import com.metal.unit.bevtree.node.Follow;
import com.metal.unit.bevtree.node.Idle;
import com.metal.unit.bevtree.precondition.AttackRadius;
import com.metal.unit.bevtree.precondition.Hp;
import com.metal.unit.bevtree.precondition.NotOnAttackStatus;
import com.metal.unit.bevtree.precondition.IsOnBornPos;
import com.metal.unit.bevtree.precondition.VerticalAttack;
import com.metal.unit.bevtree.precondition.WarnRadius;

/**
 * ...
 * @author li
 */
class HelicopterAI3 extends AbstractAI
{

	public function new() 
	{
		super();
	}
	
	override public function createAI():BevNode 
	{
		super.createAI();
		
		var ary:Array<BevNodePrecondition> = new Array();
		ary.push(new WarnRadius());
		ary.push(new NotOnAttackStatus());
		
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
			new Follow(AIStatus.Follow).setPrecondition(new BevNodePreconditionAND(ary))
		);
		
		return _monsterRoot;
	}
	
}