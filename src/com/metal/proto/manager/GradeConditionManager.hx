package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.GradeConditionInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author ...
 */
class GradeConditionManager
{
	public static var instance(get, null):GradeConditionManager;
	static private function get_instance() {
		if (instance == null)
			instance = new GradeConditionManager();
		return instance;
	}
	
	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.Grade);
		for (i in req) 
		{
			var info:GradeConditionInfo = new GradeConditionInfo();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	
	public var _data:IntMap<GradeConditionInfo>;
	
	/**提示*/
	public function getGradeConditionInfo(id:Int):GradeConditionInfo
	{
		return _data.get(id);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propGradeCondition:Fast;
		var tempInfo:GradeConditionInfo;
		for (propGradeCondition in source.nodes.propGradeCondition) {
			tempInfo = new GradeConditionInfo();
			tempInfo.readXml(propGradeCondition);
			_data.set(tempInfo.Id,tempInfo);
		}*/
	}
	
	
}