package com.metal.unit.avatar;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.math.Vector;
import com.metal.config.ResPath;

/**
 * ...
 * @author 3D
 */
class TexAvatar extends MTAvatar
{

	private var _model:TextrueSpritemap;
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
		//setHitboxTo(_model);
		color = _colorT.color;
		//super.update();
	}
	
	override function createAvatar(name:String, type:String):Dynamic 
	{
		var _model:TextrueSpritemap;
		var eff:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getModelXML(type, name));
		_model = new TextrueSpritemap(eff);
		_model.add("box", eff.getReginCount(), 14);
		_model.frame = 0;
		_model.animationEnd.add(onComplete);
		_model.centerOrigin();
		graphic = _model;
		//_model.play("box");
		
		setHitbox(Std.int(_model.width *0.5), _model.height , Std.int(_model.width / 4), Std.int(_model.height / 2));
		return _model;
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
		_model.flipped = value;
		return value;
	}
	
	override public function get_color():Int
	{
		if (_model == null)
			return 0;
		return _model.color;
	}
	
	override public function set_color(value:Int):Int
	{
		return _model.color = value;
	}
	
	override public function setCallback(fun:Dynamic) 
	{
		//super.setCallback(fun);
	}
	
	public function setFrameIndex(index:Int):Void
	{
		_model.frame = index;
		setHitbox(Std.int(_model.width *0.5), Std.int(_model.height*0.5) , Std.int(_model.width / 4), -10);
	}
}