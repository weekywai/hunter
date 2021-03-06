package com.metal.proto.manager;
import com.metal.proto.impl.BulletInfo;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class BulletManager
{
	public static var instance(default, null):BulletManager = new BulletManager();
	
	private var _data:IntMap<BulletInfo>;
	
	public function new() 
	{
		_data = new IntMap();	
	}
	/**bullet*/
	public function getInfo(key:Int):BulletInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propBullet) {
			var bullet:BulletInfo = new BulletInfo();
			bullet.readXml(propText);
			_data.set(bullet.Id, bullet);
		}
	}
	
}