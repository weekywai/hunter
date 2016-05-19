package com.metal.utils.effect.component;
import com.metal.manager.UIManager;
import openfl.display.DisplayObject;
import openfl.Lib;
import motion.Actuate;
import motion.easing.Quad;
import ru.stablex.ui.widgets.Widget;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;

/**
 * 关闭效果
 * @author 3D
 */
class EffectClose extends BaseEffect
{

	public function new(target:Dynamic=null, params:Dynamic=null,src:String = "")
	{
		super(target, params,src);
	}
	
	/**操作按钮**/
	public var operateBtn:DisplayObject;
	
	public var draw:Bmp;
	
	
	override public function play(endFunc:BaseEffect->Void):Void
	{
		// TODO Auto Generated method stub
		super.play(endFunc);
		var panel:Widget = cast target;
		//显示弹窗效果
		draw = UIBuilder.create(Bmp, {
			src:this.back
		});
		//拿到特效层
		cast(GameProcess.instance.findChild(UIManager), UIManager).effLayer.addChild(draw);
		draw.x = Std.int((Lib.current.stage.stageWidth - panel.w)/2);
		draw.y = Std.int((Lib.current.stage.stageHeight - panel.h)/2);
		var temp_x:Int = Std.int((Lib.current.stage.stageWidth / 2));
		var temp_y:Int = Std.int((Lib.current.stage.stageHeight / 2));
		Actuate.tween(draw, 0.25,{ x:temp_x, y:temp_y, scaleX:0.1, scaleY:0.1, alpha:0 }).ease(Quad.easeInOut).onComplete(onShowComplete);
		panel.alpha = 0;
		panel.visible = false;
	}
	
	/**
	 *显示完成
	 **/
	private function onShowComplete():Void
	{
		if (draw != null) {
			//draw.bitmapData.dispose();
			draw.parent.removeChild(draw);
			draw = null;
		}
		finish();
	}
	
	override public function finish():Void
	{
		//TweenLite.killTweensOf(target,true);
		super.finish();
	}
	
	
	
}