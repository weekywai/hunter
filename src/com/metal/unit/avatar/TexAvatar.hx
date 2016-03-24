package com.metal.unit.avatar;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.config.ResPath;

/**
 * ...
 * @author 3D
 */
class TexAvatar extends MTAvatar
{
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
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
		//_model.play("box");
		
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
		_model.flip = value;
		return value;
	}
	
	override public function setCallback(fun:Dynamic) 
	{
		//super.setCallback(fun);
	}
	
	public function setFrameIndex(index:Int):Void
	{
		var tex = _model.as(AttachTexture);
		tex.frame = index;
		setHitbox(Std.int(tex.width *0.5), Std.int(tex.height*0.5) , Std.int(tex.width / 4), -10);
	}
}