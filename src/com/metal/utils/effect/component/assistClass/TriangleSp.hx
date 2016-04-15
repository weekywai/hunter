package com.metal.utils.effect.component.assistClass;

import openfl.display.Sprite;

/**
 * 等腰三角形
 * @author 3D
 */
class TriangleSp extends Sprite
{

	public function new(r:Float,ro:Float,pos:Bool = true) 
	{
		super();
		 //已知条件
	   var r:Float=r;
	   var Q:Float=ro*(2*Math.PI/360);//这里得到是弧度，即30度对应的弧度数
	   //画三角形
	   graphics.beginFill(0x000000);
	   graphics.lineStyle(1, 0x000000, 1);
	   graphics.moveTo(0,0);
	   graphics.lineTo(r,0);
	   graphics.lineTo(r*Math.cos(Q),r*Math.sin(Q));
	   graphics.lineTo(0, 0);
	   graphics.endFill();
	   
	   if (pos) {
		   this.scaleY = -1;
		   //this.y = this.height;
	   }
	}
	
	
	
	public function changePos(key:Bool):Void
	{
		this.scaleY = key?-1:1;
		//this.y = key?this.height:0;
	}
	
}