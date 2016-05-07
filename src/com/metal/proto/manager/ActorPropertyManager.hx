package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.ActorPropertyInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author ...
 */
class ActorPropertyManager
{
	public static var instance(default, null):ActorPropertyManager = new ActorPropertyManager();
	private var _data:IntMap<ActorPropertyInfo>;
	public function new() 
	{
		_data = new IntMap<ActorPropertyInfo>();
		var req = RemoteSqlite.instance.request(TableType.Actor);
		for (i in req) 
		{
			var info:ActorPropertyInfo = new ActorPropertyInfo();
			info.readXml(i);
			_data.set(info.Level, info);
		}
	}
	public function getProto(key:Int):ActorPropertyInfo
	{
		return _data.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propActor:Fast;
		for (propActor in source.nodes.propActor) {
			var info:ActorPropertyInfo = new ActorPropertyInfo();
			info.readXml(propActor);
			_data.set(info.Lv, info);
		}*/
	}
}