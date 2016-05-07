package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.ModelInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class ModelManager
{

	public static var instance(default, null):ModelManager = new ModelManager();
	
	private var _data:IntMap<ModelInfo>;
	
	public function new() 
	{
		_data = new IntMap();	
		var req = RemoteSqlite.instance.request(TableType.Model);
		for (i in req) 
		{
			var info:ModelInfo = new ModelInfo();
			info.readXml(i);
			_data.set(info.ID, info);
		}
	}
	
	public function getProto(key:Int):ModelInfo
	{
		return _data.get(key);
	}
	
	public function appendXml(data:Xml):Void {
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var prop:Fast;
		for (prop in source.nodes.propModel) {
			var info:ModelInfo = new ModelInfo();
			info.readXml(prop);
			_data.set(info.ID, info);
		}*/
	}
	
}