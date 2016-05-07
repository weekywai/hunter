package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.Gold_Info;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author zxk
 */
class DiamondManager
{
	public static var instance(default, null):DiamondManager = new DiamondManager();
	
	private var _data:IntMap<Gold_Info>;
	public var data(get, null):IntMap<Gold_Info>;
	private function get_data()
	{
		return _data;
	}

	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.DiamondShop);
		for (i in req) 
		{
			var info:Gold_Info = new Gold_Info();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	
	public function getProto(key:Int):Gold_Info
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propGoldShop) {
			var gold:Gold_Info = new Gold_Info();
			gold.readXml(propText);
			_data.set(gold.Id, gold);
		}*/
	}
	
}