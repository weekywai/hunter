package com.metal.proto.impl ;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class WeaponInfo extends EquipItemBaseInfo
{
	
	
	/**最大重叠数*/
	public var PackMax:Int;
	/**穿戴等级*/
	public var NeedLevel:Int;
	
	/**最高强化等级*/
	public var MaxStrengthenLevel:Int;
	/**影响属性*/
	public var DestParam1:Dynamic;
	/**附加技能ID*/
	public var SkillsID:Int;
	/**外观资源名称*/
	//public var SwfId:String;
	
	//攻击
	public var Att:Int;
	
	/**强化等级**/
	public var strLv:Int=0;
	
	public var SellDiamond:Int;
	/**进阶值 +1 +2 +3*/
	public var Upgrade:Int = 0;
	
	public function new() 
	{
		super();
	}
	
	override public function readXml(data:Fast):Void
	{
		itemId = XmlUtils.GetInt(data, "ID");
		//itemNum = XmlUtils.GetInt(data, "NumID");
		itemType = XmlUtils.GetInt(data, "ItemKind1");
		Kind = XmlUtils.GetInt(data, "ItemKind2");
		itemName = XmlUtils.GetString(data, "Name");
		Description = XmlUtils.GetString(data, "Description");
		Detail = XmlUtils.GetString(data, "detail");
		PackMax = XmlUtils.GetInt(data, "PackMax");
		NeedLevel = XmlUtils.GetInt(data, "NeedLevel");
		InitialLevel = XmlUtils.GetInt(data, "InitialLevel");
		InitialQuality = XmlUtils.GetInt(data, "Color");
		MaxStrengthenLevel = XmlUtils.GetInt(data, "MaxStrengthenLevel");
		//DestParam1 = XmlUtils.GetString(data, "DestParam1");
		SkillsID = XmlUtils.GetInt(data, "SkillsID");
		ResId = XmlUtils.GetString(data, "ResId");
		//SwfId = XmlUtils.GetString(data, "SwfId");
		SubId = XmlUtils.GetInt(data, "SubId");
		equipType = XmlUtils.GetInt(data, "Type");
		StrengthenExp = XmlUtils.GetInt(data, "StrengthenExp");
		LevelUpItemID = XmlUtils.GetInt(data, "LevelUpItemID");
		Characteristic = XmlUtils.GetString(data, "Characteristic");
		SellDiamond = XmlUtils.GetInt(data, "SellDiamond");
		Att = XmlUtils.GetInt(data, "Att");
		
		OneClip = XmlUtils.GetInt(data, "OneClip");
		StartClip = XmlUtils.GetInt(data, "StartClip");
		ClipCost = XmlUtils.GetInt(data, "ClipCost");
		MaxBackupBullet = XmlUtils.GetInt(data, "MaxBackupBullet");
		CritPor = XmlUtils.GetInt(data, "CritPor");
		Property = XmlUtils.GetInt(data, "Property");
	}
	
	public function initDefaultValues():Void {
		itemId = 0;
		itemNum = 0;
		itemType = 0;
		Kind = 0;
		itemName = "";
		Description = "";
		Detail = "";
		PackMax = 0;
		NeedLevel = 0;
		InitialLevel = 0;
		InitialQuality = 0;
		MaxStrengthenLevel = 0;
		//DestParam1 = propItem.node.DestParam1.innerData;
		SkillsID = 0;
		ResId = "";
		SwfId = "";
		SubId = 0;
		Att = 0;
		
	}
}