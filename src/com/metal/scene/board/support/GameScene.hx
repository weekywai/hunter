package com.metal.scene.board.support;

import com.haxepunk.Entity;
import com.haxepunk.Scene;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
#if telemetry
import hxtelemetry.HxTelemetry.Timing;
#end

/**
 * ...
 * @author weeky
 */
class GameScene extends Scene implements IObserver
{
	private var _end:Bool;
	public function new() 
	{
		super();
		_end = false;
	}
	/**接收消息*/
	public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void { }
	
	override public function create<E:Entity>(classType:Class<E>, addToScene:Bool = true, ?constructorsArgs:Array<Dynamic>):E
	{
		return super.create(classType, addToScene, constructorsArgs);
	}
	
	override public function add<E:Entity>(e:E):E 
	{
		//trace(Type.typeof(e));
		return super.add(e);
	}
	
	override public function end() 
	{
		#if telemetry
		GameProcess.HXT.start_timing(Timing.USER);
		#end
		destoryGraphic(_recycled.iterator());
		destoryGraphic(_remove.iterator());
		clearTweens();
		clearRecycledAll();
		removeAll();
		_end = true;
		updateLists();
		#if telemetry
		GameProcess.HXT.end_timing(Timing.USER);
		#end
		trace("Scene end");
	}
	
	public function destoryGraphic(itr:Iterator<Entity>)
	{
		if (itr == null) return;
		var	e:Entity = itr.next();
		while (e != null)
		{
			e.dispose();
			e = itr.next();
		}
	}
	
	private function dispose():Void 
	{
		_end = false;
		
		for (key in _classCount.keys()) 
		{
			_classCount.remove(key);
		}
		trace(_add +">>" + _layerList +">>" + _layerDisplay +">>" + _layers +">>" + _classCount +">>" + _types +">>" + _recycled +">>" + _entityNames);
		//_add = null;
		//_remove = null;
		//_recycle = null;
		//_update = null;
		//_layerList = null;
		//_layerDisplay = null;
		//_layers = null;
		//_classCount = null;
		//_types = null;
		//_recycled = null;
		//_entityNames = null;
		//camera = null;
	}
	override public function updateLists(shouldAdd:Bool = true) 
	{
		super.updateLists(shouldAdd);
		if (_end){
			dispose();
			//trace("end entity:" + _remove +">> recycle:" + _recycled +">> update:"+ _update);
		}
	}
}