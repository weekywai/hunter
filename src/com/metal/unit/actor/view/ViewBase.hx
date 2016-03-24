package com.metal.unit.actor.view;

import com.haxepunk.HXP;
import com.haxepunk.graphics.TextrueSpritemap;
import com.metal.config.PlayerPropType;
import com.metal.config.UnitModelType;
import com.metal.manager.ResourceManager;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgEffect;
import com.metal.message.MsgStat;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.manager.ModelManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.impl.BaseActor;
import com.metal.unit.avatar.AbstractAvatar;
import com.metal.unit.stat.IStat;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.MsgCore;
import haxe.ds.StringMap;
import openfl.geom.Point;


/**
 * 角色视图控制
 * @author weeky
 */
class ViewBase extends AbstractAvatar
{
	private var _curAction:ActionType;
	
	private var _actor:BaseActor;

	private var _stat:IStat;
	private var _effList:StringMap<TextrueSpritemap>;
	/**武器旋转跟随坐标*/
	private var _targetPos:Point;
	private var _attcking:Bool;
	private var _meleeHit:Bool;
	public function new() 
	{
		super();
		_effList = new StringMap();
		_curAction = none;
		_attcking = false;
		_meleeHit = false;
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgCore.PROCESS:
				Notify_PostBoot(userData);
			case MsgCore.FREE:
				Notify_FREE(userData);
			case MsgActor.EnterBoard:
				Notify_EnterBoard(userData);
			case MsgActor.BornPos:
				Notify_BornPos(userData);
			case MsgActor.Stand:
				Notify_Stand(userData);
			case MsgActor.Move:
				Notify_Move(userData);
			case MsgActor.Jump:
				Notify_Jump(userData);
			case MsgActor.Attack:
				Notify_Attack(userData);
			case MsgActor.Skill:
				Notify_Skill(userData);
			case MsgActor.Injured:
				Notify_Injured(userData);
			case MsgActor.Destroy:
				Notify_Destory(userData);
			case MsgActor.Destroying:
				Notify_Destorying(userData);
			case MsgActor.Respawn:
				Notify_Respawn(userData);
			case MsgEffect.EffectStart:
				Notify_EffectStart(userData);
			case MsgEffect.EffectEnd:
				Notify_EffectEnd(userData);
			case MsgStat.ChangeSpeed:
				Notify_ChangeSpeed(userData);
			case MsgActor.Soul:
				Notify_Soul(userData);
		}
	}
	
	override public function onDispose():Void 
	{
		_actor = null;
		_stat = null;
		_targetPos = null;
		for (key in _effList.keys()) {
			var effect = _effList.get(key);
			effect.destroy();
			_effList.remove(key);
		}
		_effList = null;
		super.onDispose();
	}
	
	override public function update():Void 
	{
		super.update();
		if (isDisposed || _isFree)
			return;
		if(onCamera && !ActorState.IsDestroyed(_actor.stateID) ){
			active = onCamera;
			visible = onCamera;
		}else {
			active = true;
			visible = true;
		}
			
		//trace(_actor.x + "::" + _actor.y);
		//actor数据更新后view再更新
		//只有一帧不能loop
		//trace(_actor.stateID);
		setAction(ActorState.GetAction(_actor.stateID));
		x = _actor.x;
		y = _actor.y;
	}
	
	
	/* entity notify internal component */
	function Notify_PostBoot(userData:Dynamic) 
	{
		//判断加载类型
		var source:Int;
		switch(owner.name) {
			case UnitModelType.Player:
				source = PlayerUtils.getInfo().getProperty(PlayerPropType.ROLEID);
			case UnitModelType.Vehicle:
				source = PlayerUtils.getInfo().vehicle;
			case UnitModelType.Unit,UnitModelType.Boss,UnitModelType.Elite:
				source = owner.getProperty(MonsterInfo).res;
			//case UnitModelType.Npc:
				//source = owner.getProperty(MonsterInfo).res;
			default:
				throw " modelInfo is null - sourceId:" + owner.name;
		}
		
		_info = ModelManager.instance.getProto(source);
		//怪物飞行 
		if(owner.name == UnitModelType.Unit)
			_info.fly = owner.getProperty(MonsterInfo).ModelType;
		preload();
		setAction(ActionType.idle_1);
		
		notify(MsgActor.PostLoad, this);
	}
	
	private function Notify_FREE(userData:Dynamic):Void { 
		_isFree = true; 
		if(scene!=null)
			scene.remove(this);
	}
	private function Notify_Stand(userData:Dynamic):Void {}
	private function Notify_Move(userData:Dynamic):Void {}
	private function Notify_Skill(userData:Dynamic):Void {}
	private function Notify_Jump(userData:Dynamic):Void {}
	private function Notify_Creep(userData:Dynamic):Void {}
	private function Notify_Soul(userData:Dynamic):Void { }
	private function Notify_ChangeSpeed(userData:Dynamic):Void {}
	private function Notify_EffectStart(userData:Dynamic):Void { }
	private function Notify_Attack(userData:Dynamic):Void {}
	private function Notify_Respawn(userData:Dynamic):Void {
		trace("Notify_Respawn owner:"+owner.name);
		type = owner.name;
	}
	private function Notify_EffectEnd(userData:Dynamic):Void {
		if (_effList.exists(userData)) {
			var effect = _effList.get(userData);
			removeGraphic(effect);
			effect.destroy();
			_effList.remove(userData);
		}
	}
	private function Notify_Injured(userData:Dynamic):Void {
		//trace("injured");
		startChangeColor();
	}
	
	private function Notify_Destorying(userData:Dynamic):Void {
		type = "";
		_attcking = false;
		//trace("Notify_Destroying");
		//trace("_actor.stateID: "+_actor.stateID);
	}
	private function Notify_Destory(userData:Dynamic):Void {
		_attcking = false;
		if (_actor.isInBoard() && scene!=null)
			//scene.recycle(this);
			scene.remove(this);
	}

	private function Notify_EnterBoard(userData:Dynamic):Void
	{
		if (ResourceManager.PreLoad) {
			visible = true;
			active = true;
		}else {
			//DC.beginProfile("add viewactor");
			HXP.scene.add(this);
			//DC.endProfile("add viewactor");
		}
	}
	
	private function Notify_BornPos(userData:Dynamic):Void { }
	
	
	private function setAction(action:ActionType, loop:Bool = true):Void {
		if (_actor==null) return;
		if (_actor.dir == null)
			return;
		if (action == ActionType.none)
			return;
		if (_curAction == action)
			return;
		_curAction = action;
		if (_actor.stateID == ActorState.Destroying || _actor.stateID == ActorState.Jump || _actor.stateID == ActorState.DoubleJump || _actor.stateID == ActorState.Enter || _actor.stateID == ActorState.Attack)
			loop = false;
		//trace("_actor.stateID: " + _actor.stateID);
		//trace("action: "+action);
		setDirAction(Std.string(action), _actor.dir, loop);
	}
	
	/**掉落*/
	private function createDropItem(dropItem:Array<DropItemInfo>)
	{
		if(dropItem.length > 0)
		{
			var unit:UnitInfo = new UnitInfo();
			unit.faction = BoardFaction.Item;
			for (item in dropItem) 
			{
				//trace(item.ItemId+">>"+item.Precent);
				//if (item.Precent == 100) {
					unit.simType = UnitModelType.DropItem;
					unit.id = item.ItemId;
					unit.x = x;
					unit.y = y - 300;
					notifyParent(MsgBoard.CreateUnit, unit);
				//}else {
					//if (Math.random()*100 <= item.Precent) {
						//unit.simType = UnitModelType.Item;
						//unit.id = item.ItemId;
						//unit.x = x;
						//unit.y = (_actor.isGrounded)?HXP.height * 0.6:y - height;
						//notifyParent(MsgBoard.CreateUnit, unit);
					//}
				//}
			}
		}
	}
	
	private function startEffect(key:Int = 0, type:Int = 0, ?msg:String,renderType:Int=0):Void 
	{
		var vo:EffectRequest = new EffectRequest();
		vo.Key = key;
		vo.setInfo(this, type,renderType);
		if (msg != null)
			vo.text = msg;
		notifyParent(MsgEffect.Create, vo);
	}
}