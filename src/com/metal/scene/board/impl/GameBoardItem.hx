package com.metal.scene.board.impl ;
import com.metal.message.MsgActor;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.board.api.IBoardItem;
import de.polygonal.core.es.EntitySystem;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.SimEntity;
import openfl.errors.Error;
/**
 * ...
 * @author weeky
 */
class GameBoardItem extends Component implements IBoardItem
{
	var _itemType:Int = 0;
	public var unitType(get, null):Int;
	private function get_unitType():Int { return _itemType; }
	
	var _faction:Int = BoardFaction.None;
	public var faction(get, null):Int;
	private function get_faction():Int { return _faction; }
	
	public function isInBoard():Bool {
		return owner.parent!=null;
	}
	
	
	public var width(get, null):Float;
	private function get_width():Float { return 0; }
	public var height(get, null):Float;
	private function get_height():Float { return 0; }
	public var halfWidth(get, null):Float;
	private function get_halfWidth():Float { return 0; }
	public var halfHeight(get, null):Float;
	private function get_halfHeight():Float { return 0; }
	
	public var x(default, default):Float = 0;
	//private function get_x():Float { return _quadItem.X; }
	public var y(default, default):Float = 0;
	//private function get_y():Float { return _quadItem.Y; }
	
	public function attackable():Bool { return true; }
	public function aimable():Bool { return true; }
	public function showInRadar():Bool { return true; }
	public function alwaysCanSee():Bool { return false; }
	public function canDamage():Bool { return true; }
	public function hitTestFaction():Bool { return true; }
	
	public function new() {
		super();
	}
	override function onDispose():Void {
		detachFromBoard();
		//_quadItem = null;
		super.onDispose();
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgActor.ExitBoard:
				Notify_ExitBoard(Notify_ExitBoard);
			case MsgActor.InitFaction:
				Notify_InitFaction(userData);
		}
	}
	
	private function Notify_InitFaction(userData:Dynamic):Void {
		_faction = userData.faction;
	}
	private function Notify_ExitBoard(userData:Dynamic):Void {
		//trace(this, "", owner.name + " Unit_O_ExitBoard");
		detachFromBoard();
	}
	
	/**
	 * 脱离场景挂接。脱离场景不需要和Board打交道，可以直接在此执行脱离操作
	 */
	function detachFromBoard():Void {
		var board = GameProcess.root.findChild("GameBoard");
		if (board == null ) throw new Error("GameBoard is null");
		var gameboard:GameBoard = cast(board, SimEntity).getComponent(GameBoard);
		if (gameboard.units != null)
			gameboard.units.remove(this);
		owner.free();
		//owner.remove();
	}
	
	function initItemType(type:Int):Void {
		if (!isInBoard()) throw "is in gameboard list";
		_itemType = type;
	}
}