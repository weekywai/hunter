package com.metal.utils;
import openfl.filters.GlowFilter;
import openfl.geom.ColorTransform;
import openfl.filters.DropShadowFilter;
/**
 * 滤镜
 * @author 3D
 */
class Filter
{

	public function new() 
	{
		
	}
	
	
	public static var DARK:DropShadowFilter = null;// new DropShadowFilter();
	
	/**
	 *变暗的颜色 
	 */		
	public static var DARK_CTS:ColorTransform = new ColorTransform(0.5,0.5,0.5,1);
	
	/**
	 *变亮的颜色 
	 */		
	public static var LIGHT_CTS:ColorTransform = new ColorTransform(3.5,3.5,3.5,1);

	public static var TITLE_BLUE:GlowFilter = null;// new GlowFilter(0x085cca, 1, 5, 5, 10);//一般文字描边滤镜蓝色
	public static var TITLE_YELLOW:GlowFilter = null;//new GlowFilter(0x977409, 1, 5, 5, 10);//一般文字描边滤镜黄色
	public static var TITLE_GREEN:GlowFilter = null;//new GlowFilter(0x057916, 1, 5, 5, 10);//一般文字描边滤镜黄色
	public static var TITLE_RED:GlowFilter = new GlowFilter(0xff0000, 1, 5, 5, 10);//一般文字描边滤镜红色
	public static var TITLE_HUI:GlowFilter = new GlowFilter(0x727777, 1, 3, 3, 5);//一般文字描边滤镜灰色
	
}