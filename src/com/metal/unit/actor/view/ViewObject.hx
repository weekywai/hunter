package com.metal.unit.actor.view;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.config.ResPath;
import com.metal.unit.avatar.AttachImage;
import com.metal.unit.avatar.AttachTexture;
import com.metal.unit.avatar.IAttach;

/**
 * ...
 * @author weeky
 */
class ViewObject extends ViewBase
{

	public function new() 
	{
		super();
		
	}
	override public function update():Void {
		//setHitboxTo(_model);
		//if(_model!=null)
			//_model.color = _colorT.color;
	}
	
	override function createAvatar(name:String, type:String):Dynamic 
	{
		var fileName = name.substring(0, name.length - 4);
		var fileType = name.substr(name.length - 4);
		var res = ResPath.getIconPath(fileName, "", fileType);
		var model:Dynamic = null;
		switch(fileType) {
			case ".xml":
				var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(res);
				model = new AttachTexture(eff);
			case ".png":
				model = new AttachImage(res);
		}
		
		addGraphic(cast model);
		//trace(model);
		setHitbox(model.width, model.height);
		//setHitbox(Std.int(_model.width *0.5), _model.height , Std.int(_model.width / 4), Std.int(_model.height / 2));
		return model;
	}
	
	
	override private function preload():Void
	{
		_model = createAvatar(_info.res, name);
	}
	
	override private function set_flip(value:Bool):Bool
	{
		return _model.flip = value;
	}
	
	public function setFrameIndex(index:Int):Void
	{
		var tex = _model.as(AttachTexture);
		tex.frame = index;
		setHitbox(Std.int(tex.width *0.5), Std.int(tex.height*0.5) , Std.int(tex.width / 4), -10);
	}
}