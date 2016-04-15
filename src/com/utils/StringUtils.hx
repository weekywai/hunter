package com.utils;
import openfl.errors.Error;

/**
 * ...
 * @author weeky
 */

class StringUtils 
{

	public function new() {
		
	}
	public static function IsEmptyMeaning(str:String):Bool {
		return (str == null || str == "" || str == "null" || str == "undefined");
	}
	
	public static function IsEmptyMeaningEX(strs:Array<String>):Bool {
		for (str in strs) {
			if (IsEmptyMeaning(str)) return true;
		}
		return false;
	}
	public static function IsNullOrEmpty(str:String):Bool {
		return (str == null || str == "");
	}
		
	public static function NotEmpty(str:String):Bool {
		return !IsNullOrEmpty(str);
	}
		
	public static function IsNullOrEmptyEx(strs:Array<String>):Bool {
		for (str in strs) {
			if (IsNullOrEmpty(str)) return true;
		}
		return false;
	}	
		
	public static function GetUnicodeLen(str:String):Int {
		if (IsNullOrEmpty(str)) return 0;
		
		var len:Int = 0;
		for (i in 0...str.length) {
			var code:Int = str.charCodeAt(i);
			if (code < 256) {
				len++;
			} else {
				len += 2;
			}
		}
		return len;
	}
	public static function GetUnicodeHeadString(str:String, len:Int):String {
		if (len <= 0 || IsNullOrEmpty(str)) return "";
		var realLen:Int = len;
		var result:String = str.substr(0, realLen);
		while (GetUnicodeLen(result) > len) {
			realLen--;
			result = str.substr(0, realLen);
		}
		return result;
	}
		
	public static function FillZero(x:String, n:Int):String{
		var s = '';
		for (i in 0...n - x.length) s += '0';
		return s + x;
	}
		
	public static function SplitFirst(str:String, split:String = " "):Array<String> {
		var index:Int = str.indexOf(split);
		var ary:Array<String> = new Array<String>();
		if (index >= 0) {
			ary.push(str.substr(0, index));
			ary.push(str.substr(index + 1, str.length - index + 1));
		} else {
			ary.push(str);
			ary.push(null);
		}
		return ary;
	}
		
	/**
	 * Replaces instances of less then, greater then, ampersand, single and double quotes.
	 * @param str String to escape.
	 * @return A string that can be used in an htmlText property.
	 */		
	public static function escapeHTMLText(str:String):String {
		var chars:Array<Dynamic> = 
		[
			{char:"&", repl:"|amp|"},
			{char:"<", repl:"&lt;"},
			{char:">", repl:"&gt;"},
			{char:"\'", repl:"&apos;"},
			{char:"\"", repl:"&quot;"},
			{char:"|amp|", repl:"&amp;"}
		];
		
		for(i in 0...chars.length)
		{
			while(str.indexOf(chars[i].char) != -1)
			{
				str = replace(str, chars[i].char, chars[i].repl);
			}
		}
		
		return str;
	}
		
	public static function replace(source:String, replace:String,replaceWith:String):String
	{
		var len:Int = source.indexOf(replace);
		var strStart:String = source.substr(0, source.indexOf(replace));
		var strEnd:String = source.substring(len + replace.length);
		source = strStart + replaceWith + strEnd;
		while (source.indexOf(replace) > -1) {
			source = StringUtils.replace(source, replace, replaceWith);
		}
		return source;
	}
		
	public static function replaceAt(source:String, index:Int, replaceWith:String):String {
		var beginStr:String = source.substr(0, index);
		var endStr:String = source.substr(index + 1, source.length);
		return beginStr + replaceWith + endStr;
	}
		
	public static function stringTOInArray(str:String, sep:String=" "):Array<String> {
		if (IsEmptyMeaning(str))
			return null;
		var result:Array<String> = str.split(sep);
		return result;
	}
		
	public static function Trim(str:String, trim:String = " "):String {
		str = TrimLast(TrimFirst(str, "　"), "　");
		return TrimLast(TrimFirst(str, trim), trim);
	}
	public static function TrimFirst(str:String, trim:String = " "):String {
		for (i in 0...str.length) {
			var char:String = str.charAt(i);
			if (trim != char) {
				if (i > 0) {
					return str.substr(i, str.length - i);
				} else {
					return str;
				}
			}
		}
		return "";
	}
	public static function TrimLast(str:String, trim:String = " "):String {
		for (i in 0...str.length) {
			var char:String = str.charAt(str.length - i - 1);
			if (trim != char) {
				if (i > 0) {
					return str.substr(0, str.length - i);
				} else {
					return str;
				}
			}
		}
		return "";
	}
		
	public static function Split(str:String, delim:String = " "):Array<String> {
		if (StringUtils.IsNullOrEmpty(str)) return [];
		
		var read:Bool = false;
		var strStart:Int = 0;
		var ary:Array<String> = new Array<String>();
		
		for (i in 0...str.length) {
			var char:String = str.charAt(i);
			
			if (read) {
				if (char == delim) {
					read = false;
					ary.push(str.substring(strStart, i));
				}
			} else {
				if (char != delim) {
					read = true;
					strStart = i;
				}
			}
		}
		if (read) {
			ary.push(str.substring(strStart, str.length));
		}
		return ary;
	}
		
