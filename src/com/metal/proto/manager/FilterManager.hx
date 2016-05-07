package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.FilterInfo;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.xml.Fast;

/**
 * 字库屏蔽信息
 * @author ...
 */
class FilterManager
{
	public static var instance(default, null):FilterManager = new FilterManager();
	
	private var _data:StringMap<FilterInfo>;
	public function new() 
	{
		_data = new StringMap();
		var req = RemoteSqlite.instance.request(TableType.Filter);
		for (i in req) 
		{
			var info:FilterInfo = new FilterInfo();
			info.readXml(i);
			_data.set(info.name, info);
		}
	}
	public function getFilterProtp(key:String):FilterInfo
	{
		return _data.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propFilter:Fast;
		for (propFilter in source.nodes.propFilter)
		{
			
			var info:FilterInfo ;
			info = new FilterInfo();
			info.readXml(propFilter);
			_data.set(info.name, info);
		}*/
	}
}