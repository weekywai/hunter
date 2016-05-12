package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.AppearInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class AppearManager
{

	public static var instance(default, null):AppearManager = new AppearManager();
	
	private var _data:IntMap<AppearInfo>;
	
	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.MonsterAppear);
		for (i in req) 
		{
			var info:AppearInfo = new AppearInfo();
			info.readXml(i);
			_data.set(info.ID, info);
		}
	}
	
	public function getProto(key:Int):AppearInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propMonsterAppear) {
			var info:AppearInfo = new AppearInfo();
			info.readXml(propText);
			_data.set(info.ID, info);
		}*/
	}
}