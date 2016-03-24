package com.metal.utils.effect.component;
import com.metal.manager.UIManager;
import com.metal.message.MsgInput;
import com.metal.utils.effect.component.assistClass.TriangleSp;
import motion.Actuate;
import openfl.display.Sprite;
import openfl.Lib;

/**
 * 界面打开效果
 * @author 3D
 */
class EffectOpen extends BaseEffect
{

	public function new(target:Dynamic=null, params:Dynamic=null,src:String = "")
	{
		super(target, params, src);
		var screenW:Float = Lib.current.stage.stageWidth/1;
		var screenH:Float = Lib.current.stage.stageHeight / 2;
		
		upSprite.graphics.beginFill(0x000000);
		upSprite.graphics.drawRect(0, 0, screenW, screenH);
		upSprite.graphics.endFill();
		
		downSprite.graphics.beginFill(0x000000);
		downSprite.graphics.drawRect(0, 0, screenW, screenH);
		downSprite.graphics.endFill();
		
		//基础的三角形
		var r:UInt = 100;
		var num:UInt = Std.int(Lib.current.stage.stageWidth / r) + 2;
		var tempSp:TriangleSp = new TriangleSp(r, 60);
		triangleH = tempSp.height;
		var keyT:Bool;
		for (key in 0...2) {
			keyT = key == 0;//先上面 三角是向下的 
			for (n in 0...num) {
				tempSp = new TriangleSp(r, 60, !keyT);
				if (keyT) {
					tempSp.x = n * tempSp.width;
					tempSp.y = Lib.current.stage.stageHeight / 2;
					upSprite.addChild(tempSp);
				}else {
					tempSp.x = (n-0.5) * tempSp.width;
					downSprite.addChild(tempSp);
				}
				
			}
		}
	}
	
	private var upSprite:Sprite = new Sprite();
	private var downSprite:Sprite = new Sprite();
	
	private var triangleH:Float;
	
	/**闭合时的时间*/
	public static var closeTime:Float = 0.5;
	
	
	override public function play(endFunc:BaseEffect->Void):Void
	{
		// TODO Auto Generated method stub
		super.play(endFunc);
		//拿到特效层
		cast(GameProcess.UIRoot, UIManager).effLayer.addChild(upSprite);
		cast(GameProcess.UIRoot, UIManager).effLayer.addChild(downSprite);
		
		//调整位置
		upSprite.y = Lib.current.stage.stageHeight/2-upSprite.height;
		downSprite.y = Lib.current.stage.stageHeight / 2;
		GameProcess.NotifyUI(MsgInput.SetInputEnable, false);
		//
		Actuate.tween(upSprite, closeTime*2.3 , {y:-upSprite.height } ).delay(closeTime * 1.5).onComplete(onShowComplete);
		Actuate.tween(downSprite, closeTime*2.3, { y:Lib.current.stage.stageHeight + triangleH }).delay(closeTime * 1.5);
	}
	
	/**
	 *显示完成
	 **/
	private function onShowComplete():Void
	{
		upSprite.parent.removeChild(upSprite);
		upSprite.removeChildren();
		upSprite = null;
		downSprite.parent.removeChild(downSprite);
		downSprite.removeChildren();
		downSprite = null;
		GameProcess.NotifyUI(MsgInput.SetInputEnable, true);
		finish();
	}
}