package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.RandomNameInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author ...
 */
class RandomNameManager
{
	public static var instance(default, null):RandomNameManager = new RandomNameManager();
	private var _data:IntMap<RandomNameInfo>;
	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.RamName);
		for (i in req) 
		{
			var info:RandomNameInfo = new RandomNameInfo();
			info.readXml(i);
			_data.set(info.id, info);
		}
	}
	public function getRandomProtp(key:Int):RandomNameInfo
	{
		return _data.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var Randomlynamed:Fast;
		for (Randomlynamed in source.nodes.Randomlynamed)
		{
			var info:RandomNameInfo ;
			info = new RandomNameInfo();
			info.readXml(Randomlynamed);
			_data.set(info.id, info);
		}*/
	}
}