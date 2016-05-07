package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
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
	
	private var _data:IntMap<DuplicateInfo>;
	private var _duplicateArr:Array<Array<DuplicateInfo>>;
	
	public function new() 
	{
		_data = new IntMap();
		_duplicateArr = new Array();
		var req = RemoteSqlite.instance.request(TableType.Stage);
		for (i in req) 
		{
			var info:DuplicateInfo = new DuplicateInfo();
			info.readXml(i);
			_data.set(info.Id, info);
			var arr = [];
			if ((info.Id - 1) % 5 == 0)
			{
				if (arr.length > 0)
					_duplicateArr.push(arr);
				arr = [];
			}
			arr.push(info);
		}
	}
	
	public function getProtoDuplicate():IntMap<DuplicateInfo>
	{
		return _data;
	}
	
	public function getProtoDuplicateByID(key:Int):DuplicateInfo
	{
		return _data.get(key);
	}
	public function getDuplicateArr():Array<Array<DuplicateInfo>>
	{
		return _duplicateArr;
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
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
				if (arr != null && arr.length != 0)
					_duplicateArr.push(arr);
				arr = [];
			}
			arr.push(du);
		}*/
	}
	
}