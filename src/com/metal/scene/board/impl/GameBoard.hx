package com.metal.scene.board.impl ;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgInput;
import com.metal.message.MsgStartup;
import com.metal.unit.actor.impl.BaseActor;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.impl.UnitActor;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.SimEntity;

/**
 * 游戏板
 * @author weeky
 */
class GameBoard extends Component
{
	public var units(default, null):List<SimEntity>;
	private var _startAI:Bool;
	
	public function new() 
	{
		super();
		units = new List();
		_startAI = false;
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
	}
	
	override function onDispose():Void {
		cmd_Reset(null);
		units = null;
		super.onDispose();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgStartup.Start:
				cmd_Start(userData);
			case MsgStartup.Reset:
				cmd_Reset(userData);
			case MsgBoard.AssignUnit:
				cmd_AssignUnit(userData);
			case MsgBoard.RemoveUnit:
				cmd_RemoveUnit(userData);
			case MsgBoard.StartAI:
				cmd_StartAI();
		}
		super.onUpdate(type, source, userData);
	}
	private function cmd_Start(userData:Dynamic):Void {
		
	}
	private function cmd_Reset(userData:Dynamic):Void {
		var itr = units.iterator();
		var item:SimEntity = itr.next();
		while (item != null) {
			item.free();
			item = itr.next();
		}
		units.clear();
		_startAI = false;
	}
	
	private function cmd_AssignUnit(userData:Dynamic)
	{
		addUnitEntity(userData);
	}
	private function cmd_StartAI()
	{
		var itr = units.iterator();
		var item:SimEntity = itr.next();
		while (item != null) {
			item.notify(MsgInput.SetInputEnable, true);
			item = itr.next();
		}
		_startAI = true;
	}
	private function cmd_RemoveUnit(userData:Dynamic):Void {
		//trace ("remove" +userData);
		var item:SimEntity = userData;
		units.remove(item);
		item.free();
	}
	
	private function addUnitEntity(item:SimEntity):Bool {
		if (isDisposed) 
			return false;
		
		// 如果已经存在就返回
		if (item == null)
			return false;
		if (Lambda.has(units,item)) 
			return false;
		units.add(item);
		
		owner.add(item);
		// 发送进入游戏板信号
		item.notify(MsgActor.EnterBoard);
		if (_startAI){
			item.notify(MsgInput.SetInputEnable, true);
		}
		return true;
	}
	
	public function onCameraEntity():Array<SimEntity>
	{
		var list:Array<SimEntity> = [];
		var itr = units.iterator();
		var item:SimEntity = itr.next();
		var actor:BaseActor;
		while (item != null) {
			actor = cast item.getComponent(MTActor);
			if (actor == null)
				actor = cast item.getComponent(UnitActor);
			if (actor != null && actor.onCamera()) {
				list.push(item);
			}
			item = itr.next();
		}
		return list;
	}
}