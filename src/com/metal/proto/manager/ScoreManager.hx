package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.ScoreInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * 分数
 * @author li
 */
class ScoreManager
{
	public static var instance(get, null):ScoreManager;
	static private function get_instance() {
		if (instance == null)
			instance = new ScoreManager();
		return instance;
	}
	
	private var _data:IntMap<ScoreInfo>;
	
	public function new() 
	{
		_data = new IntMap();
		var req = RemoteSqlite.instance.request(TableType.Score);
		for (i in req) 
		{
			var info:ScoreInfo = new ScoreInfo();
			info.readXml(i);
			_data.set(info.ScoreType, info);
		}
	}
	
	public function getInfo(Id:Int):ScoreInfo
	{
		return _data.get(Id);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		//var score:Fast;
		var scoreInfo:ScoreInfo;
		for (i in source.nodes.propScore) {
			scoreInfo = new ScoreInfo();
			scoreInfo.readXml(i);
			_data.set(scoreInfo.ScoreType,scoreInfo);
		}*/
	}
}