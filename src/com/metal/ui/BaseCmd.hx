package com.metal.ui;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.Disposer;
import openfl.events.Event;
import ru.stablex.ui.widgets.Widget;

/**
 * command
 * @author weeky
 */
class BaseCmd extends Component
{
	private var _widget:Widget;
	//移除
	private var _unparent:Bool = false;
	public function new() 
	{
		super();
	}
	/**必须先执行_widget获取才super*/
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		if (_widget != null) {
			_unparent = false;
			_widget.addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			_widget.addEventListener(Event.ADDED_TO_STAGE, onDisplay);
		}
	}
	
	private function notifyRoot(type:Int, userData:Dynamic=null):Void 
	{
		GameProcess.instance.notify(type, userData);
	}
	
	private function onDisplay(e:Event):Void
	{
		if(_widget!=null)_widget.removeEventListener(Event.ADDED_TO_STAGE, onDisplay);
		onShow();
	}
	private function onRemove(e:Event):Void
	{
		if(_widget!=null)_widget.removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		onClose();
		_unparent = true;
	}
	
	private function onShow():Void {}
	private function onClose():Void {}
	override function onDispose():Void 
	{
		super.onDispose();
		if (_widget != null)
			_widget.free();
	}
}