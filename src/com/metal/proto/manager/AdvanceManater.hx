package com.metal.proto.manager;
import com.metal.proto.impl.AdvanceInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author ...
 */
class AdvanceManater
{
	public static var instance(default, null):AdvanceManater = new AdvanceManater();
	private var _protpAdvance:IntMap<AdvanceInfo>;
	public function new() 
	{
		_protpAdvance = new IntMap<AdvanceInfo>();
	}
	public function getProtpAdvance(key:Int):AdvanceInfo
	{
		return _protpAdvance.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propLevelUpEquip:Fast, subId:Int;
		
		for (propLevelUpEquip in source.nodes.propLevelUpEquip) 
		{
			subId = Std.parseInt(propLevelUpEquip.node.DstID.innerData);
			var info:AdvanceInfo=new AdvanceInfo() ;
			info.readXml(propLevelUpEquip);
			_protpAdvance.set(subId, info);
		}
	}
}