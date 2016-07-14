package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.StrengthenInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author ...
 */
class ForgeManager
{
	public static var instance(get, null):ForgeManager;
	static private function get_instance() {
		if (instance == null)
			instance = new ForgeManager();
		return instance;
	}
	
	private var _data:IntMap<StrengthenInfo>;
	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.Strengthen);
		for (i in req) 
		{
			var info:StrengthenInfo = new StrengthenInfo();
			info.readXml(i);
			_data.set(info.SnID, info);
		}
	}
	public function getProtoForge(key:Int):StrengthenInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void
	{
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propStrengthen:Fast, subId:Int;
		
		for (propStrengthen in source.nodes.propStrengthen) 
		{
			subId = Std.parseInt(propStrengthen.node.SnID.innerData);
			var info:StrengthenInfo=new StrengthenInfo() ;
			info.readXml(propStrengthen);
			_data.set(subId, info);
		}*/
	}
	
}