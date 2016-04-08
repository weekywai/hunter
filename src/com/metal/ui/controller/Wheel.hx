package com.metal.ui.controller;
import openfl.geom.Point;
import de.polygonal.core.sys.IDisposer;

using com.metal.enums.Direction;
/**
 * 方向逻辑
 * @author weeky
 */
class Wheel implements IDisposer
{
	public var cPoint:Point;
	private var _status:Direction;
	
	public function new() 
	{
		_status = NONE;
		cPoint = new Point();
	}
	
	public var isDisposed(default, null) : Bool;
	/**
	 * 删除方法
	 */	
	public function dispose() : Void{
		cPoint = null;
		_status = null;
	}
	
	public function ccpSub(point1:Point, point2:Point):Point
	{
		var result:Point = new Point((point1.x - point2.x), (point1.y - point2.y));
		return result;
	}
	
	public function ccpNormalize(point1:Point):Point
	{
		var originPoint:Point = new Point(0, 0);
		var result:Point;
		var dis:Float = Point.distance(point1, originPoint);
		if (dis == 0)
		{
			return (new Point(1.0, 0));
		}
		else
		{
			var x = point1.x / dis;
			var y = point1.y / dis;
			result = new Point(x, y);
			return result;
		}
	}
	
	public function ccpMult(point1:Point, num:Float):Point
	{
		var result:Point;
		var x = point1.x * num;
		var y = point1.y * num;
		result = new Point(x, y);
		return result;
	}
	
	public function ccpAdd(point1:Point, point2:Point):Point
	{
		var result:Point;
		var x = point1.x + point2.x;
		var y = point1.y + point2.y;
		result = new Point(x, y);
		return result;
	}
	
	public function setDirection(point:Point):Direction
	{
		
		if (point.y == cPoint.y && point.x == cPoint.x)
		{
			if (_status != NONE)
			{
				//_controlTime = Timebase.stamp();
				_status = NONE;
				//_player.notify(MsgInput.UIJoystickInput, status);
			}
		}
		else
		{
			var realPos:Point = new Point(point.x - cPoint.x, point.y - cPoint.y);
			realPos.y = realPos.y * ( -1);
			//按键区域：左、右
			if (realPos.x >= 0)
			{
				_status = RIGHT;
			}
			else if (realPos.x < 0)
			{
				_status = LEFT;
			}
			//_player.notify(MsgInput.UIJoystickInput, status);
		}
		return _status;
	}
	
}