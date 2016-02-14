package com.metal.config;
import haxe.ds.IntMap;

/**
 * ...
 * @author weeky
 */
class RequestType
{
	public static var urlList:Array<String> = [
		"metal/index.php",					//test
		"metal/e/member/doaction.php",				//test
	];
	
	public static var Success:Int = 0;
	public static var DbError:Int = 2;
	//注册类型
	public static var PwdErr:Int = 11;
	public static var ReUsername:Int = 12;
	public static var NotSpeWord:Int = 13;
	public static var NotRepassword:Int = 14;
	public static var EmptyMember:Int = 15;
	public static var LoginToRegister:Int = 16;
	public static var FaiUserlen:Int = 17;
	public static var FailPasslen:Int = 18;
	public static var CloseRegister:Int = 19;
	//登陆
	public static var EmptyLogin:Int = 20;
}