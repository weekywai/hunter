package com.utils;
import openfl.system.Capabilities;

/**
 * ...
 * @author weeky
 */
class SizeableUtil
{

	public function new() 
	{
		
	}
	/**
	 * 英寸转像素
	 */
	public static function inchesToPixels(inches:Float):Int
	{
		return Math.round(Capabilities.screenDPI * inches);
	}
	/**
	 * 磅转像素
	 */
	public static function pointToPixels(point:Float):Int
	{
		//px=1/dpi(英寸)
		//trace(Capabilities.screenDPI);
		return Math.round(point / (point * Capabilities.screenDPI));
	}
	/**
	* Convert millimeters to pixels.
	*/
	public static function mmToPixels(mm:Float):Int
	{
		return Math.round(Capabilities.screenDPI * (mm / 25.4));
	}

}