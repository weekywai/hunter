package com.metal.utils.effect.component;
import com.haxepunk.utils.Ease;
import openfl.Lib;
import motion.Actuate;
import ru.stablex.ui.widgets.Widget;

/**
 * 右侧进场效果
 * @author 3D
 */
class EffectRightIn extends BaseEffect
{

	public function new(target:Dynamic=null, params:Dynamic=null, res:String="") 
	{
		super(target, params, res);
		
	}
	
	override public function play(endFunc:BaseEffect->Void):Void
	{
		super.play(endFunc);
		Actuate.tween(cast(target, Widget), 0.8, {left:Lib.current.stage.stageWidth - this.param }).onComplete( tweenEnd );
		
	}
	
	/***/
	public function tweenEnd():Void {
		
	}
	
}