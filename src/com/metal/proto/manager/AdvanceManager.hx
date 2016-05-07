package com.metal.proto.manager;
import com.metal.config.TableType;
import com.metal.network.RemoteSqlite;
import com.metal.proto.impl.AdvanceInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * ...
 * @author ...
 */
class AdvanceManager
{
	public static var instance(default, null):AdvanceManager = new AdvanceManager();
	private var _data:IntMap<AdvanceInfo>;
	public function new() 
	{
		_data = new IntMap<AdvanceInfo>();
		var req = RemoteSqlite.instance.request(TableType.UpgradeEquip);
		for (i in req) 
		{
			var info:AdvanceInfo = new AdvanceInfo();
			info.readXml(i);
			_data.set(info.ID, info);
		}
	}
	public function getProtpAdvance(key:Int):AdvanceInfo
	{
		return _data.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		/*var source:Fast = new Fast(data);
		source = source.node.root;
		
		var propLevelUpEquip:Fast, subId:Int;
		
		for (propLevelUpEquip in source.nodes.propLevelUpEquip) 
		{
			subId = Std.parseInt(propLevelUpEquip.node.DstID.innerData);
			var info:AdvanceInfo=new AdvanceInfo() ;
			info.readXml(propLevelUpEquip);
			_protpAdvance.set(subId, info);
		}*/
	}
}