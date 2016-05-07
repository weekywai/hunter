package com.metal.proto.impl;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 进阶信息
 * @author ...
 */
class AdvanceInfo
{
	/**目标物品ID*/
	public var ID:Int;
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
	public function readXml(data:Dynamic):Void
	{
		ID = data.DstID;
		DstName = data.DstName;
		Mat = data.Mat;
		NeedGold = data.NeedGold;
		NeedDiamond = data.NeedDiamond;
	}
	public function initDefaultValues():Void
	{
		ID = 0;
		DstName = "";
		Mat = "";
		NeedGold = 0;
		NeedDiamond = 0;
	}
}