package com.metal.unit.actor.impl;
import com.metal.fsm.FState;
import com.metal.message.MsgActor;
/**
 * ...
 * @author main
 */
class ActorStateDestroyed extends FState 
{
	
	public function new() 
	{
		super();
	}
	
	override public function update(instance:Dynamic):Void 
	{
		//var actor:MTActor = cast instance;
		//actor.owner.notify(MsgActor.ExitBoard);
		//super.update(instance);
	}
	
}