package com.metal.proto.manager;
import com.metal.proto.impl.GradeConditionInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author ...
 */
class GradeConditionManager
{
	public static var instance(default, null):GradeConditionManager = new GradeConditionManager();
	
	public function new() 
	{
		gradeConditionData = new IntMap();
	}
	
	public var gradeConditionData:IntMap<GradeConditionInfo>;
	
	/**提示*/
	public function getGradeConditionInfo(id:Int):GradeConditionInfo
	{
		return gradeConditionData.get(id);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propGradeCondition:Fast;
		var tempInfo:GradeConditionInfo;
		for (propGradeCondition in source.nodes.propGradeCondition) {
			tempInfo = new GradeConditionInfo();
			tempInfo.readXml(propGradeCondition);
			gradeConditionData.set(tempInfo.Id,tempInfo);
		}
	}
	
	
}