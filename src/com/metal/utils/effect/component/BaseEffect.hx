package com.metal.utils.effect.component;

/**
 * ...
 * @author 3D
 */
class BaseEffect
{

	public function new(target:Dynamic = null, params:Dynamic = null , res:String = "")
	{
		this.target = target;
		this.back = res;
		if (params != null) {
			param = params;
			//Reflect.setField(this, "param", params);
			//parseParams(this.param,params);
		}
	}
	public var back:String;
	
	public var func:BaseEffect->Void;
	
	/**结束之后的回调**/
	public var finishFunc:Void->Void;
	
	/**参数**/
	public var param:Dynamic;
	
	/**被作用的目标**/
	public var target:Dynamic;
	
	public function play(endFunc:BaseEffect->Void):Void{
		func = endFunc;
	}
	
	/**
	 *  功能:完成特效
	 *  参数:
	 **/
	public function finish():Void
	{
		if(func != null){
			func(this);
		}
		if (finishFunc != null) {
			finishFunc();
			finishFunc = null;
		}
	}
	
	/**
	 *  功能:给参数赋值
	 *  参数:
	 **/
	public function parseParams(target:Dynamic,params:Dynamic):Void
	{
		var strArr:Array<String> = Reflect.fields(params);
		for (key in  strArr) {
			Reflect.setField(target, key, Reflect.getProperty(params,key));
		}
	}
	
	/**
	 *  功能:移除自身
	 *  参数:
	 **/
	//public function removeMe(...args):Void
	//{
		//for each(var dio:DisplayObject in args){
			//if(dio.parent)
				//dio.parent.removeChild(dio);
		//}
	//}
}