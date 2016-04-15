package com.metal.proto.manager;
import com.metal.proto.impl.TreasuerHuntInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...宝箱
 * @author hyg
 */
class TreasuerHuntManager
{
	public static var instance(default, null):TreasuerHuntManager = new TreasuerHuntManager();
	public var _protpGroup:IntMap<TreasuerHuntInfo>;
	public function new() 
	{
		_protpGroup = new IntMap<TreasuerHuntInfo>();
	}
	public function getChest(key:Int):TreasuerHuntInfo
	{
		return _protpGroup.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propBuyChest:Fast, subId:Int;
		
		for (propBuyChest in source.nodes.propBuyChestGroup) 
		{
			//subId = Std.parseInt(propBuyChest.node.Level.innerData);
			var info:TreasuerHuntInfo=new TreasuerHuntInfo() ;
			info.readXml(propBuyChest);
			_protpGroup.set(info.id, info);
		}
	}
}