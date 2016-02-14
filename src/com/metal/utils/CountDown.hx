package com.metal.utils;

/**
 * 计时器方法
 * @author 3D
 */
class CountDown
{

	public function new() 
	{
		
	}
	
	
	
	/**根据剩余秒数 转换成对应的Sting
	 * 0:保留到分
	 * 1：保留到小时
	 * **/
	static public function changeSenForTxt(seconds:Int,type:Int = 0):String
	{
		var time:String;
		var h:Int;
		var m:Int;
		var s:Int;
		h = Std.int(seconds / 3600);
		m = Std.int((seconds / 60)) % 60;
		s = seconds % 60;
		
		if (type == 0) {
			time = changeStr(m) + ":" + changeStr(s);
		}else {
			time = changeStr(h) + ":" + changeStr(m) + ":" + changeStr(s);
		}
		
		return time;
	}
	
	/**补0**/
	static public function changeStr(num:Int):String {
		var str:String;
		if (num >= 10) {
			str = Std.string(num);
		}
		else {
			str = "0" + Std.string(num);
		}
		return str;
	}
}