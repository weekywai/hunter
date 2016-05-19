package com.metal.unit.actor.view;

import com.haxepunk.HXP;
import com.haxepunk.graphics.TextrueSpritemap;
import com.metal.config.MapLayerType;
import com.metal.config.PlayerPropType;
import com.metal.config.UnitModelType;
import com.metal.manager.ResourceManager;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgEffect;
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
		layer = MapLayerType.ActorLayer;
		_effList = new StringMap();
		_curAction = none;
		_attcking = false;
		_meleeHit = false;
	}
	
	override public function onDispose():Void 
	{
		_info = null;
		_model = null;
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
		//if (_enterboard)
			//trace("update");
		super.update();
		if (isDisposed || _isFree)
			return;
		if (graphic != null) {
			graphic.active = graphic.visible = onCamera;
			//可能需要放出此判断
			//if (graphic.active)
				//setAction(ActorState.GetAction(_actor.stateID));
		}
			
		//trace(_actor.x + "::" + _actor.y);
		//actor数据更新后view再更新
		//只有一帧不能loop
		//trace(_actor.stateID);
		setAction(ActorState.GetAction(_actor.stateID));
		x = _actor.x;
		y = _actor.y;
	}
//{Notify
	/* entity notify internal component */
	override function Notify_PostBoot(userData:Dynamic) 
	{
		//判断加载类型
		var source:Int;
		switch(owner.name) {
			case UnitModelType.Player:
				source = PlayerUtils.getInfo().data.ROLEID;
			case UnitModelType.Vehicle:
				source = PlayerUtils.getInfo().vehicle;
			case UnitModelType.Unit,UnitModelType.Boss,UnitModelType.Elite:
				source = owner.getPropertyByCls(MonsterInfo).res;
			//case UnitModelType.Npc:
				//source = owner.getProperty(MonsterInfo).res;
			default:
				throw " modelInfo is null - sourceId:" + owner.name;
		}
		
		_info = ModelManager.instance.getProto(source);
		//怪物飞行 
		if(owner.name == UnitModelType.Unit)
			_info.fly = owner.getPropertyByCls(MonsterInfo).ModelType;
		preload();
		setAction(ActionType.idle_1);
		
		notify(MsgActor.PostLoad, this);
	}
	
	override function Notify_FREE(userData:Dynamic):Void { 
		super.Notify_FREE(userData); 
		if(scene!=null)
			scene.remove(this);
	}
	override function Notify_Respawn(userData:Dynamic):Void {
		trace("Notify_Respawn owner:"+owner.name);
		type = owner.name;
	}
	override function Notify_EffectEnd(userData:Dynamic):Void {
		if (_effList.exists(userData)) {
			var effect = _effList.get(userData);
			removeGraphic(effect);
			effect.destroy();
			_effList.remove(userData);
		}
	}
	
	override function Notify_Destorying(userData:Dynamic):Void {
		type = "";
		_attcking = false;
		//trace("Notify_Destroying");
		//trace("_actor.stateID: "+_actor.stateID);
	}
	override function Notify_Destory(userData:Dynamic):Void {
		_attcking = false;
		if (_actor.isInBoard() && scene!=null)
			//scene.recycle(this);
			scene.remove(this);
	}
	
	private var _enterboard:Bool = false;
	override function Notify_EnterBoard(userData:Dynamic):Void
	{
		if (ResourceManager.PreLoad) {
			visible = true;
			active = true;
		}else {
			//trace("EnterBoard" + x);
			//_enterboard = true;
			HXP.scene.add(this);
		}
	}
//}
	
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
				//trace(item.ID+">>"+item.Precent);
				//if (item.Precent == 100) {
					unit.simType = UnitModelType.DropItem;
					unit.id = item.ItemId;
					unit.x = x;
					unit.y = y - 100;
					notifyParent(MsgBoard.CreateUnit, unit);
				//}else {
					//if (Math.random()*100 <= item.Precent) {
						//unit.simType = UnitModelType.Item;
						//unit.id = item.ID;
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
		vo.setInfo(this, type, renderType);
		if (msg != null)
			vo.text = msg;
		notifyParent(MsgEffect.Create, vo);
	}
}
class EffConfig {
	/** offset x */
	public var ox:Float = 0;
	/** offset y */
	public var oy:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var loop:Bool = true;
	public var angle:Float = 0;
	public var frameRate:Int = 30;
	public var name:String = "";
	
	public function new () {}
}