package com.metal.unit.actor.view;
import com.metal.component.BattleSystem;
import com.metal.message.MsgActor;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.manager.ModelManager;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.impl.UnitActor;

/**
 * NPC
 * @author li
 */
class ViewNPC extends ViewActor
{
	public function new() 
	{
		super();	
	}
	
	override public function onDispose():Void 
	{
		super.onDispose();
	}
	
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		//判断加载类型
		var source:Int = owner.getProperty(MonsterInfo).res;
		//trace(source);
		_info = ModelManager.instance.getProto(source);
		_actor = owner.getComponent(UnitActor);
		if (_info == null)
			throw "model info is null";
		
		//if (_avatar == null) {
			//_avatar = HXP.scene.create(MTAvatar, false);
			//_avatar =  cast ResourceManager.instance.getEntity(_modelInfo.res);
		//}
		//记录碰撞类型
		
		preload();
			
		notify(MsgActor.PostLoad, this);
		animationState().onEnd.add(onEndCallback);
		//trace(owner.name);
	}
	
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		//super.Notify_Destorying(userData);
		trace("npc drop !!!!!!!!!!!!");
		var battle:BattleSystem = GameProcess.root.getComponent(BattleSystem);
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
		setDirAction(Std.string(action), _actor.dir, loop);
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