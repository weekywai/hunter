package com.metal.fsm;
/**
 * 状态类
 * @author weeky
 */
class FState 
{
	private static var _empty:FState = new FState();
	public static var empty(get, null):FState;
	private static function get_empty():FState { return _empty; }
	
	private var _id:Int;
	/**
	 * 状态ID
	 */
	public var id(get, set):Int;
	private function get_id():Int { return _id; }
	private function set_id(value:Int):Int { _id = value; return _id; }
	
	var _transitions:Array<FState>;
	public var transitions(get, null): Array<FState>;
	function get_transitions():Array<FState> { return _transitions; }
	
	/** 状态是否可以缓冲事件暂不处理 */
	public var canQueueEvent(default, default):Bool = false;
	
	public function new() {
		_transitions = [];
	}
	
	/**
	 * 是否可以转换到指定状态
	 * @param	$targetID
	 * @return
	 */
	public function canTransition(targetID:Int):Bool {
		return _transitions[targetID] != null;
	}
	/**
	 * 状态进入
	 * @param	$instance
	 */
	public function stateEnter(instance:Dynamic):Void {
	}
	/**
	 * 状态退出
	 * @param	instance
	 */
	public function stateExit(instance:Dynamic):Void {
	}
	/**
	 * 状态更新
	 * @param	instance
	 */
	public function update(instance:Dynamic):Void {
	}
	
}