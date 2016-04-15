package com.metal.utils;

typedef GeomType = {
	a:Float,
	b:Float,
	c:Float,
	d:Float,
	tx:Float,
	ty:Float,
	x:Float,
	y:Float,
}
/**
 * ...
 * @author tzq
 */
class GeomUtils
{
	/**基准坐标：obj{x,y}
	 * 角度：angle
	 * 锚点：（rotatePointX，rotatePointY）*/
	public static function anchorRotate(obj:Dynamic,angle:Float=0,rotatePointX:Float=0,rotatePointY:Float=0):GeomType
	{
		var o:GeomType = obj;	
		var orginAngle:Float = (rotatePointX == 0 && rotatePointY == 0)? 0:Math.atan(rotatePointY / rotatePointX);
		var hypotenuse:Float = Math.sqrt(rotatePointX * rotatePointX + rotatePointY * rotatePointY);
		var radian:Float = (angle  / 180) * Math.PI;
		o.tx = rotatePointX - hypotenuse * Math.cos(orginAngle+radian);
		o.ty = rotatePointY - hypotenuse * Math.sin(orginAngle+radian);
		o.x += o.tx;
		o.y += o.ty;
		o.a = Math.cos(radian);
		o.b = Math.sin(radian);
		o.c = -Math.sin(radian);
		o.d = Math.cos(radian);	
		return o;		
	}
	
}