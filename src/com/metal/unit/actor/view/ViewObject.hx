package com.metal.unit.actor.view;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.config.ResPath;
import com.metal.config.UnitModelType;
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
	}
	
	override function createAvatar(name:String, type:String):Dynamic 
	{
		var fileName = name.substring(0, name.length - 4);
		var fileType = (type != UnitModelType.Unit)?name.substr(name.length - 4):".xml";
		var res = ResPath.getIconPath(fileName, "", fileType);
		var model:IAttach;
		switch(fileType) { 
			case ".xml":
				var eff:TextureAtlasFix;
				if (type == UnitModelType.Unit){   
					eff = TextureAtlasFix.loadTexture(ResPath.getModelXML(type, name));
				}else{
					eff = TextureAtlasFix.loadTexture(res);
				}
				model = new AttachTexture(eff);
			case ".png":
				model = new AttachImage(res);
			default:
				model = null;
		}
		var img:Image = cast (model,Image);
		addGraphic(img);
		//trace(res + " : "+a.width);
		setHitbox(img.width, img.height);
		//setHitbox(Std.int(img.width *0.5), img.height , Std.int(img.width / 4), Std.int(img.height / 2));
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