package com.metal.unit.avatar;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.tweens.misc.ColorTween;
import com.haxepunk.tweens.TweenEvent;
import com.metal.config.ResPath;
import com.haxepunk.Tween.TweenType;

/**
 * ...
 * @author li
 */
class TexDropAvatar extends MTAvatar
{
	//private var _model:TextrueSpritemap;
	private var _model:Dynamic;
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
	}

	override function onDispose():Void 
	{
		_model.destroy();
		_model = null;
	}
	
	override public function update():Void {
		//if(_model!=null)
			//_model.color = _colorT.color;
		//super.update();
	}
	
	//override function createAvatar(name:String, type:String):Dynamic 
	//{
		//var _model:TextrueSpritemap;
		//var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getModelXML(type, name));
		//_model = new TextrueSpritemap(eff);
		//_model.add("drop", eff.getReginCount(), 14);
		//_model.animationEnd.add(onComplete);
		//_model.centerOrigin();
		//graphic = _model;
		//_model.play("drop");
		//
		//setHitbox(_model.width, _model.height);// , Std.int(_model.width / 2), Std.int(_model.height / 2));
		//return _model;
	//}
	
	override function createAvatar(name:String, type:String):Dynamic 
	{
		var fileName = name.substring(0, name.length - 4);
		var fileType = name.substr(name.length - 4);
		//trace(fileName+">>" + fileType);
		var res = ResPath.getIconPath(fileName, "", fileType);
		if (fileType == ".xml"){
			var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(res);
			_model = new TextrueSpritemap(eff);
			_model.add("drop", eff.getReginCount(), 14);
			_model.animationEnd.add(onComplete);
			_model.centerOrigin();
			_model.play("drop");
		}else if (fileType == ".png") {
			_model = new Image(res);
		}
		//trace(_model);
		graphic = _model;
		setHitbox(_model.width, _model.height);// , Std.int(_model.width / 2), Std.int(_model.height / 2));
		//changeColor();
		return _model;
	}
	
	private function onComplete(name:String):Void
	{
		//recycle();
		//scene.remove(this);
	}
	
	override private function initTexture():Void
	{
		_model = createAvatar(_info.res,owner.name);
	}
	
	override private function set_flip(value:Bool):Bool
	{
		_model.flipped = value;
		return value;
	}
	
	override private function get_color():Int
	{
		if (_model == null)
			return 0;
		return _model.color;
	}
	
	override private function set_color(value:Int):Int
	{
		return _model.color = value;
	}
	
	override public function setCallback(fun:Dynamic) 
	{
		//super.setCallback(fun);
	}
	override function changeColor():Void 
	{
		_colorT = new ColorTween(completeTween, TweenType.Persist);
		_colorT.tween(0.5, _model.color, _model.color, 1, 0.5);
		//_colorT.addEventListener(TweenEvent.FINISH, completeTween);
		_colorT.cancel();
		addTween(_colorT);
	}
	override function completeTween(e):Void 
	{
		trace("completeTween");
		_colorT.alpha = 1;
		_colorT.start();
		//_colorT.tween(0.5, _model.color, _model.color, 0.5, 1);
	}
}