package com.metal.ui.forge.component;

/**
 * 解析描述
 * @author hyg
 */
class DetailAnalysis
{
	private var pos:Int;
	public function new() 
	{
		
	}
	public function analysis(str:String):Array<Array<Int>>
	{
		str = str.substr(1, str.length - 2);
		
		pos= 0;
		
		var arr:Array<String> = returnStr(str);
		//trace("===========array===" + arr + "=====" + arr.length);
		var arr_1:Array<String> = [];
		var arr_2:Array<Int> = [];
		var arr_3:Array<Array<Int>> = [];
		var indexStr:String="";
		for (i in 0...(arr.length))
		{
			arr_2 = [];
			indexStr = arr[i];
			arr_1 = indexStr.split(",");
			for ( j in 0...(arr_1.length))
			{
				var num:Int = Std.parseInt(arr_1[j]);
				arr_2.push(num);
			}
			arr_3.push(arr_2);
		}
		
		
		return arr_3;

	}
	
	private function returnStr(str:String):Array<String>
	{
		var str_2:String = str;
		var startPos:Int=0;
		var endPos:Int=0;
		var str_1:String = "";
		var str_3:String = "";
		var arr:Array<String> = [];
		for (i in 0...(str.length))
		{
			str_1 = "";
			str_1 = str.charAt(pos++);
			if (str_1 == "{")
			{
				continue;
			}
			if (str_1 == "}")
			{
				arr.push(str_3);
				str_3 = "";
				pos++;
			}
			if (str_1 != "{" && str_1 != "}")
			{
				str_3 += str_1;
			}
		}
		return arr;
	}
}