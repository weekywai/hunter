package com.metal.player.api;
/**
 * 角色消息
 * @author weeky
 */
class MsgPlayer 
{
	/**
	 * 传入外部挂接的账号信息
	 * 数据格式 : 按具体情况而定，目前是IFLinkPlayer
	 */
	public static inline var AssignAccountInfo:String = "MsgPlayer_AssignAccountInfo";
	
	/**背包信息**/
	public static inline var BagInfo:String = "MsgPlayer_BagInfo";
	
	
	/**
	 * 绑定单元
	 * 数据格式 : 机体ISimEntity
	 */
	public static inline var BindUnit:String = "MsgPlayer_BindUnit";
	
	public static inline var AddStatKill:String = "MsgPlayer_AddStatKill";
	
	public static inline var AddStatDie:String = "MsgPlayer_AddStatDie";
	
	public static inline var AddStatScore:String = "MsgPlayer_AddStatScore";
	
	public static inline var AddStatDamage:String = "MsgPlayer_AddStatDamage";
	public static inline var AddStatHp:String = "MsgPlayer_AddStatHp";
	
	/**
	 * 设置玩家为离开
	 */
	public static inline var SetPlayerLeave:String = "MsgPlayer_SetPlayerLeave";
}