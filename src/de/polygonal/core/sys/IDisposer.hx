package de.polygonal.core.sys;

/**
 * ...
 * @author weeky
 */
interface IDisposer {
	/**
	 * 获取是否删除
	 */	
	var isDisposed(default, null) : Bool;
	/**
	 * 删除方法
	 */	
	function dispose() : Void;
}

