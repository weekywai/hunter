package com.haxepunk.tmx;

import com.haxepunk.graphics.atlas.AtlasData;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.AtlasRegion;
import com.haxepunk.graphics.atlas.TileAtlas;
import com.haxepunk.graphics.Canvas;
import com.haxepunk.HXP;
import com.haxepunk.masks.Grid;
import com.haxepunk.tmx.TmxMap;
import com.haxepunk.tmx.TmxTileSet;
import haxe.ds.IntMap;
import openfl.display.BitmapData;
import openfl.display.Tilesheet;
import openfl.errors.Error;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import pgr.dconsole.DC;

/**
 * A canvas to which Tiles can be drawn for fast multiple tile rendering.
 */
class TiledRenderer extends Canvas
{
	/**
	 * If x/y positions should be used instead of columns/rows.
	 */
	public var usePositions:Bool;
	
	public var layerName:String;
	
	public var atlas:IntMap<AtlasRegion> = new IntMap();
	
	var _renderList:Array<Int> = [];
	/**
	 * Constructor.
	 * @param	map				TmxMap tiled map data.
	 * @param	layerName		layer name.
	 */
	public function new(map:TmxMap, width:Int, height:Int, layerName:String, ?opaqueTiles:Bool=true)
	{
		if (map == null)
			throw new Error("tmxMap is null");
			
		_rect = HXP.rect;
		this.layerName = layerName;
		// set some tilemap information
		_map = map;
		_width = _map.fullWidth - (width % _map.tileWidth);
		_height = _map.fullHeight - (height % _map.tileHeight);
		_columns = Std.int(width / _map.tileWidth);
		_rows = Std.int(height / _map.tileHeight);
		_opaqueTiles = opaqueTiles;
		
		_count = _columns * _rows;
		tileSpacingWidth = _map.getTileMapSpacing(layerName);
		tileSpacingHeight = _map.getTileMapSpacing(layerName);

		if (_columns == 0 || _rows == 0)
			throw "Cannot create a bitmapdata of width/height = 0";

		// create the canvas
#if neko
		_maxWidth = 4000 - 4000 % _map.tileWidth;
		_maxHeight = 4000 - 4000 % _map.tileHeight;
#else
		_maxWidth -= _maxWidth % _map.tileWidth;
		_maxHeight -= _maxHeight % _map.tileHeight;
#end

		super(_width, _height);
			
		init();
	}
	// initialize map
	private function init():Void 
	{
		_tile = new Rectangle(0, 0, _map.tileWidth, _map.tileHeight);
		_tileGrids = new Array<Array<Int>>();
		for (y in 0..._rows)
		{
			_tileGrids[y] = new Array<Int>();
			for (x in 0..._columns)
			{
				_tileGrids[y][x] = -1;
			}
		}
	}
	
