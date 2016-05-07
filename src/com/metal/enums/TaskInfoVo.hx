package com.metal.enums;
import haxe.xml.Fast;

/**
 * ...任务基础信息
 * @author hyg
 */
class TaskInfoVo
{
	/**_quest_id（uint）任务ID*/
	public var taskId:UInt;//_quest_id（uint）任务ID
	/**任务名称*/
	public var Name:String;
	
	/**_num（ubyte）任务数据总数*/
	public var taskNum:Int;
	/**_data（uint）任务数据，以任务数据总数循环读取*/
	public var dataArr:Array<UInt>;
	/**任务描述*/
	public var Desc:String;
	
	
	public function new() 
	{
	}
}