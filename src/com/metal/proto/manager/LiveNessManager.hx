package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.LiveNessInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author zxk
 */
class LiveNessManager
{
	public static var instance(get, null):LiveNessManager;
	static private function get_instance() {
		if (instance == null)
			instance = new LiveNessManager();
		return instance;
	}
	private var _data:IntMap<LiveNessInfo>;
	
	public var LiveNess(get, null):IntMap<LiveNessInfo>;
	private function get_LiveNess():IntMap<LiveNessInfo>
	{
		return _data;
	}
	

	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.Live);
		for (i in req) 
		{
			var info:LiveNessInfo = new LiveNessInfo();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	
	public function getProto(key:Int):LiveNessInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propLiveNess) {
			var liveness:LiveNessInfo = new LiveNessInfo();
			liveness.readXml(propText);
			_data.set(liveness.Id, liveness);
		}*/
	}
	
}