package com.metal.proto.impl;
import com.metal.proto.impl.MonsterInfo.DropItemInfo;
import com.utils.StringUtils;
import com.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * ...
 * @author 3D
 */
class PlayerModelInfo
{

	/**id*/
	public var Id:Int;
	/**角色名字*/
	public var Name:String;
	/**角色资料*/
	public var JobEffectDesc:String;
	
	public var HP:Int;
	public var Att:Int;
	public var MP:Int;
	public var model:Int;
	/**技能id**/
	public var SkillId:Int;
	public var dropItem:Array<DropItemInfo>;
	
	public function new() 
	{
		
	}
	public function readXml(data:Dynamic):Void
	{
		Id = data.Id;
		Name = data.Name;
		JobEffectDesc = data.JobEffectDesc;
		HP = data.HP;
		Att = data.Att;
		MP = data.MP;
		model = data.model;
		SkillId = data.SkillId;
		dropItem = ParseDropItem(data.DropItem1);
	}
	private function ParseDropItem(value:String):Array<DropItemInfo>
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
			p.Precent = StringUtils.GetFloat(i[1]) / 100;
			p.Num = StringUtils.GetInt(i[2]);
			itemMap.push(p);
		}
	
		return itemMap;
	}
}