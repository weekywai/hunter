package com.metal.scene.trigger;

import com.metal.component.BattleComponent;
import com.metal.config.SfxManager;
import com.metal.enums.MonsVo;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgCamera;
import com.metal.message.MsgInput;
import com.metal.message.MsgItr;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.component.GameSchedual;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.manager.AppearManager;
import com.metal.proto.manager.ModelManager;
import com.metal.proto.manager.MonsterManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.map.GameMap;
import com.metal.unit.actor.api.IActor;
import com.metal.unit.actor.impl.MTActor;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import pgr.dconsole.DC;

/**
 * ...
 * @author 3D
 */
class TriggerComponent extends Component
{

	public function new(info:Dynamic,trigger:Trigger) 
	{
		super();
		_info = info;
		_trigger = trigger;
		type = info.name;
	}
	
	public var type:String = "-1";
	
	private var _info:Dynamic;//当前事件object
	private var _trigger:Trigger;
	private var _actor:IActor;
	
	
	public function setActive():Void
	{
		_trigger.owner.addComponent(this);
	}
	
	public function add(trigger:Trigger):Void
	{
		this._trigger = trigger;
	}
	
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = cast PlayerUtils.getPlayer().getComponent(MTActor);
	}
	
	
	
	override function onDispose():Void 
	{
		super.onDispose();
		_info = null;
		_actor = null;
	}
	
	override public function onTick(timeDelta:Float) 
	{
		super.onTick(timeDelta);
		decide();
	}
	
	
	/**
	 * 判断当前事件类型是否满足条件作相应处理
	 * 2：锁屏 角色x
	 * 3：解锁
	 * **/
	private function decide():Void {
		if (_actor == null) return;
		var key:Bool;
		switch (_info.name) {
			case TriggerEventType.NewBie:
				//trace("id"+_info.custom.resolve("id"));
				key = _actor.x >= _info.x;
				if (key) {
					GameProcess.root.notify(MsgView.NewBie, Std.parseInt(_info.custom.resolve("id")));
					dispose();
				};
			case TriggerEventType.VictoryPlace:
				//trace("id"+_info.custom.resolve("id"));
				key = _actor.x >= _info.x;
				if (key) {
					trace("VictoryPlace: Please find and code here!");
					//直接胜利
					SfxManager.playBMG(BGMType.Victory);
					PlayerUtils.getPlayer().notify(MsgActor.Victory);
					GameProcess.root.notify(MsgStartup.BattleClear);
					dispose();
				};
			case TriggerEventType.ShowMonster:
				key = _actor.x >= _info.x;
				if (!key) return;
				if (_info.custom.resolve("type") != null) {
					//trace("type::" + _info.custom.resolve("type"));
					if (_info.custom.resolve("type") == "boss") {
						var id = _info.custom.resolve("id");
						var enemies = AppearManager.instance.getProto(Std.parseInt(id)).enemies.copy();
						var obj = { "monsters":enemies, "groupId": id};
						//addMonsterInEnemies(obj.monsters);
						notify(MsgBoard.BossShow, obj);
						//TODO 怪物或角色
						//PlayerUtils.getPlayer().notify(MsgInput.SetInputEnable, true);
						var resID = MonsterManager.instance.getInfo(obj.monsters[0]).res;
						GameProcess.UIRoot.notify(MsgUI.BossPanel, ModelManager.instance.getProto(resID).res);
					}
				}else {
					var id = Std.parseInt(_info.custom.resolve("id"));
					trace("ShowMonster :"+id);
					var enemies = AppearManager.instance.getProto(id).enemies.copy();
					var enemiesVO:Array<MonsVo> = [];
					//转换arr
					for (monId in enemies) {
						var vo:MonsVo = new MonsVo(monId, id);
						enemiesVO.push(vo);
					}
					notify(MsgBoard.MonsterShow, enemiesVO);
				}
				dispose();
			
			case TriggerEventType.ShowCameraMonster:
				key = _actor.x >= _info.x;
				if (!key) return;
				notify(MsgBoard.BindHideEntity, {loop:false, random:false});
				//cast(owner.getComponent(GameMap), GameMap).cmd_BindHideEntity(false,false);				
				dispose();
				
			case TriggerEventType.ShowRandomMonster:
				key = _actor.x >= _info.x;
				if (!key) return;
				notify(MsgBoard.BindHideEntity, {loop:true, random:true});
				//cast(owner.getComponent(GameMap), GameMap).cmd_BindHideEntity(true,true);				
				dispose();
				
			case TriggerEventType.Lock:
				key = _actor.x >= _info.x;
				//trace(_info.x);
				if (key) {
					owner.notify(MsgCamera.Lock, true);
					
					var id:Int = Std.parseInt(_info.custom.resolve("id"));
					var enemies:Array<Int> = AppearManager.instance.getProto(id).enemies.copy();
					_trigger.setMonsterShowNoB(enemies);
					var enemiesVO:Array<MonsVo> = [];
					//转换arr
					for (monId in enemies) {
						var vo:MonsVo = new MonsVo(monId, id);
						enemiesVO.push(vo);
					}
					trace("Lock ShowMonster:" +id+""+enemies);
					notify(MsgBoard.MonsterShow, enemiesVO);

					//删掉
					dispose();
				}
				
			case TriggerEventType.UnLock:
				key = _actor.x >= _info.x;
				if (key) {
					owner.notify(MsgCamera.Lock, false);
					//删掉
					dispose();
				}
			case TriggerEventType.NorMalLock:
				key = _actor.x >= _info.x;
				if (key) {
					owner.notify(MsgCamera.Lock, true);
					//删掉
					dispose();
				}
			
			case TriggerEventType.CallMonsters:
				//当前index=0位置的数据长度为0时 移除index0 把切割后的index0怪物数组发出去 
				if (_info != null && Reflect.getProperty(_info, "showKey")) {
					//DC.beginProfile("call monster");
					_info.voInfo.shift();
					if (_info.voInfo.length > 0) {
						notify(MsgBoard.MonsterShow, _info.voInfo[0]);
						//GameProcess.UIRoot.notify(MsgUIUpdate.UpdateThumb, _info.voInfo.length);
					}else {
						
						var isRunMap = cast(owner.getComponent(GameMap), GameMap).mapData.runKey;
						//_trigger.owner.removeComponent(this);
						if(isRunMap){
							trace("Send Victory");
							PlayerUtils.getPlayer().notify(MsgActor.Victory);
						}
						GameProcess.root.notify(MsgStartup.BattleClear);
						dispose();
						return;
					}
					_info.showKey = false;
					//DC.endProfile("call monster");
				}
			case TriggerEventType.ClearUnLock:
				//当前index=0位置的数据长度为0时 移除index0 把切割后的index0怪物数组发出去 
				if (_info != null && Reflect.getProperty(_info, "showKey")) {
					//trace("ClearUnLock");
					notifyParent(MsgCamera.Lock, false);
					_info.showKey = false;
					//_trigger.owner.removeComponent(this);
					dispose();
				}
		}
		
	}
	
	
	override public function onNotify(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onNotify(type, source, userData);
		switch(type) {
			case MsgItr.Destory:
				cmd_Destory(userData);
			case MsgItr.AddLockEnemey:
				cmd_AddLockEnemey(userData);
		}
	}
	
	/**此方法 只在B段地图控制出场怪物数据的处理*/
	private function cmd_Destory(id:Int):Void
	{
		if (_info == null) return;
		switch(type){
			case TriggerEventType.CallMonsters:
				if (_info.voInfo[0].length == null) return;
				for (num in 0..._info.voInfo[0].length) {
					if (_info.voInfo[0][num].id == id) {
						if (_info.voInfo[0].length == 1) {
							_info.voInfo[0].remove(id);
							_info.showKey = true;
							break;
						}else {
							_info.voInfo[0].remove(_info.voInfo[0][num]);
							break;
						}
					}
				}
			case TriggerEventType.ClearUnLock:
				trace(_info.arrInfo.length);
				_info.arrInfo.remove(id);
				if (_info.arrInfo.length == 0) {
					_info.showKey = true;
					return;
				}
				//if (_info.arrInfo.length == 1) {
					//_info.showKey = true;
				//}
				
		}
	}
	
	private function cmd_AddLockEnemey(userData):Void
	{
		if (type == TriggerEventType.ClearUnLock){
			_info.arrInfo = _info.arrInfo.concat(userData);
			trace("add lock: "+_info.arrInfo.length);
		}
	}
	
	/**把添加的怪物组id塞到怪物列表中
	 * 用于判断是否杀光当前地图所有怪物过关
	 * **/
	public function addMonsterInEnemies(arr:Array<Int>):Void
	{
		var battle = _trigger.owner.getComponent(BattleResolver);
		for (id in arr) {
			battle._gameMap.enemies.push(id);
		}
		
	}
}