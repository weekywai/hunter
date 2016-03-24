package com.metal.message;
import com.metal.manager.UIManager;
import de.polygonal.core.es.Entity;
import de.polygonal.core.es.EntitySystem;
import de.polygonal.core.sys.SimEntity;

/**
 * ...
 * @author weeky
 */
class MsgUtils
{
	private static var _ui:SimEntity;
	private static var _root:Entity;
	
	public function new() 
	{
		
	}
	
	public static function sendDirectMsg(e:Entity, type:Int, userData:Dynamic = null)
	{
		if (userData != null)
			e.outgoingMessage.o = userData;
		var p = e.parent;
		if(p!=null)
			p.sendMessageToChildren(type, true);
		else
		//TODO can't send myself
			e.sendDirectMessage(e, type, true);
	}
	
	public static function sendUIMsg(type:Int, userData:Dynamic = null)
	{
		if (_ui == null)
			_ui = EntitySystem.findByName("UIManager");
		sendDirectMsg(_ui, type, userData);
	}
	
	public static function notifyUI(type:Int, userData:Dynamic = null)
	{
		if (_ui == null)
			_ui = EntitySystem.findByName("UIManager");
		_ui.notify(type, userData);
	}
	
	public static function sendRootMsg(type:Int, userData:Dynamic = null)
	{
		if (_root == null)
			_root = EntitySystem.findByName("Game");
		sendDirectMsg(_root, type, userData);
	}
}