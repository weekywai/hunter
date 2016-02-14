package com.metal.proto.manager;
import com.metal.proto.impl.PlayerModelInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * 
 * @author 3D
 */
class PlayerModelManager
{
public static var instance(default, null):PlayerModelManager = new PlayerModelManager();
	
	private var _data:IntMap<PlayerModelInfo>;
	
	public function new() 
	{
		_data = new IntMap();	
	}
	/**playermodel*/
	public function getInfo(key:Int):PlayerModelInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propPartner) {
			var model:PlayerModelInfo = new PlayerModelInfo();
			model.readXml(propText);
			_data.set(model.SN, model);
		}
	}
	
}