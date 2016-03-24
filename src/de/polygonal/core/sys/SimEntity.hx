package de.polygonal.core.sys;

import com.metal.message.MsgUtils;
import de.polygonal.core.es.Entity;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.event.Observable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.util.Assert.assert;
import de.polygonal.core.util.ClassUtil;
import de.polygonal.ds.Sll;
import haxe.ds.StringMap.StringMap;
import openfl.errors.Error;

/**
 * ...
 * @author weeky
 */
class SimEntity extends Entity implements IObservable
{
	public var compMap(default, null):Sll<Component>;
	public var propMap(default, null):StringMap<Dynamic>;
	private var _initialized:Bool;
	
	public var keyId:Int;
	
	private var _observable:Observable = null;
	public var observable(get, null):Observable;
	private function get_observable():Observable
	{
		if (_observable == null)
			_observable = new Observable(0, this);
		return _observable;
	}
	/**
	 * last is first update
	 */
	public function attach(o:IObserver, mask:Int = 0)
	{
		observable.attach(o, mask);
	}
	
	public function detach(o:IObserver, mask:Int = 0)
	{
		observable.detach(o, mask);
	}
	
	public function new(id:String = null, autoInit:Bool = true, isGlobal:Bool = false)
	{
		super(id, isGlobal);
		compMap = new Sll();
		propMap = new StringMap();
		_initialized = false;
		if(autoInit)
			init();
	}
	
	/**
	 * Adds a Component to this entity. 添加组件
	 * @param x an object inheriting from Component or a reference to an Component class.
	 * @return the added Component
	 */
	public function addComponent<T:Component>(inst:T):T
	{
		var c:Component = inst;
		if (c.owner != null){
			if (Type.enumEq(c.owner, this))
				cast c;
			else 
				throw "has owner";
		}
		if (compMap.contains(c))
			return cast c;
		compMap.append(c);
		attach(c);
		if (_initialized){
			c.initComponent(this);
			c.onUpdate(MsgCore.PROCESS, this, null);
		}
		return cast c;
	}
	
	/**
	 * 添加属性，在系统启动之前，启动后添加会报错
	 * @param	prop 属性
	 * @param	implementTypes 实现的方法
	 */	
	public function addProperty(prop : Dynamic) : Dynamic {
		var id:String = ClassUtil.getUnqualifiedClassName(prop);
		if (propMap.exists(id))
		{
			return prop;
		}
		
		propMap.set(id, prop);
		
		return prop;
	}
	
	public function removeComponent(comp:Component):Bool 
	{
		//trace(comp);
		if (compMap == null) {
			return false;
		}
		detach(comp);
		comp.remove();
		return compMap.remove(comp);
	}
	public function removeAllComponent()
	{
		var comp;
		var node = compMap.head;
		while (node!=null) 
		{
			comp =  node.val;
			if (comp != null) 
				comp.dispose();
			detach(comp);
			node = node.next;
		}
		compMap.clear(true);
	}
	public function removeProp(prop:Dynamic):Bool 
	{
		var id:String = ClassUtil.getUnqualifiedClassName(prop);
		return propMap.remove(id);
	}
	/**
	 * 获取组件，通过类型形式，启动前调用此方法会报错
	 * @param	type     类型
	 * @param	mustFind 是否一定要找到，否则会报错
	 * @return
	 */
	public function getComponent<T:Component>(type:Class<T>):T 
	{
		//var a = ClassUtil.getClassType(type);
		var n = compMap.head;
		while (n != null)
		{
			var e = n.val;
			if (ClassUtil.getClassName(type) == ClassUtil.getClassName(e))
				return untyped e;
			n = n.next;
		}
		return null;
		
		//var id:String = ClassUtil.getUnqualifiedClassName(type);
		//return untyped compMap.get(id);
	}
	/**
	 * 获取属性，通过类型形式，启动前调用此方法会报错
	 * @param	type     类型
	 * @param	mustFind 是否一定要找到，否则会报错
	 * @return
	 */	
	public function getProperty<T:Dynamic>(type:Class<T>):T 
	{
		var id:String = ClassUtil.getUnqualifiedClassName(type);
		//trace(propMap);
		return untyped propMap.get(id);
	}
	/*
	override function onRemove(parent:Entity):Void 
	{
		var comp;
		var node = compMap.head;
		while (node!=null) 
		{
			comp =  node.val;
			if (comp != null) 
				comp.dispose();
			detach(comp);
			node = node.next;
		}
		compMap.clear(true);
		compMap = null;
		propMap = null;
		super.onRemove(parent);
	}
	*/
	public function init()
	{
		if (!_initialized) {
			_initialized = true;
			var comp:Component;
			var node = compMap.head;
			while(node!=null)
			{
				comp = node.val;
				if (comp == null) 
					continue;
				comp.initComponent(this);
				node = node.next;
			}
			notify(MsgCore.PROCESS);
		}
	}
	
	override function onFree() 
	{
		//not component recieve
		notify(MsgCore.FREE);
		
		var comp;
		var node = compMap.head;
		while (node!=null) 
		{
			comp =  node.val;
			if (comp != null) {
				comp.dispose();
				detach(comp);
			}
			node = node.next;
		}
		compMap.clear(true);
		compMap = null;
		propMap = null;
		observable.free();
		observable = null;
	}
	
	override function onTick(dt:Float, post:Bool):Void 
	{
		var comp:Component;
		var node = compMap.head;
		while(node!=null) 
		{
			comp = node.val;
			if (comp == null) 
				continue;
			comp.onTick(dt);
			node = node.next;
		}
	}
	override function onDraw(alpha:Float, post:Bool):Void 
	{
		var comp:Component;
		var node = compMap.head;
		while(node!=null) 
		{
			comp = node.val;
			if (comp == null) 
				continue;
			comp.onDraw();
			node = node.next;
		}
	}
	
	/**
	 * 发送消息给自己
	 */
	public function sendMMsg(type:Int, userData:Dynamic = null):Void
	{
		MsgUtils.sendDirectMsg(this, type, userData);
	}
	/**
	 * 通知component事件
	 */
	public function notify(type:Int, userData:Dynamic = null):Void
	{
		observable.notify(type, userData);
	}
	/**
	 * 通知parent的component
	 */
	public function notifyParent(type:Int, userData:Dynamic = null):Void
	{
		if (parent == null)
			throw new Error ("parent is null");
		cast(parent, SimEntity).notify(type, userData);
	}
}