package com.metal.proto.manager;
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
	private var _protpRandom:IntMap<RandomNameInfo>;
	public function new() 
	{
		_protpRandom = new IntMap();
	}
	public function getRandomProtp(key:Int):RandomNameInfo
	{
		return _protpRandom.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var Randomlynamed:Fast;
		for (Randomlynamed in source.nodes.Randomlynamed)
		{
			var info:RandomNameInfo ;
			info = new RandomNameInfo();
			info.readXml(Randomlynamed);
			_protpRandom.set(info.id, info);
		}
	}
}