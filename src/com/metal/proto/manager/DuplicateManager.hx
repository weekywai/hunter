package com.metal.proto.manager;
import com.metal.proto.impl.DuplicateInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * 副本表
 * @author li
 */
class DuplicateManager
{
	public static var instance(default, null):DuplicateManager = new DuplicateManager();
	
	private var _protoDuplicate:IntMap<DuplicateInfo>;
	private var _duplicateArr:Array<Array<DuplicateInfo>>;
	
	public function new() 
	{
		_protoDuplicate = new IntMap();
		_duplicateArr = new Array();
	}
	
	public function getProtoDuplicate():IntMap<DuplicateInfo>
	{
		return _protoDuplicate;
	}
	
	public function getProtoDuplicateByID(key:Int):DuplicateInfo
	{
		return _protoDuplicate.get(key);
	}
	public function getDuplicateArr():Array<Array<DuplicateInfo>>
	{
		return _duplicateArr;
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propStage:Fast, id:Int;
		
		var arr:Array<DuplicateInfo> = new Array();
		for (propStage in source.nodes.propStage) {
			id = Std.parseInt(propStage.node.ID.innerData);
			var du:DuplicateInfo = new DuplicateInfo();
			du.readXml(propStage);
			_protoDuplicate.set(id, du);
			if ((id - 1) % 5 == 0)
			{
				if (arr != null && arr.length != 0)_duplicateArr.push(arr);
				arr = [];
			}
			arr.push(du);
		}
	}
	
}