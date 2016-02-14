package com.metal.scene.solids;

import com.haxepunk.HXP;
import com.haxepunk.masks.Polygon;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import com.haxepunk.graphics.Image;
import com.haxepunk.Mask;
import com.haxepunk.masks.Pixelmask;
/**
 * ...
 * @author Noel Berry
 */
class Slope extends Solid
{
	public var slopeMask:Pixelmask;

	public function new(x:Int, y:Int, type:Int) 
	{
		super(x, y, 0, 0);
		
		/*var poly:Polygon = new Polygon([new Point(0, 0), new Point(32, 0), new Point(32, 32), new Point(0, 32)]);
		switch(type) {
			case 0: poly = new Polygon([new Point(0, 33), new Point(32, 0), new Point(32, 32)]);
			case 1: poly = new Polygon([new Point(0, 0), new Point(32, 33), new Point(0, 32)]);
			case 2: poly = new Polygon([new Point(0, 0), new Point(32, 0), new Point(32, 32)]);
			case 3: poly = new Polygon([new Point(0, 0), new Point(32, 0), new Point(0, 32)]);
		}
		mask = poly;*/
		//hide us - we don't need to ever be updated
		active = false;
		visible = false;
	}
}