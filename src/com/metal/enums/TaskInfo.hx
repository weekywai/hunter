package com.metal.enums;
import com.metal.enums.TaskInfoVo;
import com.metal.proto.impl.QuestInfo;
import haxe.ds.IntMap;

/**
 * ...
 * @author hyg
 */
class TaskInfo
{
	public var taskAllNum:Int;
	public var taskArr:Array<Dynamic> = new Array();
	public var taskMap:IntMap<QuestInfo>;
	public var taskArrbtn:Array<Bool>;
	public var taskArrbtn2:Array<Bool>;

	public function new() 
	{
		
	}
	public function removeData():Void
	{
		taskAllNum = 0;
		taskArr = [];
		taskMap = new IntMap();
	}
}