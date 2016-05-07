package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
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
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.Monster);
		for (i in req) 
		{
			var info:MonsterInfo = new MonsterInfo();
			info.readXml(i);
			_data.set(info.ID, info);
		}
	}
	
	public var _data:IntMap<MonsterInfo>;
	
	/**提示*/
	public function getInfo(Id:Int):MonsterInfo
	{
		return _data.get(Id);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var room:Fast;
		var info:MonsterInfo;
		for (room in source.nodes.propMonster) {
			info = new MonsterInfo();
			info.readXml(room);
			_data.set(info.ID,info);
		}*/
	}
}