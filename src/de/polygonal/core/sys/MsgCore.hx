package de.polygonal.core.sys;
import de.polygonal.ds.Bits;

/**
 * ...
 * @author weeky
 */
class MsgCore
{
	/**添加 
	 * 并没有进入进程不能发送事件
	 */
	//public inline static var ADDED = Bits.BIT_06;
	/**移除*/
	public inline static var FREE = Bits.BIT_07;
	//public inline static var REMOVED = Bits.BIT_07;
	/**进入进程 可发送事件*/
	public inline static var PROCESS = Bits.BIT_08;
}