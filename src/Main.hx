package ;

import com.metal.GameProcess;
import com.metal.proto.impl.ConfigInfo;
import haxe.ds.StringMap;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Floating;
#if !neko
import crashdumper.CrashDumper;
import crashdumper.SessionData;
#end

/**
 * 
 * @author weeky
 */

class Main extends Sprite 
{
	var inited:Bool;
	
	public static var config:StringMap<Dynamic>;
	public static var Scale:Float = 1;
	
	public static var Log:Dynamic;
	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
		//doLayout(e);
		Scale = stage.stageWidth / 1280;
		var w:Floating = cast UIBuilder.get("root");
		if (w != null) {
			w.scaleContent = Scale;
		}
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;
		config = ConfigInfo.readXml(Assets.getText("config.xml"));
		//trace(Type.typeof(config.get("console")));
		#if !neko
		CrashDumper.writeFile = true;// cast config.get("crashLog");
		var unique_id:String = SessionData.generateID("example_app_");
		var crashDumper = new CrashDumper(unique_id);
		#end
		GameProcess.instance.init(stage, this);
	}
	

	/* SETUP */

	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		Scale = stage.stageWidth / 1280;
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	//callback to create alert popups
    
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
		
		
	}
}
