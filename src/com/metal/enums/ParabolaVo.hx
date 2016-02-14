package com.metal.enums;
import openfl.geom.Point;

/**
 * 抛物线数据
 * @author 3D
 */
class ParabolaVo
{

	public function new() 
	{
		
	}
	
	
	/**运动轨迹辅助参数**/
	public var x:Float;
	public var y:Float;
	public var xSpeed:Float;
	public var ySpeed:Float;
	public var t0:Float = 0;//x轴
	public var t1:Float = 30;//y轴
	public var g:Float = 0.8;//重力加速度
	public var angel:Float = 0;
	public var dirKey:Bool;//默认向右
	public var parabola:Int;//抛物线
	public var fightPoint:Point;//丢出去的x,y
	
	public function initRunInfo():Void {
		//根据朝向
		var dir:Bool = Math.random() * 100 >= 50;
		var pos:Point = new Point((dir?this.x + (Math.random()*50):this.x -Math.random()*50),
			y);
		xSpeed = (pos.x - this.x) / t1;
		ySpeed = (((pos.y - this.y) - ((g * t1) * (t1 / 2))) / t1);
		fightPoint = new Point(x, y);
	}
	
}