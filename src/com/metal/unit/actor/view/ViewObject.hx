package com.metal.unit.actor.view;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.config.ResPath;
import com.metal.unit.avatar.AttachTexture;

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
		if(_model!=null)
			_model.color = _colorT.color;
	}
	
	override function createAvatar(name:String, type:String):Dynamic 
	{
		var model:AttachTexture;
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getModelXML(type, name));
		model = new AttachTexture(eff);
		model.initAttach(onComplete);
		addGraphic(model);
		
		setHitbox(Std.int(model.width *0.5), model.height , Std.int(model.width / 4), Std.int(model.height / 2));
		return model;
	}
	
	private function onComplete(obj):Void
	{
		//recycle();
		//scene.remove(this);
	}
	
	override private function initTexture():Void
	{
		_model = createAvatar(_info.res, "unit");
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