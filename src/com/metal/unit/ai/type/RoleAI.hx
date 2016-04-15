package com.metal.unit.ai.type;
import com.metal.unit.bevtree.BevNode;
import com.metal.unit.bevtree.BevNodePrioritySelector;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.node.Escape;
import com.metal.unit.bevtree.node.Idle;
import com.metal.unit.bevtree.precondition.AttackRadius;
import com.metal.unit.bevtree.node.Attack;
import com.metal.unit.bevtree.precondition.Hp;
import com.metal.unit.bevtree.precondition.VictoryEscape;
/**
 * ...
 * @author li
 */
class RoleAI extends AbstractAI
{

	public function new() 
	{
		super();
	}
	
	override public function createAI():BevNode 
	{
		super.createAI();
		
		var _playerRoot:BevNode = 
		new BevNodePrioritySelector("root").addChild(
			new Escape(AIStatus.Escape).setPrecondition(new VictoryEscape())
		).addChild(
			new Attack(AIStatus.Attack).setPrecondition(new AttackRadius())
		).addChild(
			new Idle(AIStatus.Idle)
		);
		
		return _playerRoot;
	}
	
}