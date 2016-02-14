package com.metal.utils;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.BasePanel;
import ru.stablex.ui.widgets.Bmp;

/**
 * 面板工具
 * @author 3D
 */
class PanelUtil
{

	public function new() 
	{
		
	}
	
	/**
	 *  功能:返回一个面板的Bmp
	 *  参数:
	 **/
	public static function getPanelBitmap(panel:DisplayObject):Bmp
	{
		var bmd:BitmapData = new BitmapData(Std.int(panel.width),Std.int(panel.height),true,0x00000000);
		var matrix:Matrix = new Matrix();
		var rect:Rectangle = panel.getBounds(null);
		matrix.tx = -rect.left;
		matrix.ty = -rect.top;
		bmd.draw(panel, matrix);
		var bm:Bmp;
		bm = UIBuilder.create(Bmp, {
			bitmapData : bmd
		});
		return bm;
	}
	
}