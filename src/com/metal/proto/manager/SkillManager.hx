package com.metal.proto.manager;
import com.metal.proto.impl.SkillInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class SkillManager
{
	public static var instance(default, null):SkillManager = new SkillManager();
	public function new() 
	{
		proto = new IntMap();
	}
	public var proto:IntMap<SkillInfo>;
	
	/**提示*/
	public function getInfo(Id:Int):SkillInfo
	{
		return proto.get(Id);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var room:Fast;
		var info:SkillInfo;
		for (skill in source.nodes.propSkill) {
			info = new SkillInfo();
			info.readXml(skill);
			proto.set(info.Id,info);
		}
	}
}