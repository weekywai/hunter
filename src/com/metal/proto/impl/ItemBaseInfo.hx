package com.metal.proto.impl ;
import com.metal.config.ItemType;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 物品信息基础类
 * @author hyg
 */
class ItemBaseInfo
{
	public var itemType:Int;//save_type（ubyte）物品类型（大类）
	/**物品小类*/
	public var Kind:Int;
	public var itemId:Int;//item_id_（int）物品id
	public var itemName:String;//物品名
	public var itemIndex:Int;//index_（ubyte）物品索引
	public var itemNum:UInt;//item_num_（uint）物品数量
	public var itemState:Int;//item_bind_（ubyte）物品绑定状态
	public var PickUp:Int;//是否被拾取
	/**进阶最大值*/
	public var InitialQuality:Int;
	/**初始等级*/
	public var InitialLevel:Int;
	/**图表资源名称*/
	public var ResId:String;
	/**描述*/
	public var Description:String;
	/**描述*/
	public var Detail:String;
	//特性
	public var Characteristic:String;
	
	public var SubId:Int;//取武器技能与强化等级的字段
	/**包含经验*/
	public var StrengthenExp:Int;
	/**背包类型**/
	public var bagType:Int = -1;
	/**场景显示ID*/
	public var SwfId:String;
	
	/**排序*/
	public var sortInt:Int = 0;
	
	/**单个弹夹的子弹数*/
	public var OneClip:Int;
	
	/**起始的备用子弹数*/
	public var StartClip:Int;
	
	/**弹夹价格*/
	public var ClipCost:Int;
	
	/**后备子弹总数*/
	public var MaxBackupBullet:Int;
	
	/**当前子弹数*/
	public var currentBullet:Int;
	/**当前后备子弹*/
	public var currentBackupBullet:Int;
	/**首次获得*/
	public var firstGet:Bool;
	/**主键*/
	public var keyId:Int;
	/**处于备用枪背包的第几个位置*/
	public var backupIndex:Int = -1;
	
	/**暴击率*/
	public var CritPor:Int;
	
	/**属性*/
	public var Property:Int;
	
	/**进阶后的物品ID*/
	public var LevelUpItemID:Int;
	
	public function new() 
	{
		firstGet = true;
	}
	public function readXml(data:Fast):Void
	{
		itemId = XmlUtils.GetInt(data, "ID");
		itemType = XmlUtils.GetInt(data, "ItemKind1");
		Kind = XmlUtils.GetInt(data, "ItemKind2");
		Detail = XmlUtils.GetString(data, "detail");
		itemName = XmlUtils.GetString(data, "Name");
		Description = XmlUtils.GetString(data, "Description");
		InitialQuality = XmlUtils.GetInt(data, "Color");
		ResId = XmlUtils.GetString(data, "ResId");
		SubId = XmlUtils.GetInt(data, "SubId");
		StrengthenExp = XmlUtils.GetInt(data, "StrengthenExp");
		InitialLevel = XmlUtils.GetInt(data, "InitialLevel");
		Characteristic = XmlUtils.GetString(data, "Characteristic");
		SwfId = XmlUtils.GetString(data, "SwfId");
		
		LevelUpItemID = XmlUtils.GetInt(data, "LevelUpItemID");
		CritPor = XmlUtils.GetInt(data, "CritPor");
		Property = XmlUtils.GetInt(data, "Property");
		//OneClip = XmlUtils.GetInt(data, "OneClip");
		//StartClip = XmlUtils.GetInt(data, "StartClip");
		//ClipCost = XmlUtils.GetInt(data, "ClipCost");
		//MaxBackupBullet = XmlUtils.GetInt(data, "MaxBackupBullet");		
	}
	public function setStartBullet():Void
	{
		if (Kind==ItemType.IK2_GON && firstGet) 
		{
			//trace("setStartBullet");
			currentBullet = OneClip;
			currentBackupBullet = StartClip;
			firstGet = false;
		}		
	}
}