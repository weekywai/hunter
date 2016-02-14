package com.metal.proto.manager;
import com.metal.proto.impl.QuestInfo;
import com.metal.proto.impl.Task_Info;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author zxk
 */
class Task_Manager
{

	public static var instance(default, null):Task_Manager = new Task_Manager();
	
	private var _data:IntMap<Task_Info>;

	public function new() 
	{
		_data = new IntMap();
	}
	
	public function getProto(key:Int):Task_Info
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.proptask) {
			var task:Task_Info = new Task_Info();
			task.readXml(propText);
			_data.set(task.Id, task);
		}
	}
	
}