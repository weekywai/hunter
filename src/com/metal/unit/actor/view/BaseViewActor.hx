package com.metal.unit.actor.view;

import com.haxepunk.Entity;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.HXP;
import com.metal.config.PlayerPropType;
import com.metal.config.UnitModelType;
import com.metal.manager.ResourceManager;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgEffect;
import com.metal.message.MsgStat;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ModelInfo;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.manager.ModelManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.impl.BaseActor;
import com.metal.unit.avatar.MTAvatar;
import com.metal.unit.stat.IStat;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.MsgCore;
import haxe.ds.StringMap;
import openfl.geom.Point;
import pgr.dconsole.DC;


/**
 * 角色视图控制
 * @author weeky
 */
class BaseViewActor extends Component
{
	private var _avatar:MTAvatar;
	private var _curAction:ActionType;
	
	private var _actor:BaseActor;
	public function Actor():BaseActor { return _actor; }
	
	private var _modelInfo:ModelInfo;
	private var _stat:IStat;
	private var _effList:StringMap<TextrueSpritemap>;
	/**武器旋转跟随坐标*/
	private var _targetPos:Point;
	private var _attcking:Bool;
	private var _meleeHit:Bool;
	private var _checkCamera:Bool;
	public function new() 
	{
		super();
		_effList = new StringMap();
		_curAction = none;
		_attcking = false;
		_meleeHit = false;
		_checkCamera = true;
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
	}
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		//if(type==MsgActor.Respawn)
		//trace("respawn");
		switch(type) {
			case MsgCore.PROCESS:
				cmd_PostBoot(userData);
			case MsgActor.EnterBoard:
				Notify_EnterBoard(userData);
			case MsgActor.ExitBoard:
				Notify_ExitBoard(userData);
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
				//trace("Respawn");
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
		//trace("dispose");
		_avatar.dispose();
		_avatar = null;
		_actor = null;
		_stat = null;
		_modelInfo = null;
		_targetPos = null;
		for (key in _effList.keys()) {
			var effect = _effList.get(key);
			effect.destroy();
			_effList.remove(key);
		}
		_effList = null;
		super.onDispose();
	}
	override public function onDraw() 
	{
		if (isDisposed)
			return;
		if (_avatar == null) return;
		if(_checkCamera && !ActorState.IsDestroyed(_actor.stateID)){
			_avatar.active = _avatar.onCamera;
			_avatar.visible = _avatar.onCamera;
		}else {
			_avatar.active = true;
			_avatar.visible = true;
		}
			
		//trace(_actor.x + "::" + _actor.y);
		//actor数据更新后view再更新
		//只有一帧不能loop
		//trace(_actor.stateID);
		setAction(ActorState.GetAction(_actor.stateID));
		_avatar.x = _actor.x;
		_avatar.y = _actor.y;
	}
	
	
	/* entity notify internal component */
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
		trace("Notify_Respawn "+_avatar.type+" owner:"+owner.name);
		_avatar.type = owner.name;
	}
	private function Notify_EffectEnd(userData:Dynamic):Void {
		if (_effList.exists(userData)) {
			var effect = _effList.get(userData);
			_avatar.removeGraphic(effect);
			effect.destroy();
			_effList.remove(userData);
		}
	}
	private function Notify_Injured(userData:Dynamic):Void {
		//trace("injured");
		_avatar.startChangeColor();
	}
	
	private function Notify_Destorying(userData:Dynamic):Void {
		_avatar.type = "";
		_attcking = false;
		//trace("Notify_Destroying");
		//trace("_actor.stateID: "+_actor.stateID);
	}
	private function Notify_Destory(userData:Dynamic):Void {
		_attcking = false;
		if (_actor.isInBoard())
			//HXP.scene.recycle(_avatar);
			HXP.scene.remove(_avatar);
	}

	private function Notify_EnterBoard(userData:Dynamic):Void
	{
		if (ResourceManager.PreLoad) {
			_avatar.visible = true;
			_avatar.active = true;
		}else {
			//DC.beginProfile("add viewactor");
			HXP.scene.add(_avatar);
			//DC.endProfile("add viewactor");
		}
	}
	private function Notify_ExitBoard(userData:Dynamic):Void {
		//HXP.scene.recycle(_avatar);
		HXP.scene.remove(_avatar);
	}
	private function Notify_BornPos(userData:Dynamic):Void
	{
		//trace(_checkCamera);
		_checkCamera = false;
	}
	
	private function cmd_PostBoot(userData:Dynamic):Void
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
		
		_modelInfo = ModelManager.instance.getProto(source);
		
		if (_modelInfo == null)
			throw "model info is null - sourceId:" +source;
		//怪物飞行 
		if(owner.name == UnitModelType.Unit)
			_modelInfo.fly = owner.getProperty(MonsterInfo).ModelType;
		//DC.beginProfile("create");
		if (_avatar == null) {
			//_avatar = cast ResourceManager.instance.getEntity(_modelInfo.res);
			//if (_avatar == null){
				//_avatar = HXP.scene.create(MTAvatar, false);
				_avatar.init(owner);
				_avatar.preload();
			//}else{
				//_avatar.init(owner);
			//}
		}
		//trace(_modelInfo.res+" "+_avatar);
		//记录碰撞类型
		
		
		//DC.endProfile("create");
		//trace(_modelInfo.ID);
		setAction(ActionType.idle_1);
		
		notify(MsgActor.PostLoad, _avatar);
	}
	
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
		_avatar.setDirAction(Std.string(action), _actor.dir, loop);
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
					unit.x = _avatar.x;
					unit.y = _avatar.y - 300;
					notifyParent(MsgBoard.CreateUnit, unit);
				//}else {
					//if (Math.random()*100 <= item.Precent) {
						//unit.simType = UnitModelType.Item;
						//unit.id = item.ItemId;
						//unit.x = _avatar.x;
						//unit.y = (_actor.isGrounded)?HXP.height * 0.6:_avatar.y - _avatar.height;
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
		vo.setInfo(_avatar, type,renderType);
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