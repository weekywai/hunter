package com.metal.enums;
import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.tmx.TmxMap;
import com.metal.config.MapLayerType;

/**
 * ...
 * @author 3D
 */
class MapVo
{

	public var entityArr:Array<TmxEntity>;
	public var map:TmxMap;
	public var runKey:Bool;
	public var onePic:Array<String>;
	public var mapId:String;
	public var floorTmx:TmxEntity;
	public var collideLayer:TmxEntity;
	public var mapType:Int;
	//可以根据此数组 调整层级显示关系
	//public static var orderArr:Array<Int> = [7, 6, 5, 4, 3, 2, 1, 0];
	public static var orderArr:Array<Int> = [5, 4, 3, 2, 1, 0];
	public static var nLen:Int = 6;
	
	
	public function new(data:Map, run:Bool = false, type:Int)
	{
		var tmx:TmxEntity;
		reset();
		runKey = run;
		mapType = type;
		this.map = data;
		for (i in 0...nLen) {
			tmx = new TmxEntity(map);
			tmx.scrollMap = run;
			if (i == 0)
				tmx.layer = MapLayerType.FrontLayer;
			else 
				tmx.layer = MapLayerType.MapLayer;
			entityArr.push(tmx);
		}
		floorTmx = new TmxEntity(map);
		collideLayer = new TmxEntity(map);
		if (runKey) onePic = [];
	}
	
	public function reset() : Void {
		entityArr = [];
		floorTmx = null;
		onePic = [];
	}
	
	public function getEntityByLayer(layer:Int):TmxEntity
	{
		return entityArr[layer];
	}
	
	public function onDispose():Void
	{
		var len:Int = entityArr.length;
		for(i in 0...len){
			for (en in entityArr) {
				//en = null;
				entityArr.remove(en);
			}
		}
		entityArr = null;
		floorTmx = null;
		onePic = null;
		map = null;
	}
}