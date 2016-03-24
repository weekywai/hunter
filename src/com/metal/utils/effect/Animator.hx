package com.metal.utils.effect;
import com.metal.utils.effect.component.BaseEffect;
import com.metal.utils.effect.component.EffectClose;
import com.metal.utils.effect.component.EffectSreenMsg;
//import com.metal.utils.effect.component.EffectCoinFade;
import com.metal.utils.effect.component.EffectInk;
import com.metal.utils.effect.component.EffectLights;
import com.metal.utils.effect.component.EffectOpen;
import com.metal.utils.effect.component.EffectRightIn;
import com.metal.utils.effect.component.EffectRightOut;
import com.metal.utils.effect.component.EffectType;

/**
 * 特效管理
 * @author 3D
 */
class Animator
{

	public function new() 
	{
		
	}
	
	
	private static var effArr:Array<BaseEffect> = [];
	//这个数组保存所有特效的类型EffectRotation
	//private static var effTypeCls:Array = [EffectOpen];
	
	//public static function play(endCall:Function=null,target:Dynamic=null,vars:Dynamic=null):Int{
		//var type:Int = 0;
		//var param:Dynamic = getRandomType();
		//var eff:BaseEffect = param.eff;
		//eff.finishFunc = endCall;
		//eff.target = target;
		//effArr.push(eff);
		//eff.play(onEnd);
		//return param.idx;
	//}
	
	/**
	 *  功能:播放一种特定的效果
	 *  参数:
	 **/
	public static function start(target:Dynamic,res:String,effectType:Int,params:Dynamic=null,overwrite:Bool=true,endCall:Void->Void=null):Void
	{
		if(overwrite){
			killAnimat(target);
		}
		var eff:BaseEffect = new BaseEffect();
		switch(effectType) {
			case EffectType.OPEN://打开效果{
					eff = new EffectOpen(target, params, res);
			case EffectType.CLOSE://关闭效果{
					eff = new EffectClose(target, params, res);
			case EffectType.RIGHT_IN://右侧进场
				    eff = new EffectRightIn(target, params, res);
			case EffectType.RIGHT_OUT://右侧退场
				    eff = new EffectRightOut(target, params, res);
			case EffectType.LIGHTS_SHINY://闪屏效果
					eff = new EffectLights(target, params, res);
			//case EffectType.COIN_FADE:
				    //eff = new EffectCoinFade(target, params, res);
			case EffectType.MESSAGE_FADE:
				    eff = new EffectSreenMsg(target, params, res);
			case EffectType.SCREEN_CLOSE_EAT:
				    eff = new EffectInk(target, params, res);
				
		}
		eff.finishFunc = endCall;
		effArr.push(eff);
		eff.play(onEnd);
	}
	
	
	/**
	 *  功能:取消特效
	 *  参数:
	 **/
	public static function killAnimat(target:Dynamic):Void
	{
		
		var effObj:BaseEffect = new BaseEffect();
		var arr:Array<BaseEffect> = [];
		for (i in 0...effArr.length) {
			effObj = effArr[i];
			if (effObj == null || effObj.target == null)
				return;
			if(effObj.target == target){
				effObj.finish();
				arr.push(effObj);
			}
		}
		for (obj in arr) {
			deleteElm(effObj,effArr);
		}
	}
	/**
	 *结束之后调用 
	 * @param eff
	 */		
	private static function onEnd(eff:BaseEffect):Void{
		deleteElm(eff,effArr);
	}
	
	//private static function getRandomType():Dynamic{
		//var idx:Int = (Math.random()*10000)%effTypeCls.length;
		//var cls:Class = effTypeCls[idx];
		//var obj:BaseEffect = new cls();
		//var param:Dynamic = new Dynamic();
		//Reflect.setField(param, "eff", obj);
		//Reflect.setField(param, "idx", idx);
		//return param;
	//}
	
	public static function deleteElm(res:Dynamic, arr:Array<Dynamic>):Bool {
		var idx:Int = arr.indexOf(res);
		if(idx >= 0){
			arr.splice(idx,1);
			return true;
		}
		return false;
	}
}