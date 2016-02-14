package com.haxepunk.tmx;

import com.haxepunk.Entity;
import com.haxepunk.Graphic.TileType;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.Masklist;
import com.haxepunk.masks.SlopedGrid;
import com.haxepunk.tmx.TiledRenderer;
import com.haxepunk.tmx.TmxMap;
import haxe.ds.IntMap;
import openfl.Assets;

abstract Map(TmxMap)
{
	private inline function new(map:TmxMap) this = map;
	@:to public inline function toMap():TmxMap return this;

	@:from public static inline function fromString(s:String)
		return new Map(new TmxMap(Xml.parse(openfl.Assets.getText(s))));

	@:from public static inline function fromTmxMap(map:TmxMap)
		return new Map(map);

	@:from public static inline function fromMapData(mapData:MapData)
		return new Map(new TmxMap(mapData));
}

class TmxEntity extends Entity
{
	//可以根据此数组 调整层级显示关系
	public var map:TmxMap;
	public var debugObjectMask:Bool;
	public var onePicLayer:Int = -1;
	
	public var runKey:Bool = false;
	public var speed:Int = 0;
	public var addSpeed:Bool = false;
	public var mapW:Int = 0;
	public var scrollMap:Bool = false;
	/*map类型*/
	public var mapType:Int;
	private var _layerNames:String;
	
	private var _cacheMaps:IntMap<Tilemap> = new IntMap();
	
	public function new(mapData:Map)
	{
		super();
		
		map = mapData;
#if debug
		debugObjectMask = true;
#end
	}

	public function loadImageLayer(name:String)
	{
		if (map.imageLayers.exists(name) == false)
		{
#if debug
			trace("Image layer '" + name + "' doesn't exist");
#end
			return;
		}
		
		addGraphic(new Image(map.imageLayers.get(name)));
	}

	
	private function getTileset(path:String):TmxTileSet 
	{
		for (tileset in map.tilesets)
		{
			if (tileset.imageSource == path)
			{
				return tileset;
			}
		}
		return null;
	}
	
	public function loadGraphic(layerNames:String, ?corrected:Int = -1):Void
	{
		//trace(layerNames);
		var gid:Int, layer:TmxLayer, tileset:TmxTileSet;
		var num:Int = scrollMap?2:1;
		layer = map.layers.get(layerNames);
		var tilemap = new TiledRenderer(map, map.fullWidth * num, map.fullHeight, layerNames);
		for (row in 0...layer.height)
		{
			for (col in 0...layer.width*num)
			{
				gid = layer.tileGIDs[row][col%layer.width];// + corrected;
				if (gid < 0) continue;
				/*
				var tileset:TmxTileSet = map.getGidOwner(gid);
				if (tileset != null) {
					if (!TiledRenderer.atlas.exists(tileset.firstGID)) {
						var atlas:TileAtlas = new TileAtlas(tileset.imageSource);
						atlas.prepare(map.tileWidth, map.tileHeight);
						TiledRenderer.atlas.set(tileset.firstGID, atlas);
					}
				}
				*/
				tilemap.setTile(col, row, gid);
			}
		}
		addGraphic(tilemap);
	}

	public function loadMask(collideLayer:String = "collide", typeName:String = "solid", skip:Array<Int> = null)
	{
		var tileCoords:Array<TmxVec4> = new Array<TmxVec4>();
		if (!map.layers.exists(collideLayer))
		{
#if debug
				trace("Layer '" + collideLayer + "' doesn't exist");
#end
			return tileCoords;
		}

		var gid:Int;
		var layer:TmxLayer = map.layers.get(collideLayer);
		var grid = new Grid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);

		// Loop through tile layer ids
		for (row in 0...layer.height)
		{
			for (col in 0...layer.width)
			{
				gid = layer.tileGIDs[row][col] - 1;
				if (gid < 0) continue;
				if (skip == null || Lambda.has(skip, gid) == false)
				{
					grid.setTile(col, row, true);
					tileCoords.push(new TmxVec4(col*map.tileWidth, row*map.tileHeight, map.tileWidth, map.tileHeight));
				}
			}
		}

