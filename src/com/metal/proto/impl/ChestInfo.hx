package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 宝箱信息
 * @author hyg
 */
class ChestInfo
{
	/**宝箱类型*/
	public var Level:Int = 0;
	public var ItemListGroup:String;
	/**购买宝箱需要钻石*/
	public var NeedDiamond:Int;
	/**获取物品的最大数量*/
	public var MaxItemNum:Int;
	/**活动奖励内容*/
	public var Activity:String;
	public function new() 
	{
		
	}
	public function readXml(data:Dynamic):Void
	{
		Level = data.Level;
		NeedDiamond = data.NeedDiamond;
		ItemListGroup = data.ItemListGroup;
		MaxItemNum = data.MaxItemNum;
		Activity = data.Activity;
	}
	public function initDefaultValues():Void
	{
		//Level = 0;
		//NeedDiamond = 0;
		//MaxItemNum = 0;
		//Activity = "";
	}
	
}