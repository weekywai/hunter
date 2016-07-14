package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.BuffInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class BuffManager
{
	
	public static var instance(get, null):BuffManager;
	static private function get_instance() {
		if (instance == null)
			instance = new BuffManager();
		return instance;
	}
	
	private var _data:IntMap<BuffInfo>;
	
	public function new() 
	{
		_data = new IntMap();	
		var req = RemoteSqlite.instance.request(TableType.Buff);
		for (i in req) 
		{
			var info:BuffInfo = new BuffInfo();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	/**bullet*/
	public function getProto(key:Int):BuffInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propBuff) {
			var buff:BuffInfo = new BuffInfo();
			buff.readXml(propText);
			_data.set(buff.Id, buff);
		}*/
	}
}