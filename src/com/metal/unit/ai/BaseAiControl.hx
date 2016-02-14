package com.metal.unit.ai;
import com.metal.message.MsgActor;
import com.metal.message.MsgInput;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.impl.BaseActor;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;

/**
 * ...
 * @author li
 */
class BaseAiControl extends Component
{
	private var _actor:BaseActor;
	private var _stop:Bool;
	
	public function new() 
	{
		super();
		_stop = true;
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		//_actor = owner.getComponent(MTActor);
	}
	
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgActor.EnterBoard:
				cmd_enterBoard();
			case MsgActor.Destroying:
				cmd_Destroying();
			case MsgActor.Destroy:
				cmd_Destroy();
			case MsgActor.BornPos:
				cmd_BornPos(userData);
			case MsgInput.SetInputEnable:
				cmd_SetInputEnable(userData);
		}
		super.onNotify(type, source, userData);
	}
	
	private function cmd_BornPos(userData:Dynamic):Void {}
	
	private function cmd_enterBoard():Void {
		initData();
	}
	private function cmd_Destroying()
	{
		_stop = true;
	}
	private function cmd_Destroy()
	{
		owner.removeComponent(this);
	}
	
	private function cmd_SetInputEnable(userData):Void 
	{
		
		_stop = !userData;
	}
	public function initData():Void {}
	
	override public function onTick(timeDelta:Float) 
	{
		super.onTick(timeDelta);
	}
	private function Input_Enter(userData:Dynamic):Void {
		notify(MsgActor.Enter, userData);
	}
	private function Input_Move(userData:Dynamic):Void {
		notify(MsgActor.Move, userData);
	}
	private function Input_Attack(userData:Dynamic):Void {
		//if (!_actor.canTransition(ActorState.Melee)) return;
		notify(MsgActor.Attack, userData);
	}
	
	private function Input_Stand(userData:Dynamic):Void {
		if(_actor.stateID!= ActorState.Stand)
			notify(MsgActor.Stand, _actor.dir);
	}
	
	private function Input_Skill(userData:Dynamic):Void {
		notify(MsgActor.Skill, userData);
	}
	
	private function Input_Patrol(userData:Dynamic):Void {
		notify(MsgActor.Patrol, userData);
	}
	
	private function Input_Escape(userData:Dynamic):Void {
		notify(MsgActor.Escape, userData);
	}
	
	override function onDispose():Void 
	{
		super.onDispose();
		_actor = null;
	}
	
	
}