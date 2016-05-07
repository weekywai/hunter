package com.metal.proto.impl;
import com.metal.proto.impl.MonsterInfo.DropItemInfo;
import com.utils.StringUtils;
import com.utils.XmlUtils;
import openfl.geom.Point;

/**
 * ...
 * @author ...
 */
class DuplicateInfo
{
	//副本ID
	public var Id:Int;

	//房间ID
	public var RoomId:Array<String>;
	
	//副本名称
	public var DuplicateName:String;
	/**关卡名*/
	public var StageName:String;
	
	//副本描述
	public var Description:String;
	//副本类型
	public var DuplicateType:Int;
	
	//角色最低等级
	public var NeedLv:Int;
	
	//前置副本ID
	public var PreDuplicateId:Int;
	
	//消耗体力
	public var NeedPower:Int;
	
	//消耗金币
	public var NeedGold:Int;
	
	//每天可刷次数
	public var AllowTimes:Int;
	
	//通关类型
	public var StagePassType:Int;
	
	//通关怪物ID列表
	public var MonsterList:Array<Int>;
	
	//掉落物品1
	public var DropItem1:Array<Array<String>>;
	//掉落物品2
	public var DropItem2:Array<Array<String>>;
	//掉落物品3
	public var DropItem3:Array<Array<String>>;

	//图标
	public var Icon:String;
	
	//复活类型
	public var ReviveType:Int;
	
	//VIP等级
	public var VIPLv:Int;
	
	//可获取的道具最大数量
	public var CanGetItemNum:Int;
	//可掉落的宝箱
	public var DropChestMax:Int;
	
	//消耗道具ID
	public var NeedItem:Int;
	
	//副本战力
	public var StagePower:Int;
	
	//坐标
	public var Coordinate:Point;
	
	//区域标识
	public var AreaType:Int;
	
	//boss名称
	public var BossName:String;
	
	//boss特点
	public var BossFeatures:String;
	
	//boss等级
	public var BossLv:Int;
	/**开启所需的道具*/
	public var Condition2:String;
	
	//特殊处理，BOSS副本打Boss的次数---暂时处理
	public var BossNum:Int = 0;
	
	public var DropItem:Array<DropItemInfo>;
	/**buff掉落几率*/
	public var BuffRate:Float;
	
	/**通关星级判断条件*/
	public var GradeCondition:Array<String>;
	/**计时*/
	public var TimeLimit:Int;
	
	/**此次战斗星级*/
	public var rate:Int;
	
	public function new() 
	{
		
	}
	
	public function readXml(data:Dynamic):Void
	{
		Id = data.ID;
		RoomId = ParseRoomId(data.RoomID);
		DuplicateName = data.Name;
		StageName = data.Stage;
		Description = data.Desc;
		DuplicateType = data.Type;
		//NeedLv = data.NeedLevel;
		NeedPower = data.NeedPower;
		//NeedGold = data.NeedGold;
		AllowTimes = data.Times;
		StagePassType = data.StagePassType;
		//MonsterList = data.MonsterList;
		//Icon = data.Icon;
		//ReviveType = data.ReliveType;
		//VIPLv = data.NeedVip;
		CanGetItemNum = data.CanGetItemNum;
		DropChestMax = data.DropChestMax;
		PreDuplicateId = data.PreID;
		//NeedItem = data.NeedItem;
		//StagePower = data.StagePower;
		//Coordinate = ParseCoordinate(data.Coordinate);
		//AreaType = data.AreaType;
		BossName = data.BossName;
		//BossLv = data.BossLv;
		BossFeatures = data.BossFeature;
		DropItem1 = ParseItem(data.DropItem1);
		DropItem2 = ParseItem(data.DropItem2);
		DropItem3 = ParseItem(data.DropItem3);
		DropItem = ParseDropItem(data.DropItem);
		BuffRate = data.Buff;
		//Condition2 = data.Condition2;
		GradeCondition = ParseGradeCondition(data.GradeCondition);
		TimeLimit=data.TimeLimit;
	}
	
	private function ParseRoomId(value:String):Array<String>
	{
		var room:Array<String> = new Array();
		room = value.split("|");
		return room;
	}
	private function ParseGradeCondition(value:String):Array<String>
	{
		var Condition:Array<String> = new Array();
		Condition = value.split("|");
		return Condition;
	}
	
	private function ParseCoordinate(value:String):Point
	{
		var pos:Array<String> = new Array();
		pos = value.split("-");
		var point:Point = new Point(StringUtils.GetFloat(pos[0]), StringUtils.GetFloat(pos[1]));
		return point;
	}
	
	private function ParseItem(value:Dynamic):Array<Array<String>>
	{
		var itemArray:Array<String> = new Array();
		var itemMap:Array<Array<String>> = new Array();
		itemArray = Std.string(value).split("|");
		for ( item in itemArray )
		{
			var i:Array<String> = new Array();
			i = item.split(",");
			itemMap.push(i);
		}
		return itemMap;
	}
	public function ParseDropItem(value:String):Array<DropItemInfo>
	{
		var itemMap:Array<DropItemInfo> = new Array();
		if (value == "")
			return itemMap;
		var itemArray:Array<String> = new Array();
		itemArray = value.split("|");
		for ( item in itemArray )
		{
			var i:Array<String> = new Array();
			i = item.split("-");
			var p:DropItemInfo = new DropItemInfo();
			p.ItemId = StringUtils.GetInt(i[0]);
			p.Precent = 1;
			p.Num = StringUtils.GetInt(i[1]);
			itemMap.push(p);
		}
	
		return itemMap;
	}
	
	public function GetRoom():Array<String>
	{
		return RoomId;
	}
	/**此次战斗星级*/
	public function setRate(value:Int)
	{
		rate = value;
	}
}