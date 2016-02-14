package com.metal.proto.manager;
import com.metal.proto.impl.DiamondInfo;
import haxe.ds.IntMap;
import haxe.xml.Fast;

/**
 * 购买钻石信息
 * @author ...
 */
class DiamondManager
{
	public static var instance(default, null):DiamondManager = new DiamondManager();
	private var _protpDiamond:IntMap<DiamondInfo>;
	private var arr:Array<Dynamic>;
	
	private var buyId:Int;
	public function new() 
	{
		_protpDiamond = new IntMap();
	}
	/**
	 * 购买信息
	 * @param	key
	 * @return
	 */
	public function getDiamondProtp(key:Int):DiamondInfo
	{
		return _protpDiamond.get(key);
	}
	public function appendXml(data:Xml):Void
	{
		
		var source:Fast = new Fast(data);
		source = source.node.root;
		arr = [];
		var propGoldShop:Fast, id:Int;
		for (propGoldShop in source.nodes.propGoldShop)
		{
			id = Std.parseInt(propGoldShop.node.SN.innerData);
			
			var info:DiamondInfo ;
			info = new DiamondInfo();
			info.readXml(propGoldShop);
			_protpDiamond.set(id, info);
			arr.push(info);
		}
	}
	public function get_protpDiamond():Array<Dynamic>
	{
		return arr;
	}
}