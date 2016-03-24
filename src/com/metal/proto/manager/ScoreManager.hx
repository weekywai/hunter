package com.metal.proto.manager;
import com.metal.proto.impl.ScoreInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * 分数
 * @author li
 */
class ScoreManager
{
	public static var instance(default, null):ScoreManager = new ScoreManager();
	
	private var _data:IntMap<ScoreInfo>;
	
	public function new() 
	{
		_data = new IntMap();
	}
	
	public function getInfo(Id:Int):ScoreInfo
	{
		return _data.get(Id);
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		//var score:Fast;
		var scoreInfo:ScoreInfo;
		for (i in source.nodes.propScore) {
			scoreInfo = new ScoreInfo();
			scoreInfo.readXml(i);
			_data.set(scoreInfo.ScoreType,scoreInfo);
		}
	}
}