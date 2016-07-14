package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.Gold_Info;
import com.metal.proto.impl.NewsInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class NewsManager
{
	public static var instance(get, null):NewsManager;
	static private function get_instance() {
		if (instance == null)
			instance = new NewsManager();
		return instance;
	}
	
	private var _data:IntMap<NewsInfo>;
	public var data(get, null):IntMap<NewsInfo>;
	private function get_data()
	{
		return _data;
	}

	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.News);
		for (i in req) 
		{
			var info:NewsInfo = new NewsInfo();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	
	public function getProto(key:Int):NewsInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propNews) {
			var news:NewsInfo = new NewsInfo();
			news.readXml(propText);
			_data.set(news.Id, news);
		}*/
	}
	
}