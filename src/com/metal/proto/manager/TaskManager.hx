package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.QuestInfo;
import com.metal.proto.impl.Task_Info;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author zxk
 */
class TaskManager
{

	public static var instance(get, null):TaskManager;
	static private function get_instance() {
		if (instance == null)
			instance = new TaskManager();
		return instance;
	}
	
	private var _data:IntMap<Task_Info>;

	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.Task);
		for (i in req) 
		{
			var info:Task_Info = new Task_Info();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	
	public function getProto(key:Int):Task_Info
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.proptask) {
			var task:Task_Info = new Task_Info();
			task.readXml(propText);
			_data.set(task.Id, task);
		}*/
	}
	
}