package com.metal.utils.effect.component;
import openfl.display.Sprite;
import openfl.Lib;
import motion.Actuate;

/**
 * 白色闪屏
 * @author 3D
 */
class EffectLights extends BaseEffect
{

	public function new(target:Dynamic=null, params:Dynamic=null, res:String="") 
	{
			super(target, params, res);
		
		var screenW:Float = Lib.current.stage.stageWidth;
		var screenH:Float = Lib.current.stage.stageHeight;
		maxSprite = new Sprite();
		maxSprite.graphics.beginFill(0xffffff);//ffffff
		maxSprite.graphics.drawRect(0, 0, screenW, screenH);
		maxSprite.graphics.endFill();
		maxSprite.alpha = 0;
	}
	
	private var maxSprite:Sprite = new Sprite();
	
	private var triangleH:Float;
	
	/**闪烁的时间*/
	public static var lightsTime:Float = 0.15;
	
	
	override public function play(endFunc:BaseEffect->Void):Void
	{
		// TODO Auto Generated method stub
		super.play(endFunc);
		
		//var rect:Rectangle = panel.getBounds(null);
		//拿到特效层
		
		//cast(GameProcess.child(UIManager), UIManager).effLayer.addChild(maxSprite);
	
		
		//
		Actuate.tween(maxSprite, lightsTime, {alpha:0.65 } ).onComplete(onShowComplete);
		
		
	}
	
	/**
	 *闭合完成后打开
	 **/
	private function onShowComplete():Void
	{
		Actuate.tween(maxSprite, lightsTime, { alpha:0  });
		//闭合时 通知切换地图 
		finish();
	}
	

	
	override public function finish():Void
	{
		//maxSprite.parent.removeChild(maxSprite);
		super.finish();
		
	}
	
	
	
}