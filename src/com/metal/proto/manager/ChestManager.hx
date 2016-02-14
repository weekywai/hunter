package com.metal.proto.manager;
import com.metal.proto.impl.ChestInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * 购买宝箱信息
 * @author hyg
 */
class ChestManager
{
	public static var instance(default, null):ChestManager = new ChestManager();
	private var _protpChest:IntMap<ChestInfo>;
	public function new() 
	{
		_protpChest = new IntMap<ChestInfo>();
	}
	public function getChest(key:Int):ChestInfo
	{
		return _protpChest.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propBuyChest:Fast, subId:Int;
		
		for (propBuyChest in source.nodes.propBuyChest) 
		{
			//subId = Std.parseInt(propBuyChest.node.Level.innerData);
			var info:ChestInfo=new ChestInfo() ;
			info.readXml(propBuyChest);
			_protpChest.set(info.Level, info);
		}
	}
}