	public static function SplitAndTrim(str:String, splitDelim:String = ";", trimDelim:String = " "):Array<String> {
		var ary:Array<String> = Split(str, splitDelim);
		for (i in 0...ary.length) {
			ary[i] = Trim(ary[i], trimDelim);
		}
		return ary;
	}
		
	public static function SplitAndTrimEx(str:String, splitDelim:String = ";", trimDelim:String = " ", treatAsNull:String = "-"):Array<String> {
		var ary:Array<String> = Split(str, splitDelim);
		for (i in 0...ary.length) {
			var str:String = Trim(ary[i], trimDelim);
			if (str == treatAsNull) str = null;
			ary[i] = str;
		}
		return ary;
	}
		
		
	public static function Format(str:String, ?args:Array<String>):String {
		var inText:Bool = true;
		var strStart:Int = 0;
		var ary:Array<Int> = new Array<Int>();
		for (i in 0...str.length) {
			var char:String = str.charAt(i);
			
			if (inText) {
				if (char == "{") {
					inText = false;
					ary.push(Std.parseInt(str.substring(strStart, i)));
					strStart = i+1;
				} else if (char == "}") {
					throw new Error("Pattern format error.");
				}
			} else {
				if (char == "}") {
					inText = true;
					ary.push(Std.parseInt(str.substring(strStart, i)));
					strStart = i+1;
				} else if (char == "{") {
					throw new Error("Pattern format error.");
				}
			}
		}
		if (inText) {
			ary.push(Std.parseInt(str.substring(strStart, str.length)));
		} else {
			throw new Error("Pattern format error.");
		}
		
		var result:String = "";
		for (i in 0...ary.length) {
			if (ary[i]>0) {
				result += args[ary[i]];
			} else {
				result += ary[i];
			}
		}
		return result;
	}
		
	/**
	 * 检测屏蔽字
	 * @param	source
	 * @param	wordLib
	 * @return
	 */
	public static function checkScreening(source:String, wordLib:Array<String>):String {
		var len:Int = wordLib.length;
		for (i in 0...len) 
		{
			var searchStr:String = wordLib[i];
			if (source.indexOf(searchStr) > -1) 
				source = replace(source, searchStr, replaceWord(searchStr.length));
		}
		return source;
	}
		
	private static function replaceWord(len:Int):String {
		var returnStr:String = "";
		for (i in 0...len)  {
			returnStr += "*";
		}
		return returnStr;
	}
		
	public static function formatTime(date:Date):String {
		var hoursNum:String = Std.string(date.getHours());
		hoursNum = (Std.parseInt(hoursNum) < 10)?("0" + hoursNum):(hoursNum);
		var minutesNum:String = Std.string(date.getMinutes());
		minutesNum = (Std.parseInt(minutesNum) < 10)?("0" + minutesNum):(minutesNum);
		var secondNum:String = Std.string(date.getSeconds());
		secondNum = (Std.parseInt(secondNum) < 10)?("0" + secondNum):(secondNum);
		return hoursNum + ":" + minutesNum + ":" + secondNum;
	}
		
	public static function SecondToString(second:Int):String  {
		var result:String = "";
		if (second >= 3600) {
			if (second / 3600 < 10) result += "0";
			result += Std.int(second / 3600);
			result += ":";
		}else {
			result += "00:";
		}
		second = second % 3600;
		if (second >= 60) {
			if (second / 60 < 10) result += "0";
			result += Std.int(second / 60);
			result += ":";
		}else {
			result += "00:";
		}
		second = second % 60;
		if (second < 10) result += "0";
		result += second;
		return result;
	}
		
	public static function GetTime(timenum:Float):String{
		var h:Int = Std.int(timenum / 3600);
		var m:Int = Std.int((timenum % 3600) / 60);
		var s:Int = Std.int(timenum % 60);
		var t:String = "";
		if (timenum > 0) {
			if (s >= 0) {
				if (s >= 10) {
					t = Std.string(s);
				} else {
					t = "0" + s;
				}
			}
			if (m >= 0) {
				if (m >= 10) {
					t = m + ":" + t;
				} else {
					t = "0" + m + ":" + t;
				}
			}
			if (h >= 0) {
				if (h >= 10) {
					t = h + ":" + t;
				} else {
					t = "0" + h + ":" + t;
				}
			}
		} else {
			t = "00:00:00";
		}
		return t;
	}
	
	public static function GetInt(str:String, init:Int=0):Int 
	{
		if (str == null)
			return init;
		return Std.parseInt(str);
	}
	public static function GetFloat(str:String, init:Float=0):Float 
	{
		if (str == null)
			return init;
		return Std.parseFloat(str);
	}
}