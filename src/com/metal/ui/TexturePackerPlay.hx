package com.metal.ui;
import com.marshgames.openfltexturepacker.TexturePackerImport;
import motion.Actuate;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import signals.Signal1;
//import tweenx909.TweenX;

/**
 * ...
 * @author hyg
 */
class TexturePackerPlay extends Sprite
{
	
	//public static var instance(default, null):TexturePackerPlay = new TexturePackerPlay();
	private var frames:Array<TexturePackerFrame>;
	private var tilesheet:Tilesheet;
	private var idMap:Map<String,Int>;
	private var effectSp:Sprite;
	private var _spriteName:String;
	private var imageNum:Int = 0;
	public var callback:Signal1<Dynamic>;
	
	public function new() 
	{
		super();
		callback = new Signal1();
	}
	public function effectPlay(path:String, spriteName:String, posx:Float = 0, posy:Float = 0, isXml:Bool = false):Void
	{
		effectSp = new Sprite();
		if (this.numChildren > 0) this.removeChildAt(0);
		this.addChild(effectSp );
		effectSp.x = posx;
		effectSp.y = posy;
		_spriteName = spriteName;
		if (isXml)
			frames = TexturePackerImport.parseXml(
				Assets.getText(path+".xml")
			);
		else
			frames = TexturePackerImport.parseJson(
				Assets.getText(path+".json")
			);
		tilesheet = new Tilesheet(
			Assets.getBitmapData(path+".png")
		);
		
		idMap = TexturePackerImport.addToTilesheet(tilesheet, frames);
	}
	public function onPlay():Void
	{
		imageNum = 0;
		for (i in 1...frames.length+1)
		{
			Actuate.timer(i * 0.07).onComplete(play);
		}
	}
	private function  play():Void
	{
		imageNum++;
		effectSp.graphics.clear();
		var str:String = Std.string(imageNum);
		if (imageNum < 10) str = "0" + Std.string(imageNum);
		tilesheet.drawTiles(effectSp.graphics, [0, 0, idMap[_spriteName + str + ".png"]]);
		if (imageNum >= frames.length)
		{
			effectSp.graphics.clear();
			this.removeChildren();
			callback.dispatch(true);
		}
	}
	
}