	override public function destroy():Void 
	{
		_map = null;
		_tileGrids = null;
	}
	/**
	 * Sets the index of the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @param	index		Tile index.
	 */
	public function setTile(column:Int, row:Int, index:Int = 0)
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}
		//index %= _count;
		//column %= _columns;
		//row %= _rows;
		_tileGrids[row][column] = index;
		
		if (blit)
		{
			if(_opaqueTiles == false || index < 0)
			{
				_tile.x = column * _tile.width;
				_tile.y = row * _tile.height;
				fill(_tile, 0, 0); // erase tile
			}
			if(index >= 0)
			{
				updateTileRect(index);
				var tileset:TmxTileSet = _map.getGidOwner(index);
				if (tileset != null)
					draw(column * _tile.width, row * _tile.height, tileset.image, _tile);
			}
		}else {
			var tileSet:TmxTileSet = _map.getGidOwner(index);
			if (tileSet != null) {
				var data:AtlasData = AtlasData.getAtlasDataByName(tileSet.imageSource, true);
				data.blend = AtlasData.BLEND_NONE;
				data.alpha = false;
				data.rgb = false;
				atlas.set(index, data.createRegion(tileSet.getRect(index - tileSet.firstGID)));
			}
		}
		
	}

	/**
	 * Clears the tile at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 */
	public function clearTile(column:Int, row:Int)
	{
		setTile(column, row, -1);
	}

	/**
	 * Gets the tile index at the position.
	 * @param	column		Tile column.
	 * @param	row			Tile row.
	 * @return	The tile index.
	 */
	public function getTile(column:Int, row:Int):Int
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
		}
		return _tileGrids[row % _rows][column % _columns];
	}

	/**
	 * Sets a rectangular region of tiles to the index.
	 * @param	column		First tile column.
	 * @param	row			First tile row.
	 * @param	width		Width in tiles.
	 * @param	height		Height in tiles.
	 * @param	index		Tile index.
	 */
	public function setRect(column:Int, row:Int, width:Int = 1, height:Int = 1, index:Int = 0)
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
			width = Std.int(width / _tile.width);
			height = Std.int(height / _tile.height);
		}
		column %= _columns;
		row %= _rows;
		var c:Int = column,
			r:Int = column + width,
			b:Int = row + height,
			u:Bool = usePositions;
		usePositions = false;
		while (row < b)
		{
			while (column < r)
			{
				setTile(column, row, index);
				column ++;
			}
			column = c;
			row ++;
		}
		usePositions = u;
	}

	/**
	 * Clears the rectangular region of tiles.
	 * @param	column		First tile column.
	 * @param	row			First tile row.
	 * @param	width		Width in tiles.
	 * @param	height		Height in tiles.
	 */
	public function clearRect(column:Int, row:Int, width:Int = 1, height:Int = 1)
	{
		if (usePositions)
		{
			column = Std.int(column / _tile.width);
			row = Std.int(row / _tile.height);
			width = Std.int(width / _tile.width);
			height = Std.int(height / _tile.height);
		}
		column %= _columns;
		row %= _rows;
		var c:Int = column,
			r:Int = column + width,
			b:Int = row + height,
			u:Bool = usePositions;
		usePositions = false;
		while (row < b)
		{
			while (column < r)
			{
				clearTile(column, row);
				column ++;
			}
			column = c;
			row ++;
		}
		usePositions = u;
	}

	/**
	 * Set the tiles from an array.
	 * The array must be of the same size as the Tilemap.
	 *
	 * @param	array	The array to load from.
	 */
	public function loadFrom2DArray(array:Array<Array<Int>>):Void
	{
		if (blit)
		{
			for (y in 0...array.length)
			 {
				for (x in 0...array[0].length)
				{
					setTile(x, y, array[y][x]);
				}
			 }
		}
		_tileGrids = array;
	}

	/**
	* Loads the Tilemap tile index data from a string.
	* The implicit array should not be bigger than the Tilemap.
	* @param str			The string data, which is a set of tile values separated by the columnSep and rowSep strings.
	* @param columnSep		The string that separates each tile value on a row, default is ",".
	* @param rowSep			The string that separates each row of tiles, default is "\n".
	*/
	public function loadFromString(str:String, columnSep:String = ",", rowSep:String = "\n")
	{
		var row:Array<String> = str.split(rowSep),
			rows:Int = row.length,
			col:Array<String>, cols:Int, x:Int, y:Int;
		for (y in 0...rows)
		{
			if (row[y] == '') continue;
			col = row[y].split(columnSep);
			cols = col.length;
			for (x in 0...cols)
			{
				if (col[x] == '') continue;

				//if (blit)
					setTile(x, y, Std.parseInt(col[x]));
				//_tileGrids[y][x] = Std.parseInt(col[x]);
			}
		}
	}

	/**
	* Saves the Tilemap tile index data to a string.
	* @param columnSep		The string that separates each tile value on a row, default is ",".
	* @param rowSep			The string that separates each row of tiles, default is "\n".
	*
	* @return	The string version of the array.
	*/
	public function saveToString(columnSep:String = ",", rowSep:String = "\n"): String
	{
		var s:String = '',
			x:Int, y:Int;
		for (y in 0..._rows)
		{
			for (x in 0..._columns)
			{
				s += Std.string(getTile(x, y));
				if (x != _columns - 1) s += columnSep;
			}
			if (y != _rows - 1) s += rowSep;
		}
		return s;
	}

	/**
	 * Gets the index of a tile, based on its column and row in the tileset.
	 * @param	tilesColumn		Tileset column.
	 * @param	tilesRow		Tileset row.
	 * @return	Index of the tile.
	 */
	public inline function getIndex(tilesColumn:Int, tilesRow:Int):Int
	{
		return (tilesRow % _rows) * _columns + (tilesColumn % _columns);
	}

	/**
	 * Shifts all the tiles in the tilemap.
	 * @param	columns		Horizontal shift.
	 * @param	rows		Vertical shift.
	 * @param	wrap		If tiles shifted off the canvas should wrap around to the other side.
	 */
	public function shiftTiles(columns:Int, rows:Int, wrap:Bool = false)
	{
		if (usePositions)
		{
			columns = Std.int(columns / _tile.width);
			rows = Std.int(rows / _tile.height);
		}

		if (columns != 0)
		{
			for (y in 0..._rows)
			{
				var row = _tileGrids[y];
				if (columns > 0)
				{
					for (x in 0...columns)
					{
						var tile:Int = row.pop();
						if (wrap) row.unshift(tile);
					}
				}
				else
				{
					for (x in 0...Std.int(Math.abs(columns)))
					{
						var tile:Int = row.shift();
						if (wrap) row.push(tile);
					}
				}
			}
			_columns = _tileGrids[Std.int(y)].length;

#if flash
			shift(Std.int(columns * _tile.width), 0);
			_rect.x = columns > 0 ? 0 : _columns + columns;
			_rect.y = 0;
			_rect.width = Math.abs(columns);
			_rect.height = _rows;
			updateRect(_rect, !wrap);
#end
		}

		if (rows != 0)
		{
			if (rows > 0)
			{
				for (y in 0...rows)
				{
					var row:Array<Int> = _tileGrids.pop();
					if (wrap) _tileGrids.unshift(row);
				}
			}
			else
			{
				for (y in 0...Std.int(Math.abs(rows)))
				{
					var row:Array<Int> = _tileGrids.shift();
					if (wrap) _tileGrids.push(row);
				}
			}
			_rows = _tileGrids.length;

#if flash
			shift(0, Std.int(rows * _tile.height));
			_rect.x = 0;
			_rect.y = rows > 0 ? 0 : _rows + rows;
			_rect.width = _columns;
			_rect.height = Math.abs(rows);
			updateRect(_rect, !wrap);
#end
		}
	}

	/** @private Used by shiftTiles to update a rectangle of tiles from the tilemap. */
	private function updateRect(rect:Rectangle, clear:Bool)
	{
		var x:Int = Std.int(rect.x),
			y:Int = Std.int(rect.y),
			w:Int = Std.int(x + rect.width),
			h:Int = Std.int(y + rect.height),
			u:Bool = usePositions;
		usePositions = false;
		if (clear)
		{
			while (y < h)
			{
				while (x < w) clearTile(x ++, y);
				x = Std.int(rect.x);
				y ++;
			}
		}
		else
		{
			while (y < h)
			{
				while (x < w) updateTile(x ++, y);
				x = Std.int(rect.x);
				y ++;
			}
		}
		usePositions = u;
	}

	@:dox(hide)
	override public function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		// determine drawing location
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		var scalex:Float = HXP.screen.fullScaleX,
			scaley:Float = HXP.screen.fullScaleY,
			tw:Int = Std.int(tileWidth),
			th:Int = Std.int(tileHeight);

		var scx = scale * scaleX,
			scy = scale * scaleY;

		// determine start and end tiles to draw (optimization)
		var startx = Math.floor( -_point.x / (tw * scx)),
			starty = Math.floor( -_point.y / (th * scy)),
			destx = startx + 1 + Math.ceil(HXP.width / (tw * scx)),
			desty = starty + 1 + Math.ceil(HXP.height / (th * scy));

		// nothing will render if we're completely off screen
		if (startx > _columns || starty > _rows || destx < 0 || desty < 0)
			return;

		// clamp values to boundaries
		if (startx < 0) startx = 0;
		if (destx > _columns) destx = _columns;
		if (starty < 0) starty = 0;
		if (desty > _rows) desty = _rows;

		var wx:Float, sx:Float = (_point.x + startx * tw * scx) * scalex,
			wy:Float = (_point.y + starty * th * scy) * scaley,
			stepx:Float = tw * scx * scalex,
			stepy:Float = th * scy * scaley,
			gid:Int = 0;
		
		//var gidList:Array<Int> = [];
		var tileSet:TmxTileSet;
		for (y in starty...desty)
		{
			wx = sx;
			// ensure no vertical overlap between this and next tile
			scy = (Math.floor(wy+stepy) - Math.floor(wy)) / tileHeight;
			for (x in startx...destx)
			{
				gid = _tileGrids[y % _rows][x % _columns];
				if (gid >= 0)
				{
					
					// ensure no horizontal overlap between this and next tile
					scx = (Math.floor(wx + stepx) - Math.floor(wx)) / tileWidth;
					//gidList.push(gid);
					//if (Lambda.has(_renderList, gid))
						//continue;
					var regoin = atlas.get(gid);
					if (regoin != null){
						regoin.draw(Math.floor(wx), Math.floor(wy), layer, scx, scy, 0, _red, _green, _blue, alpha, smooth);
					}
					//tileSet = _map.getGidOwner(gid);
					/*
					if (tileSet != null)
					{
						var tile:Int = gid - tileSet.firstGID;
						
						_tile.x = tileSet.getRect(tile).x;
						_tile.y = tileSet.getRect(tile).y;
						//updateTileRect(tile);
						//TODO rectangle 矩形设定
						//tileSet.atlas.prepareTile(tile - tileSet.firstGID, Math.floor(wx), Math.floor(wy), layer, scx, scy, 0, _red, _green, _blue, alpha, smooth);
						DC.beginProfile("renderer");
						var data = AtlasData.getAtlasDataByName(tileSet.imageSource, true);
						data.blend = AtlasData.BLEND_NONE;
						data.alpha = false;
						data.prepareTile(_tile, Math.floor(wx), Math.floor(wy), layer, scx, scy, 0, _red, _green, _blue, alpha, false);
						
						//_atlas.prepareTile(_tile, Math.floor(wx), Math.floor(wy), layer, scx, scy, 0, _red, _green, _blue, alpha, smooth);
						DC.endProfile("renderer");
						//var tileatlas:TileAtlas = TiledRenderer.atlas.get(tileSet.firstGID);
						//if (tileatlas == null) throw "tileatlas is null";
						//tileatlas.prepareTile(_tile, Math.floor(wx), Math.floor(wy), layer, scx, scy, 0, _red, _green, _blue, alpha, smooth);
						//tileatlas.getRegion(tile).draw(Math.floor(wx), Math.floor(wy), layer, scx, scy, 0, _red, _green, _blue, alpha, smooth);
						//tileSet.atlas.getRegion(tile).draw(Math.floor(wx), Math.floor(wy), layer, scx, scy, 0, _red, _green, _blue, alpha, smooth);
						
					}
					*/
				}
				wx += stepx;
			}
			wy += stepy;
		}
		//_renderList = gidList;
	}
	/**
	 * Create a Grid object from this tilemap.
	 * @param solidTiles	Array of tile indexes that should be solid.
	 * @param grid			A grid to use instead of creating a new one, the function won't check if the grid is of correct dimension.
	 * @return The grid with a tile solid if the tile index is in [solidTiles].
	*/
	public function createGrid(solidTiles:Array<Int>, ?grid:Grid)
	{
		if (grid == null)
		{
			grid = new Grid(width, height, Std.int(_tile.width), Std.int(_tile.height));
		}
		
		for (y in 0..._rows)
		{
			for (x in 0..._columns)
			{
				if (solidTiles.indexOf(getTile(x, y)) != -1)
				{
					grid.setTile(x, y, true);
				}
			}
		}
		
		return grid;
	}
	/** @private Sets the _tile convenience rect to the x/y position of the supplied tile. Assumes _tile has the correct tile width/height set. Respects tile spacing. */
	private inline function updateTileRect(index:Int)
	{
		_tile.x = (index % _columns) * (_tile.width + tileSpacingWidth);
		_tile.y = Std.int(index / _columns) * (_tile.height + tileSpacingHeight);
	}
	
	/** @private Used by shiftTiles to update a tile from the tilemap. */
	private function updateTile(column:Int, row:Int)
	{
		setTile(column, row, _tileGrids[row % _rows][column % _columns]);
	}

	/**
	 * The tile width.
	 */
	public var tileWidth(get, never):Int;
	private inline function get_tileWidth():Int { return Std.int(_tile.width); }

	/**
	 * The tile height.
	 */
	public var tileHeight(get, never):Int;
	private inline function get_tileHeight():Int { return Std.int(_tile.height); }

	/**
	 * The tile horizontal spacing of tile.
	 */
	public var tileSpacingWidth(default, null):Int;

	/**
	 * The tile vertical spacing of tile.
	 */
	public var tileSpacingHeight(default, null):Int;

	/**
	 * How many tiles the tilemap has.
	 */
	public var tileCount(get, never):Int;
	private inline function get_tileCount():Int { return _count; }

	/**
	 * How many columns the tilemap has.
	 */
	public var columns(get, null):Int;
	private inline function get_columns():Int { return _columns; }

	/**
	 * How many rows the tilemap has.
	 */
	public var rows(get, null):Int;
	private inline function get_rows():Int { return _rows; }

	public var smooth:Bool = true;

	// Tilemap information.
	private var _tileGrids:Array<Array<Int>>;
	private var _columns:Int;
	private var _rows:Int;

	// Tileset information.
	private var _map:TmxMap;
	private var _count:Int;
	private var _tile:Rectangle;
	private var _opaqueTiles:Bool;
}
