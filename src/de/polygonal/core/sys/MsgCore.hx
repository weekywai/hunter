package de.polygonal.core.sys;
import de.polygonal.ds.Bits;

/**
 * ...
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	FREE,		/**移除*/
	PROCESS		/**进入进程 可发送事件*/
]))
class MsgCore
{
}