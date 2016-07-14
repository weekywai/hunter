package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.TreasuerHuntInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...宝箱
 * @author hyg
 */
class TreasuerHuntManager
{
	public static var instance(get, null):TreasuerHuntManager;
	static private function get_instance() {
		if (instance == null)
			instance = new TreasuerHuntManager();
		return instance;
	}
	
	public var _data:IntMap<TreasuerHuntInfo>;
	public function new() 
	{
		_data = new IntMap<TreasuerHuntInfo>();
		var req = RemoteSqlite.instance.request(TableType.ChestGroup);
		for (i in req) 
		{
			var info:TreasuerHuntInfo = new TreasuerHuntInfo();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	public function getChest(key:Int):TreasuerHuntInfo
	{
		return _data.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propBuyChest:Fast, subId:Int;
		
		for (propBuyChest in source.nodes.propBuyChestGroup) 
		{
			//subId = Std.parseInt(propBuyChest.node.Level.innerData);
			var info:TreasuerHuntInfo=new TreasuerHuntInfo() ;
			info.readXml(propBuyChest);
			_data.set(info.id, info);
		}*/
	}
}