package com.metal.proto.manager;
import com.metal.proto.impl.BattlePrepareInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * 站前准备
 * @author li
 */
class BattlePrepareManager
{
	public static var instance(default, null):BattlePrepareManager = new BattlePrepareManager();
	
	private var _protoBattlePrepare:IntMap<BattlePrepareInfo>;
	
	/**顺序存储_protoBattlePrepare的key值*/
	private var _protoKeyMap:IntMap<Int>;
	
	private var _protoLength:Int;

	public function new() 
	{
		_protoBattlePrepare = new IntMap();
		_protoKeyMap = new IntMap();
		_protoLength = 0;
	}
	
	public function getProtoBattlePrepare():IntMap<BattlePrepareInfo>
	{
		return _protoBattlePrepare;
	}
	
	public function getProtoBattlePrepareByID(key:Int):BattlePrepareInfo
	{
		return _protoBattlePrepare.get(key);
	}
	
	/**顺序获取_protoBattlePrepare的值*/
	public function getProtoBattlePrepareByOrder(key:Int):BattlePrepareInfo
	{
		var protoKey:Int = _protoKeyMap.get(key);
		return _protoBattlePrepare.get(protoKey);
	}
	
	public function getProtoLength():Int
	{
		return _protoLength;
	}
	
	public function appendXml(data:Xml):Void {
		var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propBattlePrepare:Fast, key:Int, id:Int = 0;
		for (propBattlePrepare in source.nodes.propBattlePrepare) {
			key = Std.parseInt(propBattlePrepare.node.ID.innerData);
			var du:BattlePrepareInfo = new BattlePrepareInfo();
			du.readXml(propBattlePrepare);
			_protoBattlePrepare.set(key, du);
			_protoKeyMap.set(id, key);
			_protoLength++;
			id++;
		}
	}
	
}