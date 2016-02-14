package com.metal.unit.actor.view;
import com.haxepunk.HXP;
import com.metal.component.BattleComponent;
import com.metal.manager.ResourceManager;
import com.metal.message.MsgActor;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.manager.ModelManager;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.ai.MonsterAI;
import com.metal.unit.avatar.MTAvatar;
import de.polygonal.core.event.IObservable;
import spinehaxe.Event;

/**
 * NPC
 * @author li
 */
class ViewNPC extends BaseViewActor
{
	private var _info:MonsterInfo;
	public function new() 
	{
		super();	
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = owner.getComponent(UnitActor);
		_info = owner.getProperty(MonsterInfo);
	}
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onNotify(type, source, userData);
	}
	
	override public function onDispose():Void 
	{
		super.onDispose();
	}
	
	override private function cmd_PostBoot(userData:Dynamic):Void
	{
		//判断加载类型
		var source:Int = owner.getProperty(MonsterInfo).res;
		//trace(source);
		_modelInfo = ModelManager.instance.getProto(source);
		if (_modelInfo == null)
			throw "model info is null";
		
		if (_avatar == null) {
			_avatar = HXP.scene.create(MTAvatar, false);
			//_avatar =  cast ResourceManager.instance.getEntity(_modelInfo.res);
		}
		//记录碰撞类型
		_avatar.init(owner);
		
		_avatar.preload(_modelInfo);
			
		notify(MsgActor.PostLoad, _avatar);
		_avatar.animationState().onEnd.add(onEndCallback);
		trace(owner.name);
	}
	
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		//super.Notify_Destorying(userData);
		trace("npc drop !!!!!!!!!!!!");
		var battle:BattleComponent = GameProcess.root.getComponent(BattleComponent);
		var items = battle.currentStage().DropItem;
		//trace("items=="+items);
		var ran = Math.round(Math.random() * (items.length-1));
		//trace("RandomID: "+ran+" info:"+items[ran].ItemId);
		createDropItem([items[ran]]);
		setAction(ActionType.teshu_1, false);
	}
	
	override function setAction(action:ActionType, loop:Bool = true):Void 
	{
		//trace("action " + action + "current " + _curAction);
		//super.setAction(action, loop);
		if (_curAction == action || action == dead_1) 
			return;
		_curAction = action;
		//trace(action);
		_avatar.setDirAction(Std.string(action), _actor.dir, loop);
	}
	
	private function onEndCallback(count:Int, name:String):Void
	{
		//trace("name " + name);
		if (name == "teshu_1")
		{
			notify(MsgActor.Destroy);
		}
	}
	
}