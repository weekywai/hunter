package com.metal.scene.board.view;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.HXP;
import com.haxepunk.Mask;
import de.polygonal.core.sys.IDisposer;
import openfl.geom.Point;

/**
 * ...
 * @author weeky
 */
class ViewDisplay extends Entity implements IDisposer
{
	private var _collideTypes:Array<String>;
	
	public var velocity:Point;
	public var acceleration:Point;
	public var drag:Point;
	public var maxVelocity:Point;
	
	public var onGround:Bool;
	public var onWall:Bool;
	public var isDisposed(default, null) : Bool = false;
	
	public function new(x:Float, y:Float) 
	{
		super(x, y);
		velocity = new Point();
		acceleration = new Point();
		drag = new Point();
		maxVelocity = new Point(10000, 10000);
		_collideTypes = ["solid"];
	}
	
	public function dispose() : Void {
		if (isDisposed)
			return;
		onDispose();
		isDisposed = true;
	}
	private function onDispose():Void
	{
		_collideTypes = null;
		velocity = null;
		acceleration = null;
		drag = null;
		maxVelocity = null;
		if (scene != null)
			scene.remove(this);
	}
	override public function update():Void 
	{
		//if (_collideTypes != null)
		if (isDisposed) return;
		onCheck();
	}
	
	public function hitLeft() {}
	public function hitRight() {}
	public function hitTop() {}
	public function hitBottom() {}
	
	private function onCheck():Void 
	{
		//trace("check");
		var vc:Float, i:Int, e:Entity;

		onWall = false;
		onGround = false;
		
		vc = (compute(velocity.x, acceleration.x, drag.x, maxVelocity.x) - velocity.x) / 2;
		velocity.x += vc;
		var xd:Float = velocity.x * HXP.elapsed;
		velocity.x += vc;

		vc = (compute(velocity.y, acceleration.y, drag.y, maxVelocity.y) - velocity.y) / 2;
		velocity.y += vc;
		var yd:Float = velocity.y * HXP.elapsed;
		velocity.y += vc;
		i = 0;
		if (xd != 0)
		do
		{
			if (collide("solid", x + HXP.sign(xd), y) != null)
			//if ((e = collideTypes(_collideTypes, x + HXP.sign(xd), y)) != null)
			{
				onWall = true;
				velocity.x = 0;
				if (xd < 0)
				{
					hitLeft();
				}
				else
				{
					hitRight();
				}
				break;
			}
			else
			{
				x += HXP.sign(xd);
			}
			i += 1;
		} while (i < Math.abs(xd));

		i = 0;
		if (yd != 0)
		do
		{
			if (collide("solid", x, y + HXP.sign(yd)) != null)
			//if ((e = collideTypes(_collideTypes, x, y + HXP.sign(yd))) != null)
			{
				velocity.y = 0;
				if (yd > 0)
				{
					hitBottom();
					onGround = true;
				}
				else
				{
					hitTop();
				}
				break;
			}else {
				y += HXP.sign(yd);
			}
			i += 1;
		} while (i < Math.abs(yd));
	}
	
	
	public function compute(Velocity:Float, Acceleration:Float = 0, Drag:Float = 0, Max:Float = 10000):Float
	{
		if (Acceleration != 0)
			Velocity += Acceleration * HXP.elapsed;
		else if (Drag != 0)
		{
			var d:Float = Drag * HXP.elapsed;
			if(Velocity - d > 0)
				Velocity = Velocity - d;
			else if(Velocity + d < 0)
				Velocity += d;
			else
				Velocity = 0;
		}
		if ((Velocity != 0) && (Max != 10000))
		{
			if(Velocity > Max)
				Velocity = Max;
			else if(Velocity < -Max)
				Velocity = -Max;
		}
		return Velocity;
	}
}