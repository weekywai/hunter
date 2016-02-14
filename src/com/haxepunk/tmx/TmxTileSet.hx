/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

import com.haxepunk.graphics.atlas.TileAtlas;
import com.metal.config.ResPath;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import haxe.xml.Fast;
import openfl.Assets;

abstract TileSetData(Fast)
{
	private inline function new(f:Fast) this = f;
	@:to public inline function toMap():Fast return this;

	@:from public static inline function fromFast(f:Fast)
		return new TileSetData(f);

	@:from public static inline function fromByteArray(ba:ByteArray) {
		var f = new Fast(Xml.parse(ba.toString()));
		return new TileSetData(f.node.tileset);
	}
}

class TmxTileSet
{
	private var _tileProps:Array<TmxPropertySet>;
	private var _image:BitmapData;

	public var firstGID:Int;
	public var name:String;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var spacing:Int=0;
	public var margin:Int=0;
	public var imageSource:String;

	//available only after image has been assigned:
	public var numTiles:Int;
	public var numRows:Int;
	public var numCols:Int;
	
	//新加 图片资源宽度
	public var picWidth:Int;
	public function new(data:TileSetData)
	{
		var node:Fast, source:Fast;
		numTiles = 0xFFFFFF;
		numRows = numCols = 1;

		source = data;

		firstGID = (source.has.firstgid) ? Std.parseInt(source.att.firstgid) : 1;

		// check for external source
		if (source.has.source)
		{
			source = new Fast(Xml.parse(Assets.getText(ResPath.MapRoot + source.att.source)));
			praseTileset(source.node.tileset);
		}
		else // internal
		{
			praseTileset(source);
		}
	}
	
	private function praseTileset(source:Fast)
	{
		var node:Fast = source.node.image;
		imageSource = ResPath.MapRoot + node.att.source;
		name = source.att.name;
		picWidth = Std.parseInt(node.att.width);
		
		if (source.has.tilewidth) tileWidth = Std.parseInt(source.att.tilewidth);
		if (source.has.tileheight) tileHeight = Std.parseInt(source.att.tileheight);
		if (source.has.spacing) spacing = Std.parseInt(source.att.spacing);
		if (source.has.margin) margin = Std.parseInt(source.att.margin);
		

		numCols = Math.floor(Std.parseInt(node.att.width) / tileWidth);
		numRows = Math.floor(Std.parseInt(node.att.height) / tileHeight);
		numTiles = numRows * numCols;
		//read properties
		_tileProps = new Array<TmxPropertySet>();
		for (node in source.nodes.tile)
		{
			if (node.has.id)
			{
				var id:Int = Std.parseInt(node.att.id);
				_tileProps[id] = new TmxPropertySet();
				for (prop in node.nodes.properties)
					_tileProps[id].extend(prop);
			}
		}
	}

	public var image(get, set):BitmapData;
	private function get_image():BitmapData
	{
		return _image;
	}
	public function set_image(v:BitmapData):BitmapData
	{
		_image = v;
		//TODO: consider spacing & margin
		numCols = Math.floor(v.width / tileWidth);
		numRows = Math.floor(v.height / tileHeight);
		numTiles = numRows * numCols;
		//硬件渲染
		if (HXP.renderMode == RenderMode.HARDWARE) {
			atlas = new TileAtlas(_image);
			//trace(firstGID);
			atlas.prepare(tileWidth, tileHeight, 0, 0);
		}
		
		return _image;
	}
	public var atlas:TileAtlas;

	public function hasGid(gid:Int):Bool
	{
		return (gid >= firstGID) && (gid < firstGID + numTiles);
	}

	public function fromGid(gid:Int):Int
	{
		return gid - firstGID;
	}

	public function toGid(id:Int):Int
	{
		return firstGID + id;
	}

	public function getPropertiesByGid(gid:Int):TmxPropertySet
	{
		if (_tileProps != null)
			return _tileProps[gid - firstGID];
		return null;
	}

	public function getProperties(id:Int):TmxPropertySet
	{
		return _tileProps[id];
	}

	public function getRect(id:Int):Rectangle
	{
		//TODO: consider spacing & margin
		return new Rectangle((id % numCols) * tileWidth, Std.int(id / numCols) * tileHeight, tileWidth+spacing, tileHeight+spacing);
	}
	
	//添加一个判断是否自身资源的方法 根据gid 返回bool
	public function checkMySrcByGID(gid:Int):Bool
	{
		var key:Bool = false;
		return key;
	}
	
	public function dispose():Void 
	{
		_tileProps = null;
		_image = null;
		if(atlas!=null) atlas.destroy();
		atlas = null;
	}
	
}
