package com.metal.proto.impl;
import com.metal.enums.TaskInfoVo;
import com.metal.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 任务
 * @author 
 */
class QuestInfo extends TaskInfoVo
{
	/**任务Id*/
	public var SN:Int;
	/**任务名称*/
	public var name:String;
	/**任务描述 */
	public var desc:String;
	/**奖励钱币*/
	public var rewardSilver:Int;
	/**奖励钻石*/
	public var rewardGem:Int;
	/**奖励经验*/
	public var rewardExp:Int;
	/**奖励物品*/
	public var rewardItem:Array<Array<String>>;
	/**任务类型*/
	public var type:Int;
	/**前置任务*/
	public var RepeatType:Int;
	/**执行方式*/
	public var RunType:Int;
	/*条件*/
	public var Count:Int;
	/**_state（ubyte）任务状态   0未完成  1完成未领取 2已领取*/
	public var state:Int;
	
	/**完成度*/
	public var Finish:Int = 0;
	
	public var taskArr:Array<TaskInfoVo>;
	
	public function new() 
	{
		super();
	}
	public function readXml(data:Fast):Void
	{
		
		//taskId = XmlUtils.GetInt(data, "SN");
		SN = XmlUtils.GetInt(data, "SN");
		taskName = XmlUtils.GetString(data, "Name");
		taskDesc = XmlUtils.GetString(data, "Desc");
		rewardSilver = XmlUtils.GetInt(data, "RewardSilver");
		rewardGem = XmlUtils.GetInt(data, "RewardGold");
		type = XmlUtils.GetInt(data, "Type");
		RunType = XmlUtils.GetInt(data, "RunType");
		RepeatType = XmlUtils.GetInt(data, "RepeatType");
		state = 0;
		rewardItem = ParseDropItem(XmlUtils.GetString(data, "CRewardItem"));
	}
	
	private function ParseDropItem(value:String):Array<Array<String>>
	{
		var itemArray:Array<String> = new Array();
		var itemMap:Array<Array<String>> = new Array();
		itemArray = value.split("|");
		for ( item in itemArray )
		{
			var i:Array<String> = new Array();
			i = item.split("-");
			itemMap.push(i);
		}
		return itemMap;
	}
	
	public function resetValues():Void
	{
		SN = 0;
		name = "";
		desc = "";
		rewardExp = 0;
		rewardSilver = 0;
		state = 0;
		rewardItem = null;
	}
	
}