package com.metal.unit.ai.type;
import com.metal.unit.bevtree.BevNode;
import com.metal.unit.bevtree.BevNodePrioritySelector;
import com.metal.unit.bevtree.data.AIStatus;
import com.metal.unit.bevtree.node.Escape;
import com.metal.unit.bevtree.node.Patrol;
import com.metal.unit.bevtree.precondition.IsNeedEscape;
import com.metal.unit.bevtree.precondition.IsNeedPatrol;

/**
 * NPC
 * @author li
 */
class NpcAI extends AbstractAI
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
		.addChild( new Patrol(AIStatus.Patrol).setPrecondition(new IsNeedPatrol()) );
		
		return _monsterRoot;
	}
	
}