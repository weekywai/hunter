package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
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
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.Skill);
		for (i in req) 
		{
			var info:SkillInfo = new SkillInfo();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	public var _data:IntMap<SkillInfo>;
	
	/**提示*/
	public function getInfo(Id:Int):SkillInfo
	{
		return _data.get(Id);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var room:Fast;
		var info:SkillInfo;
		for (skill in source.nodes.propSkill) {
			info = new SkillInfo();
			info.readXml(skill);
			_data.set(info.Id,info);
		}*/
	}
}