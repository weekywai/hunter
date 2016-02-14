package com.metal.network;
import haxe.ds.IntMap;

/**
 * ...
 * @author li
 */
class NetProtocol
{
	//大包
	public static var PT_BIG_PACKET					:UInt = 0x1021;  //服务器返回的大包协议，特殊处理
	
	//发给服务器并且有回调
	public static var PT_CREATE_ACCOUNT				:UInt = 0x1004;  //客户端发给服务器创建账号的消息
	public static var PT_CREATE_PLAYER				:UInt = 0x1002;  //客户端发给服务器创建角色的消息
	public static var PT_GET_ACCOUNT				:UInt = 0x1003;  //客户端发给服务器登陆游戏的消息
	public static var PT_GET_PLAYERLIST				:UInt = 0x1008;  //客户端发给服务器获取角色列表的消息
	public static var PT_GET_ITEM_BAG				:UInt = 0x1061;  //客户端发送此消息请求背包信息
	public static var PT_COMPLETE_QUEST				:UInt = 0x10AB;  //客户端发送到服务器完成一个任务的消息
	public static var PT_STAGE_LIST					:UInt = 0x2602;  //客户端请求获取副本列表
	public static var PT_ENTER_STAGE				:UInt = 0x2601;	 //客户端请求进入一个副本
	public static var PT_BUY_POWER            		:UInt = 0x2830;  //客户端请求购买体力
	public static var PT_STAGE_PASS_REWARD			:UInt = 0x2605;	 //客户端发送到服务器领取通关奖励的消息
	public static var PT_STAGE_CLEAR_CD				:UInt = 0x2634;	 //客户端发给服务器购买复活的消息
	public static var PT_DELETE_ITEM				:UInt = 0x0200;  //客户端发给服务器删除道具
	public static var PT_EQUIP_ITEM               	:UInt = 0x1067;  //客户端发给服务器装备物品
	public static var PT_GET_FIGHT_BUFF_LIST		:UInt = 0x2606;	 //客户端发给服务器获取buff列表
	public static var PT_BUY_FIGHT_BUFF				:UInt = 0x2607;	 //客户端发给服务器购买buff
	public static var PT_STRENGTHEN               	:UInt = 0x1501;  //客户端发给服务器强化物品
	public static var PT_LEVELUP_EQUIP              :UInt = 0x1520;  //客户端发给服务器进阶装备物品
	public static var ST_OPEN_STAGE                 :UInt = 0x2608;  //客户端发给服务器开启副本
	public static var PT_BUY_GOLD                   :UInt = 0x1235;  //客户端发给服务器购买金币
	public static var PT_BUY_CHEST                  :UInt = 0x1521;  //客户端发给服务器购买宝箱
	
	//发给服务器但没有回调
	public static var PT_JOIN_GAME					:UInt = 0x1009;  //客户端发给服务器进入游戏的消息
	
	//服务器主动下发的协议
	public static var ST_ENTER_SCENE				:UInt = 0x1046;  //服务器发送给客户端进入场景的消息
	public static var ST_HINT_TEXT					:UInt = 0x100B;  //登陆前的提示消息(错误信息)
	public static var ST_TEXT  						:UInt = 0x1031;  //进入场景后的提示消息(错误信息)
	public static var ST_CREATE_ITEM				:UInt = 0x1074;  //该消息是服务器主动同步到客户端的，用于新的物品生成
	public static var ST_ALL_PARTNER_NVAL			:UInt = 0x2352;  //服务器发给客户端所有伙伴的属性数据
	public static var ST_PARTNER_VAL				:UInt = 0x2353;  //服务器同步伙伴属性到客户端的消息
	public static var ST_SET_VAL  					:UInt = 0x1081;  //服务器同步角色资源数据的消息
	public static var ST_QUEST_LIST				    :UInt = 0x10A1;  //游戏上线时服务端推送到客户端任务数据的协议
	public static var ST_QUEST_COMPLETE				:UInt = 0x10AD;  //当一个任务状态改变至完成时，服务器发送给客户端的消息
	public static var ST_ACCEPT_QUEST				:UInt = 0x10A7;  //服务器发送给客户端接受任务的消息
	public static var ST_QUEST_REFRESH				:UInt = 0x10A8;  //服务器主动同步到客户端的，当任务的数据有更新时发送
	
	//GM命令
	public static var GM_CMD_CREAT_GOOD             :UInt = 0x1018;// --GM命令消息号类型string 指令内容 createtestitem 创建测试物品
	
	private static function InitMessage():IntMap<String> {
		var ary:IntMap<String> = new IntMap();
		ary.set(PT_CREATE_ACCOUNT, "客户端发给服务器创建账号的消息");
		ary.set(PT_CREATE_PLAYER, "客户端发给服务器创建角色的消息");
		ary.set(PT_GET_ACCOUNT, "客户端发给服务器登陆游戏的消息");
		ary.set(PT_GET_PLAYERLIST, "客户端发给服务器获取角色列表的消息");
		ary.set(PT_JOIN_GAME, "客户端发给服务器进入游戏的消息");
		ary.set(PT_GET_ITEM_BAG, "客户端发送此消息请求背包信息");
		ary.set(ST_HINT_TEXT, "登陆前的提示消息(错误信息)");
		ary.set(ST_TEXT, "进入场景后的提示消息(错误信息)");
		ary.set(ST_ALL_PARTNER_NVAL, "服务器发给客户端所有伙伴的属性数据");
		ary.set(ST_PARTNER_VAL, "服务器同步伙伴属性到客户端的消息");
		ary.set(ST_SET_VAL, "服务器同步角色资源数据的消息");
		
		return ary;
	}
	
	private static var _msgs:IntMap<String> = InitMessage();

	public static function GetMessage(code:UInt):String {
		return _msgs.get(code);
	}
	
	public function new() 
	{
		
	}
	
}