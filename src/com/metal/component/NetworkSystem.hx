package com.metal.component;

import com.metal.network.Network;
import com.metal.network.packet.*;
import com.metal.network.ZNetPacketCreator;
import de.polygonal.core.sys.Component;

/**
 * ...
 * @author weeky
 */
class NetworkSystem extends Component
{
	private var _netWork:Network;
	
	public function new() 
	{
		super();
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		init();
	}
	
	private function init()
	{
		//注册网络回调和初始化网络
		ZNetPacketCreator.instance.RegisterPacketClass(Client_LoginAccount);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_GetPlayerList);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_GetPlayerInfo);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_CreateAccount);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_HintText);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_GetProperty);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_SYNPartner);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_SYNResources);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_GetDuplicateList);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_EnterDuplicate);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_GetDuplicateReward);
		ZNetPacketCreator.instance.RegisterPacketClass(Client_GetBagInfo);//背包数据请求+返回
		ZNetPacketCreator.instance.RegisterPacketClass(Client_AddItemFromServer);//添加新物品
		ZNetPacketCreator.instance.RegisterPacketClass(Client_TaskList);//任务列表
		ZNetPacketCreator.instance.RegisterPacketClass(Client_CompleteTask);//完成任务领取奖励+返回
		ZNetPacketCreator.instance.RegisterPacketClass(Client_ACCEPTnews);//接受任务
		ZNetPacketCreator.instance.RegisterPacketClass(Client_UpdateTask);//更新任务
		ZNetPacketCreator.instance.RegisterPacketClass(Client_EquipItem);//更新装备
		ZNetPacketCreator.instance.RegisterPacketClass(Clieant_DeleteItem);//移除道具
		ZNetPacketCreator.instance.RegisterPacketClass(Client_GetBufferList);//获取buff列表
		ZNetPacketCreator.instance.RegisterPacketClass(Client_BuyBuff);//购买buff
		ZNetPacketCreator.instance.RegisterPacketClass(Client_StrengthenEquip);//更新强化
		ZNetPacketCreator.instance.RegisterPacketClass(Client_LevelupEquip);//更新进阶
		ZNetPacketCreator.instance.RegisterPacketClass(Client_OpenStage);//开启副本
		ZNetPacketCreator.instance.RegisterPacketClass(Client_BuyGold);//购买金币返回
		ZNetPacketCreator.instance.RegisterPacketClass(Client_BuyChest);//购买宝箱返回
		ZNetPacketCreator.instance.RegisterPacketClass(Client_GetRevived);//购买复活
	}
}