package com.metal.proto.manager; 
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.DecompositionInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author hyg
 */
class DecompositionManager
{
	public static var instance(get, null):DecompositionManager;
	static private function get_instance() {
		if (instance == null)
			instance = new DecompositionManager();
		return instance;
	}
	
	private var _data:IntMap<DecompositionInfo>;
	public function new() 
	{
		_data = new IntMap<DecompositionInfo>();
		var req = RemoteSqlite.instance.request(TableType.Decompoe);
		for (i in req) 
		{
			var info:DecompositionInfo = new DecompositionInfo();
			info.readXml(i);
			_data.set(info.Id, info);
		}
	}
	public function getProtoDecom(id:Int):DecompositionInfo
	{
		return _data.get(id);
	}
	public function appendXml(data:Xml):Void
	{
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		var propDecomposition:Fast, id:Int;
		for (propDecomposition in source.nodes.propDecomposition)
		{
			id = Std.parseInt(propDecomposition.node.ID.innerData);
			var decomInfo:DecompositionInfo = new DecompositionInfo();
			decomInfo.readXml(propDecomposition);
			_data.set(id,decomInfo);
		}*/
	}
	
}