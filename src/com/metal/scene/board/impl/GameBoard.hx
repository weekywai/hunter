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
	private var _units:List<GameBoardItem>;
	public var units(get, null):List<GameBoardItem>;
	private function get_units():List<GameBoardItem>
	{
		return _units;
	}
	private var _startAI:Bool;
	// 类型缓冲 u:UnitType  v:Faction
	//private var _typeCache:DLL<Dynamic>; // Type, Faction
	
	public function new() 
	{
		super();
		_units = new List();
		_startAI = false;
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
	}
	
	override function onDispose():Void {
		cmd_Reset(null);
		_units = null;
		super.onDispose();
	}
	
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgStartup.Start:
				cmd_Start(userData);
			case MsgStartup.Reset:
				cmd_Reset(userData);
			case MsgBoard.AssignUnit:
				cmd_AssignUnit(userData);
			case MsgBoard.StartAI:
				cmd_StartAI();
		}
		super.onNotify(type, source, userData);
	}
	private function cmd_Start(userData:Dynamic):Void {
		
	}
	private function cmd_Reset(userData:Dynamic):Void {
		var itr = _units.iterator();
		var item:GameBoardItem = itr.next();
		while (item != null) {
			item.owner.free();
			item = itr.next();
		}
		//owner.treeNode.clear();
		_units.clear();
		_startAI = false;
	}
	
	private function cmd_AssignUnit(userData:Dynamic)
	{
		addUnitEntity(userData);
	}
	private function cmd_StartAI()
	{
		var itr = _units.iterator();
		var item:GameBoardItem = itr.next();
		while (item != null) {
			item.notify(MsgInput.SetInputEnable, true);
			item = itr.next();
		}
		_startAI = true;
	}
	
	public function addUnitEntity(entity:SimEntity):Bool {
		if (isDisposed) 
			return false;
		
		// 如果已经存在就返回
		var item:GameBoardItem = cast entity.getComponent(MTActor);
		if (item == null)
			item = cast entity.getComponent(UnitActor);
		//trace(entity.id+"::"+_units.contains(item));
		if (item == null)
			return false;
		if (Lambda.has(_units,item)) 
			return false;
		_units.add(item);
		
		owner.add(entity);
		// 发送进入游戏板信号
		entity.notify(MsgActor.EnterBoard);
		if (_startAI){
			entity.notify(MsgInput.SetInputEnable, true);
		}
		return true;
	}
	
	public function onCameraEntity():Array<SimEntity>
	{
		var list:Array<SimEntity> = [];
		var itr = _units.iterator();
		var item:BaseActor =  cast itr.next();
		while (item != null) {
			if (item != null && item.onCamera()) {
				list.push(item.owner);
			}
			item =  cast itr.next();
		}
		return list;
	}
}