package com.metal.proto.impl;
import com.metal.proto.manager.ModelManager;
import com.utils.StringUtils;
import com.utils.XmlUtils;
import openfl.geom.Point;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author li
 */
class MonsterInfo
{
	//怪物ID
	public var ID:Int;
	
	//行为类型 1:站桩类 2:巡逻类
	public var BehaviorType:Int;
	
	//是否种植怪 0:按事件走出来的怪 1:种植在场景内的怪
	public var FixedType:Int;
	
	//怪物名称
	public var Name:String;
	
	//等级
	public var Lv:Int;
	
	//入场点坐标 屏幕X,Y百分比
	public var EnAt:Point;
	
	//出场坐标 屏幕X,Y百分比
	public var BornAt:Point;
	
	//离场坐标 屏幕X,Y百分比
	public var Leave:Point;
	
	//巡逻路径
	public var PatrolPath:PatrolPathInfo;
	
	//最大血量
	public var MaxHp:Int;
	
	//攻击
	public var Atk:Int;
	
	//防御
	public var Def:Int;
	
	//暴击率
	public var CritPor:Float;
	
	//ai类型
	public var AiType:Int;
	
	//模型类型
	public var ModelType:Int;
	/**默认技能*/
	public var SkillId:Int;
	//技能槽
	//public var Skill:Array<SkillSlotInfo>;
	public var Skill:Array<Int>;
	
	//召唤槽
	public var Summon:Array<SummonInfo>;
	
	//警戒半径 屏幕X,Y百分比
	public var AlertRadius:Float;
	
	//攻击半径 屏幕X,Y百分比
	public var AttackRadius:Float;
	
	//追击半径 屏幕X,Y百分比
	public var ChaseRadius:Float;
	
	//出场时间上限
	public var ResidenceTime:Int;
	
	//攻击次数上限
	public var AtkNum:Int;
	
	//攻击间隔
	public var PublicCD:Float;
	
	//锁定优先级
	public var Lock:Int;
	
	//模型资源
	public var res:Int;
	
	public var dropItem:Array<DropItemInfo>;
	
	/**爆炸类型*/
	public var boomType:Int;
	
	/**是否爆炸*/
	public var isBoom:Bool;
	
	/**怪物分数类型*/
	public var ScoreType:Int;
	/**属性*/
	public var Property:Int;
	
	public function new() 
	{
		PatrolPath = new PatrolPathInfo();
		Skill = new Array();
		Summon = new Array();
		dropItem = new Array();
	}
	
	public function readXml(data:Dynamic):Void
	{
		ID = data.ID;
		BehaviorType = data.BehaviorType;
		FixedType = data.FixedType;
		Name = data.Name;
		//Lv = data.Lv;
		if (FixedType == 0)
		{
			EnAt = ParseBornAt(data.EnAt);
			BornAt = ParseBornAt(data.BornAt);
			Leave = BornAt;
		}
		if (BehaviorType == 2)
		{
			PatrolPath = ParsePatrolPath(data.PatrolPath);
		}
		//MaxHp = data.MaxHp;
		//Atk = data.Atk;
		//Def = data.Def;
		CritPor = data.CritPor;
		AiType = data.AiType;
		ModelType = data.ModelType;
		SkillId = data.SkillId;
		//Skill = ParseSkillSlots(data.SkillSlots);
		Skill.push(data.SkillId);
		Skill.push(data.SkillId2);
		Skill.push(data.SkillId3);
		Skill.push(data.SkillId4);
		Skill.push(data.SkillId5);
		Skill.push(data.SkillId6);
		Skill.push(data.SkillId7);
		//Summon = ParseSummon(data.Summon);
		AlertRadius = data.AlertRadii / 10000;
		AttackRadius = data.AtkRadii / 10000;
		ChaseRadius = data.ChaseRadii / 10000;
		ResidenceTime = data.ResidenceTime;
		AtkNum = data.AtkNum;
		PublicCD = data.PublicCd;
		Lock = data.Lock;
		dropItem = DropItemInfo.ParseDropItem(data.DropItem1);
		res = data.ModelPic;
		boomType = data.IsExplosion;
		isBoom = boomType != 0;
		ScoreType = data.ScoreType;
		Property = data.Property;
	}
	
	private function ParseBornAt(value:String):Point
	{
		var a:Array<String> = new Array();
		var p:Point = new Point();
		a = value.split(",");
		p.x = StringUtils.GetFloat(a[0]) / 100;
		p.y = StringUtils.GetFloat(a[1]) / 100;
	
		return p;
	}
	
	private function ParsePatrolPath(value:String):PatrolPathInfo
	{
		var a:Array<String> = new Array();
		a = value.split(",");
		var p:PatrolPathInfo = new PatrolPathInfo();
		p.PartolType = StringUtils.GetInt(a[0]);
		p.PartolRadius = StringUtils.GetFloat(a[1]) / 1000;
	
		return p;
	}
	
	private function ParseSkillSlots(value:String):Array<SkillSlotInfo>
	{
		var itemArray:Array<String> = new Array();
		var itemMap:Array<SkillSlotInfo> = new Array();
		itemArray = value.split("|");
		for ( item in itemArray )
		{
			var i:Array<String> = new Array();
			i = item.split("-");
			var p:SkillSlotInfo = new SkillSlotInfo();
			p.SkillType = StringUtils.GetInt(i[0]);
			p.SkillPrecent = StringUtils.GetInt(i[1]) / 10000;
			itemMap.push(p);
		}
	
		return itemMap;
	}
	
	private function ParseSummon(value:String):Array<SummonInfo>
	{
		var itemArray:Array<String> = new Array();
		var itemMap:Array<SummonInfo> = new Array();
		itemArray = value.split("|");
		for ( item in itemArray )
		{
			var i:Array<String> = new Array();
			i = item.split("-");
			var p:SummonInfo = new SummonInfo();
			p.SummonType = StringUtils.GetInt(i[0]);
			p.SummonPrecent = StringUtils.GetInt(i[1]) / 10000;
			itemMap.push(p);
		}
	
		return itemMap;
	}
	
	
}

class DropItemInfo
{
	//掉落物品id
	public var ItemId:Int;
	//掉落概率
	public var Precent:Float;
	//掉落数量
	public var Num:Int;
	
	public function new()
	{
		
	}
	public static function ParseDropItem(data:Dynamic):Array<DropItemInfo>
	{
		var value:String = Std.string(data);
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
			p.Precent = StringUtils.GetFloat(i[1]);
			p.Num = StringUtils.GetInt(i[2]);
			itemMap.push(p);
		}
	
		return itemMap;
	}
}

class PatrolPathInfo
{
	//巡逻路径类型
	public var PartolType:Int;
	
	//巡逻半径 屏幕X百分比
	public var PartolRadius:Float;
	
	public function new()
	{
		
	}
}

class SkillSlotInfo
{
	//技能类型
	public var SkillType:Int;
	
	//技能概率
	public var SkillPrecent:Float;
	
	public function new()
	{
		
	}
}

class SummonInfo
{
	//召唤类型
	public var SummonType:Int;
	
	//召唤概率
	public var SummonPrecent:Float;
	
	public function new()
	{
		
	}
}