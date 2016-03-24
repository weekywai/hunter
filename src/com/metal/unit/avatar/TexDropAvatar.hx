package com.metal.unit.avatar;
import com.haxepunk.Tween.TweenType;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.tweens.misc.ColorTween;
import com.metal.config.ResPath;

/**
 * ...
 * @author li
 */
class TexDropAvatar extends MTAvatar
{
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
	}
	
	override public function update():Void {
		if(_model!=null)
			_model.color = _colorT.color;
	}
	
	override function createAvatar(name:String, type:String):Dynamic 
	{
		var model:Dynamic = null;
		var fileName = name.substring(0, name.length - 4);
		var fileType = name.substr(name.length - 4);
		//trace(fileName+">>" + fileType);
		var res = ResPath.getIconPath(fileName, "", fileType);
		if (fileType == ".xml"){
			var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(res);
			model = new AttachTexture(eff);
			model.initAttach(onComplete);
		}else if (fileType == ".png") {
			model = new AttachImage(res);
		}
		//trace(_model);
		addGraphic(cast model);
		setHitbox(model.width, model.height);// , Std.int(_model.width / 2), Std.int(_model.height / 2));
		
		//changeColor();
		return model;
	}
	
	private function onComplete(name:String):Void
	{
		//recycle();
		//scene.remove(this);
	}
	
	override private function initTexture():Void
	{
		_model = createAvatar(_info.res, owner.name);
	}
	
	override private function set_flip(value:Bool):Bool
	{
		_model.flip = value;
		return value;
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