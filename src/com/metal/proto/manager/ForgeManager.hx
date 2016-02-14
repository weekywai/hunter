package com.metal.proto.manager;
import com.metal.proto.impl.StrengthenInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author ...
 */
class ForgeManager
{
	public static var instance(default, null):ForgeManager = new ForgeManager();
	private var _protpForge:IntMap<StrengthenInfo>;
	public function new() 
	{
		_protpForge = new IntMap();
	}
	public function getProtpForge(key:Int):StrengthenInfo
	{
		return _protpForge.get(key);
	}
	
	public function appendXml(data:Xml):Void
	{
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propStrengthen:Fast, subId:Int;
		
		for (propStrengthen in source.nodes.propStrengthen) 
		{
			subId = Std.parseInt(propStrengthen.node.SnID.innerData);
			var info:StrengthenInfo=new StrengthenInfo() ;
			info.readXml(propStrengthen);
			_protpForge.set(subId, info);
		}
	}
	
}