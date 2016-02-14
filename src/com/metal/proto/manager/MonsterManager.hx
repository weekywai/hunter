package com.metal.proto.manager;
import haxe.ds.IntMap;
import com.metal.proto.impl.MonsterInfo;
import haxe.xml.Fast;
/**
 * ...
 * @author weeky
 */
class MonsterManager
{

	public static var instance(default, null):MonsterManager = new MonsterManager();
	
	public function new() 
	{
		proto = new IntMap();
	}
	
	public var proto:IntMap<MonsterInfo>;
	
	/**提示*/
	public function getInfo(Id:Int):MonsterInfo
	{
		return proto.get(Id);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var room:Fast;
		var info:MonsterInfo;
		for (room in source.nodes.propMonster) {
			info = new MonsterInfo();
			info.readXml(room);
			proto.set(info.ID,info);
		}
	}
}