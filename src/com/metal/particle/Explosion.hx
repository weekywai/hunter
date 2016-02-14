package com.metal.particle;

import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.AtlasRegion;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.HXP;
import com.haxepunk.utils.Ease;
import com.haxepunk.Entity;
import com.particleSystem.ASParticleSystem;
import com.particleSystem.ASParticleSystemNew;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.Lib;
import haxe.Timer;

class Explosion extends Entity
{
	private var image:Stamp;
	
	private var			particleSystem:ASParticleSystem;
	private var particale:ASParticleSystemNew;
	private var			systems:Array<String>;
	private var			currIndex:Int;
	private var         tempA:ASParticleSystem;
	
	private var tempBmpData:BitmapData;
	private var gr:Graphic;
	public static var particleX:Float;
	public static var particleY:Float;
	
	public var debugKey:Bool = true;
	public var errorTimes:Int = 0;
	
	public var pRes:String;
	private static var Root:String = "particles/";
	
	
	public function new(res:String = "aaa")
	{
		super(x, y);
        graphic = gr;
        layer = 500;
		
		debugKey = true;
		pRes = res;
		//init();
		changeParticle(pRes);
		//stopSystem();
	}

	
	private function init():Void
	{
		//tempBmpData = new BitmapData(Lib.current.stage.stageWidth,Lib.current.stage.stageHeight);
		//image = new Stamp(null);
		//graphic = image;
		//测试
		//particleSystem = ASParticleSystem.particleWithFile("boil.plist", "particles/");
		debugKey = true;
		particale = ASParticleSystemNew.particleWithFile(pRes, Explosion.Root);
	}
	
	
	override public function update():Void 
	{
		super.update();
		if (particale == null) return;
		//调用粒子系统的帧事件
		//particleSystem.position = new Point(Lib.current.stage.mouseX, Lib.current.stage.mouseY);
		
		//particleSystem.updateSystemByMyself();
		//updataGraphic(particleSystem.updateSystemByMyself());
		//if (debugKey) {
			//debugKey = false;
			//Timer.delay(init, 1000 * 5);
		//}
		//trace("error in time:"+(errorTimes++));
		//particale.position = new Point(Lib.current.stage.mouseX, Lib.current.stage.mouseY);
		graphic = particale;
	}	
	
	/**更新位置*/
	public function updataPoition(x:Float, y:Float):Void
	{
		particale.position = new Point(x,y);
	}
	
	//public function updataGraphic(sp:ASParticleSystem):Void
	//{
		//var tempBmpData:BitmapData;
		//tempBmpData = new BitmapData(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, true, 0);
		//tempBmpData.draw(sp);
		//////更新了粒子数据
		//if (image == null) {
			////image = new Stamp(tempBmpData);
		//}else {
			//image.updataRegion(tempBmpData);
		//}
		////this.graphic = image;
	//}
	
	/**切换粒子**/
	public function changeParticle(name:String = ""):Void
	{
		particale = ASParticleSystemNew.particleWithFile(name,Explosion.Root);
	}
	
	public function stopSystem():Void
	{
		particale.destroy();
		particale = null;
	}
	
}
