package com.metal.proto.manager; 
import com.metal.proto.impl.DecompositionInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author hyg
 */
class DecompositionManager
{
	public static var instance(default, null):DecompositionManager = new DecompositionManager();
	private var _protoDecom:IntMap<DecompositionInfo>;
	public function new() 
	{
		_protoDecom = new IntMap<DecompositionInfo>();
	}
	public function getProtoDecom(id:Int):DecompositionInfo
	{
		return _protoDecom.get(id);
	}
	public function appendXml(data:Xml):Void
	{
		var source:Fast = new Fast(data);
		source = source.node.root;
		var propDecomposition:Fast, id:Int;
		for (propDecomposition in source.nodes.propDecomposition)
		{
			id = Std.parseInt(propDecomposition.node.ID.innerData);
			var decomInfo:DecompositionInfo = new DecompositionInfo();
			decomInfo.readXml(propDecomposition);
			_protoDecom.set(id,decomInfo);
		}
	}
	
}