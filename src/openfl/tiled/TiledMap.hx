// Copyright (C) 2013 Christopher "Kasoki" Kaster
//
// This file is part of "openfl-tiled". <http://github.com/Kasoki/openfl-tiled>
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
package openfl.tiled;

import com.haxepunk.HXP;
import com.haxepunk.tmx.TmxMap;
import com.haxepunk.tmx.TmxTileSet;
import com.metal.enums.RunVo;
import haxe.ds.IntMap;
import motion.Actuate;
import motion.easing.Linear;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
//import tweenx909.EaseX;
//import tweenx909.TweenX;



/**
 * This class represents a TILED map
 * @author Christopher Kaster
 */
class TiledMap extends Sprite {
	private var tilesheets:Map<Int, Tilesheet>;
	private var _map:TmxMap;
	private var _rollList:Array <Shape>;
	private var _rollMap:Bool = false;
	private var horizon:Int = 0x80000000;
	private var verticsl:Int = 0x40000000;
	//private function new(path:String, ?map) {
	public function new(path:String, map:TmxMap = null, roll:Bool = false ) {
		super();
		this._map = map;
		_rollMap = roll;
		this.tilesheets = new Map<Int, Tilesheet>();
		
		scaleX = HXP.screen.fullScaleX;
		scaleY = HXP.screen.fullScaleY;
		//trace(HXP.screen.fullScaleX + ">>" + HXP.screen.fullScaleY);
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}

	// onAddedToStage for non-flash targets
	private function onAddedToStage(e:Event) {
		this.graphics.clear();
		loadTmx();
	}

	
	private function loadTmx():Void {
		for (tileset in _map.tilesets) {
			//trace(tileset.imageSource);
			this.tilesheets.set(tileset.firstGID, new Tilesheet(HXP.getBitmap(tileset.imageSource)));
		}
		_rollList = [];
		var shape:Shape = null;
		for (layer in _map.layers) {
			if (layer.name == "floor") continue;
			//if (layer.name != "Middle_2_3") continue;
			var drawLayer:IntMap<Array<Float>> = new IntMap();
			var drawList:Array<Float> = new Array<Float>();
			var num:Int = _rollMap?2:1;
			
			for(y in 0...layer.height) {
				for (x in 0...layer.width*num) {
					var nextGID = layer.tileGIDs[y][x % layer.width];

					if (nextGID < 0) continue;
					var point:Point = new Point(x * _map.tileWidth, y * _map.tileHeight);
					
					var tileset:TmxTileSet = _map.getGidOwner(nextGID);
					if (tileset == null) continue;
						//trace(layer.name + ">>"+nextGID);
					var tilesheet:Tilesheet = this.tilesheets.get(tileset.firstGID);

					var rect:Rectangle = tileset.getRect(nextGID - tileset.firstGID);
					
					var tileId:Int = this.tilesheets.get(tileset.firstGID).addTileRect(rect);
					
					if (drawLayer.exists(tileset.firstGID)){
						drawList = drawLayer.get(tileset.firstGID);
					}else {
						drawList = [];
						drawLayer.set(tileset.firstGID, drawList);
					}	
					 //add coordinates to draw list					
					var status = layer.status[y][x % layer.width];	
					var matrix:Matrix = new Matrix();
				
						switch (status) 
						{						
							//顺时针旋转90度
							case -6:
								// add coordinates to draw list
								drawList.push(point.x+_map.tileWidth); // x coord
								drawList.push(point.y); // y coord
								drawList.push(tileId); // tile id						
								matrix.rotate(Math.PI/2);
								
								
							//顺时针旋转180度
							case -4:
								drawList.push(point.x+_map.tileWidth); // x coord
								drawList.push(point.y+_map.tileHeight); // y coord
								drawList.push(tileId); // tile id								
								matrix.rotate(Math.PI);
								
							//顺时针旋转270度	
							case 6:
								drawList.push(point.x); // x coord
								drawList.push(point.y+_map.tileHeight); // y coord
								drawList.push(tileId); // tile id							
								matrix.rotate(Math.PI/2*3);
								
							//水平翻转
							case -8:								
								drawList.push(point.x+_map.tileWidth); // x coord
								drawList.push(point.y); // y coord
								drawList.push(tileId); // tile id							
								matrix.a = -1;
								matrix.b = 0;
								matrix.c = 0;
								matrix.d = 1;
								
							//垂直翻转
							case 4:
								drawList.push(point.x); // x coord
								drawList.push(point.y+_map.tileHeight); // y coord
								drawList.push(tileId); // tile id			
								matrix.a = 1;
								matrix.b = 0;
								matrix.c = 0;
								matrix.d = -1;			
								
							//水平镜面后顺时针旋转90度
							case -2:
								drawList.push(point.x+_map.tileWidth); // x coord
								drawList.push(point.y+_map.tileHeight); // y coord
								drawList.push(tileId); // tile id			
								matrix.a = 0;
								matrix.b = -1;
								matrix.c = -1;
								matrix.d = 0;		
								
							//水平镜面后顺时针旋转270度
							case 2:
								drawList.push(point.x); // x coord
								drawList.push(point.y); // y coord
								drawList.push(tileId); // tile id			
								matrix.a = 0;
								matrix.b = 1;
								matrix.c = 1;
								matrix.d = 0;									

							default:
								drawList.push(point.x); // x coord
								drawList.push(point.y); // y coord
								drawList.push(tileId); // tile id									
						}	
					drawList.push(matrix.a);
					drawList.push(matrix.b);
					drawList.push(matrix.c);
					drawList.push(matrix.d);
				}
			}		
			shape = new Shape();
			addChild(shape);
			_rollList.push(shape);
			
			// draw layer
			for (firstGID in drawLayer.keys()) {
				var tilesheet:Tilesheet = this.tilesheets.get(firstGID);
				var drawTileList:Array<Float> = drawLayer.get(firstGID);
				tilesheet.drawTiles(shape.graphics, drawTileList, false, Tilesheet.TILE_TRANS_2x2);				
			}				
		}
		//test(tilesheets.get(4399));
	}
	private function test(tilesheet:Tilesheet)
	{
		var tileId = tilesheet.addTileRect(new Rectangle(0,0,200,200)); 
		var dlist:Array<Float> = [];
		dlist.push(1.0); // x coord
		dlist.push(1.0); // y coord
		dlist.push(tileId); // tile id
		//dlist.push(1.0); 
		//tilesheet.drawTiles(this.graphics, dlist, true);
		tilesheet.drawTiles(_rollList[0].graphics, dlist, true);
	}
	public function startRoll(data:IntMap<RunVo>)
	{
		var i = 0;// _rollList.length;
		for(shape in _rollList)
		{
			//i--;
			if (data.get(i).runSpeed == 0) continue;
			Actuate.tween(shape, data.get(i).runSpeed, { x: -_map.fullWidth } ).repeat().ease(Linear.easeNone);
			i++;
		}
	}
	
	public function dispose()
	{
		parent.removeChild(this);
		_map = null;
		for(shape in _rollList)
		{
			Actuate.stop(shape);
			removeChild(shape);
		}
		tilesheets = null;
		_rollList = null;
	}
}
