package com.metal.scene.effect.support;

import com.haxepunk.Entity;
import com.haxepunk.graphics.BitmapText;
import com.haxepunk.HXP;
import com.haxepunk.gui.Label;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.impl.EffectEntity;
import motion.Actuate;
import motion.easing.Bounce;
import motion.easing.Quad;
import motion.easing.Elastic;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;

/**
 * 数字特效
 * @author weeky
 */
class EffectText extends EffectEntity
{
	private var _bmpTxt:BitmapText;
	private var _color:Int;
	private var _crit:Int;
	//private var _normalTpye = [new GlowFilter(0xFF0000, 1, 5, 5, 5) , new DropShadowFilter(3, 45, 0, 0.8)];
	//private var _critTpye = [new GlowFilter(0xCCCC00,1,5,5,5) ,new DropShadowFilter(3,45,0,0.8)];
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
		
	}
	override private function onDispose():Void 
	{
		if(_bmpTxt!=null)
			_bmpTxt.destroy();
		_bmpTxt = null;
		super.onDispose();
	}
	
	override function onStart(req:EffectRequest):Void 
	{
		x -= req.width * 0.5;
		y -= req.height * 1.5;
		if(_bmpTxt==null){
			_bmpTxt = new BitmapText(req.text);
			_color = _bmpTxt.color;
		}else{
			_bmpTxt.text = req.text;
			_bmpTxt.x = _bmpTxt.y = 0;
			_bmpTxt.color = _color;
			_bmpTxt.alpha = 1;
		}
		_bmpTxt.size = 20;
		_bmpTxt.charSpacing = 1;
		_crit = req.renderType;
		if (_crit == EffectRequest.Crit) {
			_bmpTxt.color = 0xFFFFFF;
			//Actuate.transform (_bmpTxt, 0.4).color (0);
			Actuate.tween(_bmpTxt, 0.4, { size:50 } ).ease (Elastic.easeOut).onUpdate(function() {
				//trace(_bmpTxt.scaleX+"-"+_bmpTxt.scale);
				_bmpTxt.x = -_bmpTxt.textWidth*_bmpTxt.fontScale*0.2;
				_bmpTxt.y = -_bmpTxt.textHeight*_bmpTxt.fontScale*0.4;
			});
			//Actuate.timer(0.5).onComplete (recycle);
			Actuate.tween(_bmpTxt, 0.5, { alpha:0 }, false).delay(0.4).onComplete(recycle);
		}else {
			_bmpTxt.color = 0xFF0000;
			Actuate.timer(0.8).onComplete (recycle);
			//Actuate.tween(_bmpTxt,0.8, {}).onComplete(function() {
				//recycle();
			//});
		}
		addGraphic(_bmpTxt);
	}
	override function recycle():Void 
	{
		removeGraphic(_bmpTxt);
		super.recycle();
	}
	override public function update():Void 
	{
		if (_bmpTxt == null)
			return;
		super.update();
		/*if (_remove) {
			recycle();
			return;
		}*/
		
		if (_crit != EffectRequest.Crit)
			y --;
	}
}