package com.metal.config;

/**
 * ...
 * @author weeky
 */
enum GameMsgType {
	SkillFreeze;
	//SkillInsufficient; 
}
class MsgType
{

	public static function getMsg(type:Int):String
	{
		var msg:String =
		switch(type) {
			case RequestType.Success: "成功！";
			case RequestType.DbError: "数据库出错！";
			case RequestType.PwdErr:"密码错误！";
			case RequestType.ReUsername:"此用户名已存在，请重输一个！";
			case RequestType.NotSpeWord:"名字不能有特殊字符！";
			case RequestType.NotRepassword:"两次输入的密码不一致！";
			case RequestType.EmptyMember:"空白会员！";
			case RequestType.LoginToRegister:"已经登陆！";
			case RequestType.FaiUserlen:"用户名长度不够！";
			case RequestType.FailPasslen:"密码名长度不够！";
			case RequestType.EmptyLogin:"请输入用户名与密码！";
			default:"";
		}
		return msg;
	}
	
	public static function getGameMsg(type:GameMsgType):String
	{
		switch(type) {
			case SkillFreeze: 		return "能量不足!冷却中!";
			default:return "";
		}
	}
}