package com.metal.proto.manager;
import com.metal.enums.TaskInfoVo;
import com.metal.proto.impl.QuestInfo;
import com.metal.enums.TaskInfo;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.xml.Fast;

/**
 * 任务信息
 * @author hyg
 */
class TaskManager
{

	public static var instance(default, null):TaskManager = new TaskManager();
	private var _protpTask:IntMap<QuestInfo>;
	var arr:Array<Dynamic>;
	
	public var taskId:Int;
	public var taskType:Int;//任务奖励类型
	
	public var Task(get, null):IntMap<QuestInfo>;
	private function get_Task():IntMap<QuestInfo>
	{
		return _protpTask;
	}
	
	public function new() 
	{
		_protpTask = new IntMap();
	}
	/**
	 * 任务
	 * @param	key
	 * @return
	 */
	public function getTaskProtp(key:Int):QuestInfo
	{
		return _protpTask.get(key);
	}
	/**
	 * 所领取的任务ID
	 * @param	id
	 */
	public function setTaskId(id:Int):Void
	{
		taskId = id;
	}
	/**
	 * 选择奖励类型
	 * @param	_taskType
	 */
	public function setTaskType(id:Int):Void
	{
		taskType = id;
	}
	public function appendXml(data:Xml):Void
	{
		
		var source:Fast = new Fast(data);
		source = source.node.root;
		arr = [];
		var propQuest:Fast, id:Int;
		for (propQuest in source.nodes.propQuest)
		{
			id = Std.parseInt(propQuest.node.SN.innerData);
			
			var info:Dynamic ;
			info = new QuestInfo();
			info.readXml(propQuest);
			_protpTask.set(id, info);
			arr.push(info);
			
		}
	}
	public function get_protpTask():Array<Dynamic>
	{
		return arr;
	}
	
}