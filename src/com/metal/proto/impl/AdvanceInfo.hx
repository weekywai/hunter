package com.metal.proto.impl;
import com.metal.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 进阶信息
 * @author ...
 */
class AdvanceInfo
{
	/**目标物品ID*/
	public var DstID:Int;
	/**目标物品名称*/
	public var DstName:String;
	/**所需材料*/
	public var Mat:String;
	/**花费金币*/
	public var NeedGold:Int;
	/**花费钻石*/
	public var NeedDiamond:Int;
	public function new() 
	{
		
	}
	public function readXml(data:Fast):Void
	{
		DstID = XmlUtils.GetInt(data, "DstID");
		DstName = XmlUtils.GetString(data, "DstName");
		Mat = XmlUtils.GetString(data, "Mat");
		NeedGold = XmlUtils.GetInt(data, "NeedGold");
		NeedDiamond = XmlUtils.GetInt(data, "NeedDiamond");
	}
	public function initDefaultValues():Void
	{
		DstID = 0;
		DstName = "";
		Mat = "";
		NeedGold = 0;
		NeedDiamond = 0;
	}
}