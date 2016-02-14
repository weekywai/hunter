package de.polygonal.core.sys;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.event.Observable;
import de.polygonal.core.sys.Disposer;
import de.polygonal.core.sys.SimEntity;

/**
 * Components are bits of data and logic that can be added to entities.
 */
//@:build(de.polygonal.core.sys.ComponentType.build())
//@:autoBuild(de.polygonal.core.sys.ComponentType.build())
class Component extends Disposer implements IObserver
{
	var _owner:SimEntity;
    /** The entity this component is attached to, or null. */
    public var owner (get, null) :SimEntity;
	private function get_owner():SimEntity
	{
		return untyped _owner;
	}
	
	public var isInit(default, null):Bool;
	//public var _type:Int;
	public function new():Void 
	{
		super();
		isInit = false;
		//var c = Type.getClass(this);
		//_type = ClassUtil.getClassType(c);
		//Entity.addComp(_type);
	}
	
	public function initComponent(owner:SimEntity):Void 
	{
		if (isDisposed) throw "Component disposed";
		if (this.owner != null) throw "Component owner not null";
		if (isInit) throw "Component Already Initialized : " + toString();
		_owner = owner;
		onInitComponent();
		if (!isInit) throw "Component super.OnInitComponent not called : " + toString();
	}
	
	// Do       1:注册事件监听    2:获取其他组建
	// Not Do   1:调用或读取引用    2:发送事件    3:删除    4:调用其他组件的方法
	private function onInitComponent():Void 
	{
		isInit = true;
	}
	private function onRemoveComponent()
	{
		
	}
	public function remove()
	{
		onRemoveComponent();
		_owner = null;
		isInit = false;
	}
	
	override function onDispose():Void 
	{
		super.onDispose();
		if (_owner != null) {
			//Removes this component from its owning entity.
            _owner.removeComponent(this);
        }
		_owner = null;
	}
	public function onUpdate(type:Int, source:IObservable, userData:Dynamic)
	{
		onNotify(type, source, userData);
	}
	/**接收消息*/
	public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void { }
	/**逻辑更新*/
	public function onTick(timeDelta:Float) { }	
	/**渲染更新*/
	public function onDraw(){}	
	
	/**
	 * 必须在onInitComponent方法执行
	 */
	private function addMsgListener(type:Int, func:Int -> Dynamic -> Bool):Void 
	{
		Observable.bind(func, owner, type);
	}
	/**发送给component entity内部通讯*/
	private function notify(type:Int, userData:Dynamic=null):Void 
	{
		_owner.notify(type, userData);
	}
	/**发送给component entity->parent通讯*/
	private function notifyParent(type:Int, userData:Dynamic=null):Void 
	{
		_owner.notifyParent(type, userData);
	}
	private function notifyDirect(name:String, type:Int, userData:Dynamic=null):Void 
	{
		var e = _owner.findChild(name);
		cast(e, SimEntity).notify(type, userData);
	}
	/**发送给本体entity*/
	private function sendMsg(type:Int, userData:Dynamic=null):Void 
	{
		if (userData != null)
			_owner.outgoingMessage.o = userData;
		_owner.sendDirectMessage(_owner, type, true);
	}
	/**发送给上级entity*/
	private function sendMsgParent(type:Int, userData:Dynamic=null):Void 
	{
		if (userData != null)
			_owner.outgoingMessage.o = userData;
		_owner.sendMessageToParents(type, true);
	}
	/**
	 * 发送到最上层,最上层可能不是游戏，需要override
	 */
	private function sendMsgRoot(type:Int, userData:Dynamic=null):Void 
	{
		if (userData != null)
			_owner.outgoingMessage.o = userData;
		_owner.sendMessageToAncestors(type, true);
	}
	/**发送子级 entity内部通讯*/
	private function sendMsgChildren(type:Int, userData:Dynamic = null)
	{
		if (userData != null)
			_owner.outgoingMessage.o = userData;
		_owner.sendMessageToChildren(type, true);
	}
	
	override public function toString():String 
	{
		return super.toString();
	}
}
