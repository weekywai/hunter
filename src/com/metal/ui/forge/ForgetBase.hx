package com.metal.ui.forge;
import de.polygonal.core.sys.SimEntity;
import ru.stablex.ui.widgets.Widget;

/**
 * ...
 * @author weeky
 */
class ForgetBase
{
	private var _goodsInfo:Dynamic;
	private var _owner:SimEntity;
	//选择装备类型Id
	private var subId:Int;
	private var _widget:Widget;
	public function new() 
	{
	}
	public function onInitComponent(owner:SimEntity):Void 
	{
		_owner = owner;
	}
	
	/**设置数据*/
	public function setData(data:Dynamic):Void
	{	
		_goodsInfo = data;
	}
	/*设置背包中可作为强化的材料*/
	private function setMaterial():Void
	{
	}
	//public function submit():Void
	//{
	//}
	//
	private function sendMsg(type:Int,userData:Dynamic = null)
	{
		if (_owner != null){
			if (userData != null)
				_owner.outgoingMessage.o = userData;
			_owner.sendMMsg(type, userData);
		}
	}
	private function notifyParent(type:Int,userData:Dynamic = null)
	{
		if (_owner != null)
			_owner.notifyParent(type, userData);
	}
	private function notifyRoot(type:Int,userData:Dynamic = null)
	{
		GameProcess.root.notify(type, userData);
	}
	private function notify(type:Int,userData:Dynamic = null)
	{
		if (_owner != null)
			_owner.notify(type, userData);
	}
	public function dispose():Void 
	{
		_owner = null;
		_goodsInfo = null;
		_widget.free();
		_widget = null;
	}
}