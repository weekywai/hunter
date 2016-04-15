package com.metal.fsm;
/**
 * 一个可共享的状态机，不要再状态中储存任何数据，数据应在具体的instance中储存
 * @author weeky
 */
class FStateMachine 
{
	private var _states:Array<FState>;
	
	public function new() {
		_states = [];
		// 0是默认的空状态
		_states[0] = FState.empty;
	}
	
	/**
	 * 添加状态
	 * @param	state
	 * @param	id
	 * @param	canQueueEvent
	 * @param	...transitions
	 */
	public function addState(state:FState, id:Int, canQueueEvent:Bool, ?transitions:Array<Int>):Void {
		if (_states[id] != null) throw ("State exist");
		state.id = id;
		state.canQueueEvent = canQueueEvent;
		_states[id] = state;
		if (transitions == null) return;
		for (tran in 0...transitions.length) {
			state.transitions[tran] = state;
		}
	}
	/**
	 * 是否能转换到指定状态
	 * @param	current  当前状态
	 * @param	targetID 目标状态
	 * @return 是否能转换
	 */
	public function canTransition(current:FState, targetID:Int):Bool {
		if (current != null) {
			if (current.id != 0) {
				return current.transitions[targetID] != null;
			} else {
				return true;
			}
		} else {
			return true;
		}
	}
	/**
	 * 转换状态
	 * @param	current  当前状态
	 * @param	targetID 目标状态
	 * @param	instance 逻辑对象
	 * @return 新的当前状态
	 */
	public function transition(current:FState, targetID:Int, instance:Dynamic):FState {
		if (current != null) {
			current.stateExit(instance);
		}
		var tarState:FState = _states[targetID];
		if (tarState != null) {
			tarState.stateEnter(instance);
			return tarState;
		} else {
			return FState.empty;
		}
	}
	
	/**
	 * 转换状态，如果当前状态时目标状态则忽略转换操作
	 * @param	current  当前状态
	 * @param	targetID 目标状态
	 * @param	instance 逻辑对象
	 * @return 新的当前状态
	 */
	public function transitionIgnoreSame(current:FState, targetID:Int, instance:Dynamic):FState {
		if (current != null) {
			if (current.id == targetID) return current;
			current.stateExit(instance);
		}
		var tarState:FState = _states[targetID];
		if (tarState != null) {
			tarState.stateEnter(instance);
			return tarState;
		} else {
			return FState.empty;
		}
	}
}
