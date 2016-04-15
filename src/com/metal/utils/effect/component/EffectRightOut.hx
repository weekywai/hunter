package com.metal.utils.effect.component;
import openfl.Lib;
import motion.Actuate;
import ru.stablex.ui.widgets.Widget;

/**
 * ...
 * @author 3D
 */
class EffectRightOut extends BaseEffect
{

	public function new(target:Dynamic=null, params:Dynamic=null, res:String="") 
	{
		super(target, params, res);
		
	}
	
	override public function play(endFunc:BaseEffect->Void):Void
	{
		super.play(endFunc);
		Actuate.tween(cast(target, Widget), 0.8, {left:Lib.current.stage.stageWidth}).onComplete( tweenEnd );
		
	}
	
	/***/
	public function tweenEnd():Void {
		
	}
	
}