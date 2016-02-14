package com.haxepunk.graphics.atlas;
import com.haxepunk.graphics.atlas.AtlasData.AtlasDataType;
import com.haxepunk.HXP;
import haxe.ds.StringMap;
import openfl.Assets;
import openfl.geom.Point;

/**
 * ...
 * @author weeky
 */
class TextureAtlasFix extends TextureAtlas
{
	public static var caches:StringMap<TextureAtlasFix> = new StringMap();
	public static function clearCacahes() {
		for (key in caches.keys()) 
		{
			caches.remove(key);
		}
	}
	private var _regionKeys:Array <String>;
	public var xml:Xml;
	public var ox:Float = 0;
	public var oy:Float = 0;
	public var scale:Float = 1;
	public var r:Float = 0;
	public function new(source:AtlasDataType) 
	{
		_regionKeys = [];
		super(source);
	}
	
	public static function loadTexture(file:String):TextureAtlasFix
	{
		if (caches.exists(file))
			return caches.get(file);
		var dataXml = Xml.parse(Assets.getText(file));
		//Modify
		var index:Int = file.lastIndexOf("/");
		var rootPath:String = file.substring(0, index + 1);
		//
		var root:Xml = dataXml.firstElement();
		var atlas:TextureAtlasFix = new TextureAtlasFix(rootPath + root.get("imagePath"));
		if (root.exists("ox"))
			atlas.ox = Std.parseFloat(root.get("ox"));
		if (root.exists("oy"))
			atlas.oy = Std.parseFloat(root.get("oy"));
		if (root.exists("r"))
			atlas.r = Std.parseFloat(root.get("r"));
		if (root.exists("scale"))
			atlas.scale= Std.parseFloat(root.get("scale"));
		atlas.xml = dataXml;
		for (sprite in root.elements())
		{
			HXP.rect.x = Std.parseInt(sprite.get("x"));
			HXP.rect.y = Std.parseInt(sprite.get("y"));
			if (sprite.exists("w")) HXP.rect.width = Std.parseInt(sprite.get("w"));
			else if (sprite.exists("width")) HXP.rect.width = Std.parseInt(sprite.get("width"));
			if (sprite.exists("h")) HXP.rect.height = Std.parseInt(sprite.get("h"));
			else if (sprite.exists("height")) HXP.rect.height = Std.parseInt(sprite.get("height"));
			
			var offset:Point;
			if (sprite.exists("r") && sprite.get("r") == "y"){
				offset = new Point(Std.parseFloat(sprite.get("oY")) + HXP.rect.width, Std.parseFloat(sprite.get("oX")));
			}else {
				if(sprite.exists("oX") && sprite.exists("oY"))
					offset = new Point( Std.parseFloat(sprite.get("oX")), Std.parseFloat(sprite.get("oY")));
				else 
					offset = new Point();
			}
			// set the defined region
			var name = if (sprite.exists("n")) sprite.get("n")
						else if (sprite.exists("name")) sprite.get("name")
						else throw("Unable to find the region's name.");
			var region:AtlasRegion = atlas.defineRegion(name, HXP.rect, offset);
			atlas._regionKeys.push(name);
			if (sprite.exists("r") && sprite.get("r") == "y") region.rotated = true;
		}
		caches.set(file, atlas);
		return atlas;
	}
	
	public function getRegionNames():Iterator<String>
	{
		return _regions.keys();
	}
	
	public function getRegionByIndex(p_index:Int):AtlasRegion 
	{
		var name:String =  _regionKeys[p_index];
		if (name == null) return null;
		return _regions.get(name);
	}
	
	public function getReginCount():Int 
	{
		return _regionKeys.length;
	}
}