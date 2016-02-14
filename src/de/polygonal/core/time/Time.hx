package de.polygonal.core.time;
import flash.events.Event;
import openfl.Lib;

/**
 * ...
 * @author weeky
 */
class Time
{
	private var _fun:Void->Void;
	public function new() 
	{
		init();
	}
	public function init()
	{
		Lib.current.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	public function now():Float
	{
		return
		#if flash
		Date.now().getTime() / 1000
		#else
		haxe.Timer.stamp()
		#end
		//openfl.Lib.getTimer()
		;
	}
	
	public function setTimingEventHandler(fun:Void->Void)
	{
		_fun = fun;
	}
	
	function onEnterFrame(e:Event):Void
	{
		if (_fun != null )
			_fun();
	}
}