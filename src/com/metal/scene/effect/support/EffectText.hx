package com.metal.scene.effect.support;

import com.haxepunk.Entity;
import com.haxepunk.graphics.BitmapText;
import com.haxepunk.HXP;
import com.haxepunk.gui.Label;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.scene.effect.impl.EffectEntity;
import motion.Actuate;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;

/**
 * 数字特效
 * @author weeky
 */
class EffectText extends EffectEntity
{
	//private var _numTxt:BitmapText;
	private var _numTxt:Label;
	private var _h:Float;
	private var _normalTpye = [new GlowFilter(0xFF0000, 1, 5, 5, 5) , new DropShadowFilter(3, 45, 0, 0.8)];
	private var _critTpye = [new GlowFilter(0xCCCC00,1,5,5,5) ,new DropShadowFilter(3,45,0,0.8)];
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
		
	}
	override private function onDispose():Void 
	{
		super.onDispose();
		if(_numTxt!=null)
			HXP.scene.clearRecycled(Type.getClass(_numTxt));
		_numTxt = null;
	}
	
	
	override public function start(req:EffectRequest):Void 
	{
		super.start(req);
		/*
		_numTxt = new BitmapText("0");
		_numTxt.size = 30;
		_numTxt.color = 0xFF0000;
		_numTxt.charSpacing = 1;
		graphic = _numTxt;
		*/
		_numTxt = HXP.scene.create(Label, true);
		//_numTxt.size = 18;
		_numTxt.size = 30;
		_numTxt.color = 0xFF9900;
		//_numTxt.textField.filters = [new DropShadowFilter(3)];
		//_numTxt.textField.filters = [new GlowFilter(0xFF0000,1,6,6,10)];
		_numTxt.textField.filters =_normalTpye;
		//_numTxt.textField.borderColor = 0xffffff;
		_h = 20;
		
		
		//_numTxt.text = "-" + req.text;
		_numTxt.text = req.text;
		x -= req.width * 0.5;
		y -= req.height * 2;
		//trace("req.height: "+req.height);
		_numTxt.x = x;
		_numTxt.y = y;
		if (req.renderType == EffectRequest.Crit) {
			_numTxt.textField.filters = _critTpye;
			Actuate.tween(this, 0.3, { y:y - 25 } );
			Actuate.tween(_numTxt, 0.3, { size:80} ).onComplete(function() {
				if (_numTxt != null) {
					Actuate.tween(_numTxt, 0.5, { size:30} ).onComplete(function() {
						_h = 0;
					});
					Actuate.tween(this, 0.3, { y:y + 25 } );
				}
				
			});
		}else {
			Actuate.tween(_numTxt,0.8,{}).onComplete(function() {
				_h = 0;
			});
		}
		//_numTxt.size *=2;
		//Actuate.tween(_numTxt, 0.5, { size:_numTxt.size>>1} ).onComplete(function() {
			//_h = 0;
		//});
	}
	
	override public function update():Void 
	{
		if (_numTxt == null)
			return;
		super.update();
		//_numTxt.color = (_h % 2 == 0)?0xFF0000:0xFFCC00;
		if (_h <= 0) {
			//alphaTo();
			recycle();
			return;
		}
		
		//if (_numTxt.size <= 18)
			//_numTxt.size = 18;
		//_numTxt.size -= 1;
		//_numTxt.textField.alpha -= 0.1;
		//if (_numTxt.textField.alpha <= 0)
			//_numTxt.textField.alpha = 0;
		//_h--;
		y --;
		_numTxt.x = x;
		_numTxt.y = y;
	}
	
	private function alphaTo():Void 
	{
		_numTxt.textField.alpha -= 0.1;
		if (_numTxt.textField.alpha <= 0)
			_numTxt.textField.alpha = 0;
			recycle();
	}
	
	override function recycle():Void 
	{
		HXP.scene.recycle(_numTxt);
		_numTxt = null;
		super.recycle();
	}
}