package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.ChestInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * 购买宝箱信息
 * @author hyg
 */
class ChestManager
{
	public static var instance(get, null):ChestManager;
	static private function get_instance() {
		if (instance == null)
			instance = new ChestManager();
		return instance;
	}
	private var _data:IntMap<ChestInfo>;
	public function new() 
	{
		_data = new IntMap<ChestInfo>();
		var req = RemoteSqlite.instance.request(TableType.Chest);
		for (i in req) 
		{
			var info:ChestInfo = new ChestInfo();
			info.readXml(i);
			_data.set(info.Level, info);
		}
	}
	public function getChest(key:Int):ChestInfo
	{
		return _data.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propBuyChest:Fast, subId:Int;
		
		for (propBuyChest in source.nodes.propBuyChest) 
		{
			//subId = Std.parseInt(propBuyChest.node.Level.innerData);
			var info:ChestInfo=new ChestInfo() ;
			info.readXml(propBuyChest);
			_data.set(info.Level, info);
		}*/
	}
}