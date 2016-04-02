package com.metal.unit.actor.view;

import com.metal.config.UnitModelType;
import com.metal.enums.EffectEnum.EffectAniType;
import com.metal.message.MsgActor;
import com.metal.message.MsgEffect;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.manager.ModelManager;
import com.metal.scene.effect.api.EffectRequest;
import com.metal.unit.actor.api.ActorState.ActionType;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.avatar.AttachTexture;

/**
 * 角色视图控制
 * @author weeky
 */
class ViewItem extends ViewActor
{
	private var _key:Bool;//判断是否骨骼 or xml
	public function new() 
	{
		super();	
	}
	
	override private function Notify_PostBoot(userData:Dynamic):Void
	{
		//判断加载类型
		_actor = owner.getComponent(UnitActor);
		var source:Int = owner.getProperty(MonsterInfo).res;
		//trace(source);
		_info = ModelManager.instance.getProto(source);
		if (_info == null)
			throw "model info is null";
		
		if (_model == null) {
			//骨骼 or xml
			//trace("modelinfo " + _modelInfo);
			_key = _info.type == 2;
			//trace("creat type:"+key);
			//if (_key) {
				//_model = createAvatar();
			//}else {
				//_model = HXP.scene.create(MTAvatar, false);
			//}
		}
		//记录碰撞类型
		//_model.init(owner);
		if(!_key)
			preload();
		notify(MsgActor.PostLoad, this);
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
			type = "solid";
			//播放爆炸特效
			var vo:EffectRequest = new EffectRequest();
			vo.setInfo(this, EffectAniType.Boom1);
			GameProcess.root.notify(MsgEffect.Create, vo);
			
			//停留到死亡后的骨骼 无需循环flase
			setAction(ActionType.dead_1, false);
			//useHitBox = true;
			originY = Std.int(originY * 0.7);
			originX = Std.int(originX * 0.7);
			width = Std.int(width * 1.3);
			//setHitbox(325, 90, 140, 90);
			return;
		}
		
		//trace(" sd destorying");
		_model.as(AttachTexture).frame = 1;
		type = "solid";
	}
}