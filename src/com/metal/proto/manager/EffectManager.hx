package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.EffectInfo;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class EffectManager
{
	public static var instance(get, null):EffectManager;
	static private function get_instance() {
		if (instance == null)
			instance = new EffectManager();
		return instance;
	}
	
	
	private var _data:IntMap<EffectInfo>;
	
	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.Effect);
		for (i in req) 
		{
			var info:EffectInfo = new EffectInfo();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	/**bullet*/
	public function getProto(key:Int):EffectInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propEffects) {
			var eff:EffectInfo = new EffectInfo();
			eff.readXml(propText);
			_data.set(eff.Id, eff);
		}*/
	}
	
}