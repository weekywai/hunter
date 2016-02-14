package com.metal.network;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import signals.Signal1;

/**
 * ...
 * @author li
 */
class STCallBack
{
	private static var _instance:STCallBack;
	public static var instance(get, null):STCallBack;
	private static function get_instance():STCallBack {
		if (_instance == null) {
			_instance = new STCallBack();
		}
		return _instance;
	}
	
	public var calFunc:Signal1<ZNetPacket>;
	
	public function new() 
	{
		calFunc = new Signal1();
		calFunc.add(handleSTCallback);
	}
	
	private function handleSTCallback(packet:ZNetPacket):Void
	{
		switch(packet.protocol) {
			case NetProtocol.ST_TEXT:
			case NetProtocol.ST_HINT_TEXT:  //服务器主动下发的公告栏消息
				
				GameProcess.root.notify(MsgUI.HintPanel, packet);
			case NetProtocol.ST_ENTER_SCENE: //进入游戏获取角色信息
				GameProcess.root.notify(MsgNet.AssignAccount, packet);
			case NetProtocol.ST_PARTNER_VAL: //角色或伙伴属性有更新
				GameProcess.root.notify(MsgNet.UpdateInfo, packet);
			case NetProtocol.ST_SET_VAL: //角色资源有更新
				GameProcess.root.notify(MsgNet.UpdateResources, packet);
			case NetProtocol.ST_QUEST_COMPLETE: //任务有更新
				//GameProcess.root.notify(MsgNet.UpdateTask, packet);
			case NetProtocol.ST_QUEST_LIST: //刷新任务列表
				GameProcess.root.notify(MsgNet.QuestList, packet);
			case NetProtocol.PT_STRENGTHEN: //更新强化
				//GameProcess.root.notify(MsgNet.Intensify, packet);
			case NetProtocol.PT_LEVELUP_EQUIP: //更新进阶
				//GameProcess.root.notify(MsgNet.Advance, packet);
			case NetProtocol.ST_OPEN_STAGE: //更新开启副本
				GameProcess.root.notify(MsgNet.OpenStage, packet);
			case NetProtocol.PT_BUY_GOLD: //购买金币返回
				GameProcess.root.notify(MsgNet.BuyGold, packet);
			default:
		}	
	}
	
}