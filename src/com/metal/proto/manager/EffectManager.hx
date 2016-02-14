package com.metal.proto.manager;
import com.metal.proto.impl.EffectInfo;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class EffectManager
{
	public static var instance(default, null):EffectManager = new EffectManager();
	
	private var _data:IntMap<EffectInfo>;
	
	public function new() 
	{
		_data = new IntMap();	
	}
	/**bullet*/
	public function getProto(key:Int):EffectInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propEffects) {
			var eff:EffectInfo = new EffectInfo();
			eff.readXml(propText);
			_data.set(eff.Id, eff);
		}
	}
	
}