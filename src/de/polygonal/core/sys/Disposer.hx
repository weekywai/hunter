package de.polygonal.core.sys;

import de.polygonal.core.util.ClassUtil;
import flash.errors.Error;

/**
 * ...
 * @author weeky
 */
class Disposer implements IDisposer {
	public var isDisposed(default, null) : Bool;
	
	var _disposedHook : Void->Void;
	public function new() {
		isDisposed = false;
		isOnDisposeCalled = false;
	}

	public function ConfigDisposedCallBack(disposedHook : Dynamic = null) : Void {
		_disposedHook = disposedHook;
	}

	/*  删除部分****************************************************
	 * 
	 * 
	 */ 
	 public function dispose() : Void {
		if(isDisposed) 
			return;
		isDisposed = true;
		// 再解除所有其他逻辑引用
		onDispose();
		if(!isOnDisposeCalled)  {
			throw new Error("base.OnDisposing not called : " + toString());
		}
		if(_disposedHook != null) 
			//TODO _disposedHook(this);
			_disposedHook();
		_disposedHook = null;
	}

	// 必定onDispose（层层检查）
	private var isOnDisposeCalled : Bool;
	function onDispose() : Void {
		isOnDisposeCalled = true;
	}

	/*  检查部分****************************************************
	 * 
	 * 
	 */	// trace使用显示名称
	public function toString() : String {
		return "[" + ClassUtil.getUnqualifiedClassName(this) + "]";
	}

	function mytrace(msg : Dynamic, caller : Dynamic = null) : Void {
		if(caller == null)  {
			trace(toString() + " >> " + msg);
		}
		else  {
			trace(toString() + "-" + caller + " >> " + msg);
		}
	}

}

