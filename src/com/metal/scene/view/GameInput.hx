package com.metal.scene.view;

//import com.metal.message.MsgInput;
//import com.metal.unit.event.Unit_I_Move;
import suity.input.api.MouseEvent;
import suity.input.api.TouchPoint;
import suity.sim.SimMessage;
import suity.sim.input.impl.InputComponent;
import suity.sim.tick.api.MsgTick;

/**
 * 输入组件
 * @author weeky
 */
class GameInput extends InputComponent
{

	public function new() 
	{
		super();
		
	}
	override function onInitSimComponent():Void 
	{
		super.onInitSimComponent();
		//addMessageListenerFunc(MsgInput.AddInputBlocker, Cmd_AddInputBlocker);
		//addMessageListenerFunc(MsgInput.RemoveInputBlocker, Cmd_RemoveInputBlocker);
		addMessageListenerFunc(MsgTick.OnPreUpdate, Cmd_Update);
	}
	
	public function sendDirInput(dir:Int):Void
	{
		//sendMessage(MsgInput.UserInput, new Unit_I_Move(dir));
	}
	
	private function Cmd_AddInputBlocker(msg:SimMessage):Void {
		addInputBlocker(msg.content);
	}
	private function Cmd_RemoveInputBlocker(msg:SimMessage):Void {
		removeInputBlocker(msg.content);
	}
	private function Cmd_Update(msg:SimMessage):Void {
		update();
	}
	
	override private function onMouseUp(e:MouseEvent) : Void {
		//sendMessage(MsgInput.MouseUp, e);
	}
	override private function onMouseDown(e:MouseEvent) : Void {
		//sendMessage(MsgInput.MouseDown, e);
	}
	/** 处理触摸事件 */
	override private function onTouchDown(e:TouchPoint):Void {
		//sendMessage(MsgInput.MouseDown, e);
	}
	override private function onTouchMove(e:TouchPoint):Void {
		//sendMessage(MsgInput.MouseMove, e);
	}
	override private function onTouchUp(e:TouchPoint):Void {
		//sendMessage(MsgInput.MouseUp, e);
	}
}