		this.mask = grid;
		this.type = typeName;
		setHitbox(grid.width, grid.height);
		return tileCoords;
	}
	
	public function loadSlopedMask(collideLayer:String = "collide", typeName:String = "solid", skip:Array<Int> = null)
	{
		if (!map.layers.exists(collideLayer))
		{
#if debug
				trace("Layer '" + collideLayer + "' doesn't exist");
#end
			return;
		}
		
		var gid:Int;
		var layer:TmxLayer = map.layers.get(collideLayer);
		var grid = new SlopedGrid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);
		var types = Type.getEnumConstructs(TileType);
		
		for (row in 0...layer.height)
		{
			for (col in 0...layer.width)
			{
				gid = layer.tileGIDs[row][col] - 1;
				if (gid < 0) continue;
				if (skip == null || Lambda.has(skip, gid) == false)
				{
					var type = map.getGidProperty(gid + 1, "tileType");
					
					// collideType is null, load as solid tile
					if (type == null)
						grid.setTile(col, row, Solid);
						
					// load as custom collide type tile
					else
					{
						//trace(types+">>"+type);
						for(i in 0...types.length)
						{
							if(type == types[i])
							{
								grid.setTile(col, row,
									Type.createEnum(TileType, type),
									Std.parseFloat(map.getGidProperty(gid + 1, "slope")),
									Std.parseFloat(map.getGidProperty(gid + 1, "yOffset"))
									);
								break;
							}
						}
					}
				}
			}
		}
		
		this.mask = grid;
		this.type = typeName;
		setHitbox(grid.width, grid.height);
	}

	/*
		debugging shapes of object mask is only availble in -flash
		currently only supports ellipse object (circles only), and rectangle objects
			no polygons yet
	*/
	public function loadObjectMask(collideLayer:String = "objects", typeName:String = "solidObject")
	{
		if (map.getObjectGroup(collideLayer) == null)
		{
#if debug
				trace("ObjectGroup '" + collideLayer + "' doesn't exist");
#end
			return;
		}
		var objectGroup:TmxObjectGroup = map.getObjectGroup(collideLayer);
		var masks_ar = new Array<Dynamic>();
#if debug
		var debug_graphics_ar = new Array<Graphic>();
#end
		// Loop through objects
		for(object in objectGroup.objects){ // :TmxObject
			masks_ar.push(object.shapeMask);
#if debug
			debug_graphics_ar.push(object.debug_graphic);
#end
		}
#if debug
		if(debugObjectMask){
			var debug_graphicList = new Graphiclist(debug_graphics_ar);
			this.addGraphic(debug_graphicList);
		}
#end
		var maskList = new Masklist(masks_ar);
		this.mask = maskList;
		this.type = typeName;
	}
	
	/***********************************************************/
	public function loadGraphicMapNew(layerNames:String,corrected:Int= 0,skip:Array<Int> = null)
	{
		if (map.layers.exists(layerNames) == false)
		{
			return;
		}
		loadGraphics(layerNames,corrected);
		//loadGraphic(layerNames,corrected);
	}
	
	public function loadGraphics(layerNames:String, corrected:Int, skip:Array<Int> = null):Void
	{
		var gid:Int, layer:TmxLayer;
		_layerNames = layerNames;
		layer = map.layers.get(layerNames);
		var spacing = map.getTileMapSpacing(name);
	
		var  tempNum:Int = 0;
		//滚屏地图几多屏
		var num:Int = scrollMap?2:1;
		_cacheMaps = new IntMap();
		for (row in 0...layer.height)
		{
			for (col in 0...layer.width)
			{
				gid = layer.tileGIDs[row][col] + corrected;
				
				if (gid < 0) continue;
				var tileset:TmxTileSet = map.getGidOwner(gid);
				if (tileset != null && !_cacheMaps.exists(tileset.firstGID)) {
					var tilemap = new Tilemap(tileset.imageSource, map.fullWidth*num, map.fullHeight, map.tileWidth, map.tileHeight, spacing, spacing);
					_cacheMaps.set(tileset.firstGID, tilemap);
				}
			}
		}
		
		// Loop through tile layer ids
		for (row in 0...layer.height)
		{
			for (col in 0...layer.width*num)
			{
				gid = layer.tileGIDs[row][col%layer.width] + corrected;
				
				if (gid < 0) continue;
				if (skip == null || Lambda.has(skip, gid) == false)
				{	
					var tileset:TmxTileSet = map.getGidOwner(gid);
					if (tileset != null && _cacheMaps.exists(tileset.firstGID)) {
						_cacheMaps.get(tileset.firstGID).setTile(col, row, gid - tileset.firstGID);
					}
				}
			}
		}
		
		for(tempMap in _cacheMaps.iterator()){
			addGraphic(tempMap);
		}
	}
	
	override public function removed():Void 
	{
		graphic = null;
		map.dispose();
		map = null;
		if(_cacheMaps!=null){
			for (key in _cacheMaps.keys()) 
			{
				var tileMap = _cacheMaps.get(key);
				tileMap.destroy();
				_cacheMaps.remove(key);
			}
		}
		_cacheMaps = null;
		super.removed();
	}
	
	/**开始滚屏**/
	public function startRunLayer(speed:Int):Void
	{
		this.speed = speed;
		runKey = true;
		if (!runKey || graphic == null) return;
	}
	
	/**停止滚屏**/
	public function stopRunLayer():Void
	{
		runKey = false;
		speed = 0;
	}
	
	override public function update():Void 
	{
		super.update();
		if (!runKey || graphic == null) return;
		if (x <= -map.fullWidth)
			x += map.fullWidth;
		moveTowards( -map.fullWidth, y, (addSpeed?20:speed));
	}
}