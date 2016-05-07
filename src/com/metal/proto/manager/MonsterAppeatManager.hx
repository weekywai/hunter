package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.MonsterAppearInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author hyg
 */
class MonsterAppeatManager
{
	public static var instance(default, null):MonsterAppeatManager = new MonsterAppeatManager();
	private var _data:IntMap<MonsterAppearInfo> ;
	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.MonsterAppear);
		for (i in req) 
		{
			var info:MonsterAppearInfo = new MonsterAppearInfo();
			info.readXml(i);
			_data.set(info.ID, info);
		}
	}
	
	public function getData(id:Int):MonsterAppearInfo
	{
		return _data.get(id);
	}
	
	public function  appendXml(data:Xml):Void
	{
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propMonsterAppear) {
			var info:MonsterAppearInfo = new MonsterAppearInfo();
			info.readXml(propText);
			_data.set(info.ID, info);
		}*/
	}
}