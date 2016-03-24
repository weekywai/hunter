package com.metal.proto.manager;
import com.metal.proto.impl.NoviceInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author cqm
 */
class NoviceManager
{
	public static var instance(default, null):NoviceManager = new NoviceManager();
	private var _data:IntMap<NoviceInfo>;
	public var novice(get, null):IntMap<NoviceInfo>;
	private function get_novice():IntMap<NoviceInfo>
	{
		return _data;
	}
	public function new() 
	{
		_data = new IntMap();
	}
	
	public function getProto(key:Int):NoviceInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propText) {
			var noviceInfo:NoviceInfo = new NoviceInfo();
			noviceInfo.readXml(propText);
			_data.set(noviceInfo.ID, noviceInfo);
		}
	}
	
}