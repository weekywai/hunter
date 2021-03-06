package com.metal.unit.actor.view;

import com.haxepunk.HXP;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.manager.ResourceManager;
import com.metal.message.MsgActor;
import com.metal.message.MsgEffect;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.manager.ModelManager;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.avatar.MTAvatar;
import com.metal.unit.avatar.TexAvatar;
import de.polygonal.core.event.IObservable;

/**
 * 角色视图控制
 * @author weeky
 */
class ViewItem extends BaseViewActor
{
	private var _info:MonsterInfo;
	private var _key:Bool;//判断是否骨骼 or xml
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
			//骨骼 or xml
			//trace("modelinfo " + _modelInfo);
			_key = _modelInfo.type == 2;
			//trace("creat type:"+key);
			if(_key){
				_avatar = new TexAvatar();
			}else {
				_avatar = HXP.scene.create(MTAvatar, false);
			}
		}
		//记录碰撞类型
		_avatar.init(owner);
		if(!_key)
			_avatar.preload(_modelInfo);
		notify(MsgActor.PostLoad, _avatar);
	}
	
	override function setAction(action:ActionType, loop:Bool = true):Void 
	{
		if (_key) return;//图片资源则跳出
		super.setAction(action, loop);
	}
	
	
	override function Notify_Injured(userData:Dynamic):Void 
	{
		super.Notify_Injured(userData);
		if (_key) return;
		setAction(ActionType.injured_1);
	}
	
	override function Notify_Destory(userData:Dynamic):Void 
	{
		//super.Notify_Destory(userData);
	}
	
	override function Notify_Destorying(userData:Dynamic):Void 
	{
		super.Notify_Destorying(userData);
		if (!_key) {
			_avatar.type = "solid";
			//播放爆炸特效
			var vo:EffectRequest = new EffectRequest();
			vo.setInfo(this._avatar, EffectAniType.Boom1);
			GameProcess.root.notify(MsgEffect.Create, vo);
			
			//停留到死亡后的骨骼 无需循环flase
			setAction(ActionType.dead_1, false);
			//_avatar.useHitBox = true;
			_avatar.originY = Std.int(_avatar.originY * 0.7);
			_avatar.originX = Std.int(_avatar.originX * 0.7);
			_avatar.width = Std.int(_avatar.width * 1.3);
			//_avatar.setHitbox(325, 90, 140, 90);
			return;
		}
		
		//trace(" sd destorying");
		var avatar:TexAvatar = cast(_avatar, TexAvatar);
		avatar.setFrameIndex(1);
		avatar.type = "solid";
	}
}