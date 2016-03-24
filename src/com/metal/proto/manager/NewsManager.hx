package com.metal.proto.manager;
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
	public static var instance(default, null):NewsManager = new NewsManager();
	
	private var _data:IntMap<NewsInfo>;
	public var data(get, null):IntMap<NewsInfo>;
	private function get_data()
	{
		return _data;
	}

	public function new() 
	{
		_data = new IntMap();
	}
	
	public function getProto(key:Int):NewsInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propText:Fast;
		for (propText in source.nodes.propNews) {
			var news:NewsInfo = new NewsInfo();
			news.readXml(propText);
			_data.set(news.Id, news);
		}
	}
	
}