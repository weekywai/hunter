package com.metal.component;

import com.metal.config.FilesType;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.proto.impl.DuplicateInfo;
import com.metal.proto.impl.QuestInfo;
import com.metal.proto.manager.TaskManager;
import com.metal.utils.FileUtils;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import haxe.ds.IntMap;

/**
 * ...
 * @author 3D
 */
class TaskComponent extends Component
{

	//任务数据
	private var _taskMap:IntMap<QuestInfo>;
	public var taskMap(get, null):IntMap<QuestInfo>;
	private function get_taskMap():IntMap<QuestInfo> { return _taskMap; }
	
	public var taskAllNum:Int;
	public var taskArr:Array<Dynamic> = new Array();
	public var taskArrbtn:Array<Bool>;
	public var taskArrbtn2:Array<Bool>;
	
	
	public function new() 
	{
		super();
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		cmd_initTask(null);
		//trace("MissionComponent2");
	}
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) 
		{
			case MsgNet.UpdateTask :
				cmd_UpdateTask(userData);
				GameProcess.SendUIMsg(MsgUI.AwardPanel, userData);
			case MsgNet.QuestList:
				cmd_QuestList(userData);
			case MsgStartup.BattleResult:
				cmd_updateCopy(userData);
			//case MsgMission.Init:
				//cmd_initTask(userData);
			case MsgMission.Update:
				cmd_Update(userData);
				
		}
		super.onUpdate(type, source, userData);
	}
	override function onDispose():Void 
	{
		super.onDispose();
	}
	/**
	 * 初始化任务数据
	 * @param	task
	 */
	public function cmd_initTask(userData:Dynamic):Void
	{
		taskArr = TaskManager.instance.get_protpTask();
		_taskMap = FileUtils.getTask();// TaskManager.instance.Task;
		taskArrbtn = [false, false, false, false, false, false];
		taskArrbtn2 = [false, false, false, false, false, false];
	}
	//更新任务
	private function cmd_UpdateTask(data:Dynamic):Void
	{
		var info:Dynamic;
		//info = TaskManager.instance.getTaskProtp(data);
		//_taskInfo.taskArr
	}
	/**
	 * 刷新任务列表
	 * @param	data
	 */
	private function cmd_QuestList(data:Dynamic):Void
	{
		//trace("===========questList==========="+data);
	}
	/**更新副本任务*/
	private function cmd_updateCopy(duplicateInfo:DuplicateInfo):Void
	{
		if (duplicateInfo != null)
		{
			searchTask(duplicateInfo.DuplicateType,duplicateInfo);
		}
	}
	/*锻造任务更新*/
	private function cmd_updateForge(userData:Dynamic):Void
	{
		var type:Int = Reflect.field(userData, "id");
		var info = Reflect.field(userData, "info");//Iteminfo
		if (_taskMap == null) return;
		for (i in _taskMap.keys())
		{
			var task = _taskMap.get(i);
			if (type == task.RunType || task.RunType == 8)
			{
				if (task.RunType == 8)
				{
					if (info != null)
					{
						if (info.equipType == 1 &&info.strLv>=task.Count)
						{
							if(task.state!=2)task.state = 1;
						}else if (info.equipType == 13 && info.strLv >= task.Count)
						{
							if(task.state!=2)task.state = 1;
						}
					}
				}
				
				task.Finish += 1;
				
				if (task.Finish >= task.Count)
				{
					task.Finish = task.Count;
					if(task.state!=2)task.state = 1;
				}
				
				
			}
		}
		FileUtils.setFileData(null, FilesType.Task);
	}
	
	private function cmd_Update(userData:Dynamic):Void
	{
		if(userData.type=="task"){
		var info:QuestInfo = userData.data;
		_taskMap.get(info.SN).state = 2;
		FileUtils.setFileData(null, FilesType.Task);
		}else if (userData.type=="forge") {
			cmd_updateForge(userData.data);
		}
	}
	/**根据任务类型查找任务并更新副本任务*/
	public function searchTask(type:Int,duplicateInfo:DuplicateInfo=null):Void
	{
		if (_taskMap == null) return;
		for (i in _taskMap.keys())
		{
			var task = _taskMap.get(i);
			//if (type == 0)//普通关卡
			//{
				if ((task.RunType == 2&&type == 0))
				{
					//task.Finish += 1;
					//
					//if (task.Finish >= task.Count)
					//{
						//task.Finish = task.Count;
						
					if (duplicateInfo != null)
					{
						if (task.state!= 2&&task.SN == duplicateInfo.Id)
						{
							task.state = 1;
							break;
						}
						
					}
					
				}else if ((task.RunType == 12 && type == 9) || (task.RunType == 13 && type == 10) || (task.RunType == 14 && type == 11) || (task.RunType == 15 && type == 12))
				{
					task.Finish += 1;
					
					if (task.Finish >= task.Count)
					{
						task.Finish = task.Count;
						if(task.state!=2)task.state = 1;
					}
				}
			//}
		}
		FileUtils.setFileData(null, FilesType.Task);
	}
	
		/**解析任务网络数据包*/
	public function analyticalTaskPacket(data:Dynamic):Void
	{	
		//var result:Int = Std.parseInt(data.result);
		//var content:String = data.toString();
		//var taskData:String = JsonUtils.parse(content);
		//var _allTask:IntMap<QuestInfo>=TaskManager.instance.Task;
		//for ( taskKey in _taskMap.keys())
		//{
			//var _taskKey:QuestInfo = cast taskKey;
			//var dyna:Dynamic = JsonUtils.getDynamic(taskData, Std.string(_taskKey.SN));
			//if (dyna != null)
			//{
				//_taskKey.SN = dyna.SN;
				//_taskKey.state = dyna.state;
				//_taskKey.type = dyna.type;
			//}
		//}
		
	}
	/**解析需更新的task数据*/
	//public function analyticalTaskData():String
	//{
		//
		//var taskInfo = _taskMap;
		//var updateMap:Map<String,Dynamic> = new Map();
		//var flag:Bool = false;
		//for (task in taskInfo.keys())
		//{	cast task;
			//var questInfo:QuestInfo = cast task;
			//var taskMap:Map<String,Dynamic> = new Map();
			//if (questInfo.type == 0)//主线任务
			//{
				//if ( (questInfo.RepeatType == 0&&questInfo.state!=2)||questInfo.state!=2)
				//{
					//if (questInfo.state == 1 || questInfo.state == 0) {
						//if (flag == true) continue;
						//taskMap.set("SN",questInfo.SN);
						//taskMap.set("state",questInfo.state);
						//taskMap.set("type", questInfo.type);
						//if (questInfo.state == 0) flag = true;
						//updateMap.set(Std.string(questInfo.SN), questInfo.SN);
					//}
				//}
			//}else if (questInfo.type == 1&&questInfo.state == 1)//支线任务
			//{
				//taskMap.set("SN",questInfo.SN);
				//taskMap.set("state",questInfo.state);
				//taskMap.set("type", questInfo.type);
				//updateMap.set(Std.string(questInfo.SN), questInfo.SN);
			//}
			//
		//}
		//return Json.stringify(updateMap);
		//
	//}
	
	
}