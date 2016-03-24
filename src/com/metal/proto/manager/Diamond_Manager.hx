package com.metal.proto.manager;
import com.metal.proto.impl.Gold_Info;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author zxk
 */
class Diamond_Manager
{
	public static var instance(default, null):Diamond_Manager = new Diamond_Manager();
	
	private var _data:IntMap<Gold_Info>;
	public var data(get, null):IntMap<Gold_Info>;
	private function get_data()
	{
		return _data;
	}

	public function new() 
	{
		_data = new IntMap();
	}
	
	public function getProto(key:Int):Gold_Info
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propGoldShop) {
			var gold:Gold_Info = new Gold_Info();
			gold.readXml(propText);
			_data.set(gold.Id, gold);
		}
	}
	
}