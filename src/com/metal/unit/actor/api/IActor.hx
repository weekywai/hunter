package com.metal.unit.actor.api;
import com.metal.enums.Direction;
import com.metal.scene.board.api.IBoardItem;
import de.polygonal.core.sys.IDisposer;
import openfl.geom.Point;

/**
 * 行动者
 * @author weeky
 */
interface IActor extends IBoardItem extends IDisposer
{
	/**
	 * 绑定的玩家,  >=0 是玩家  <0 非玩家
	 */
	var bindPlayerID(get, null):Int;
	
	/**
	 * ActorState枚举
	 */
	var stateID(get, null):Int;
	/**
	 * 是否可以转换到另一个状态
	 * @param	targetStateID
	 * @return
	 */
	function canTransition(targetStateID:Int):Bool;
	
	/**
	 * 方向(向)
	 */
	var dir(get, set):Direction;
	/**
	 * 移动速度
	 */
	var velocity:Point;
	
	
	/**
	 * 是否需要向左翻转
	 * */
	var isNeedLeftFlip:Bool;
	/**
	 * 是否需要向右翻转
	 * */
	var isNeedRightFlip:Bool;
}