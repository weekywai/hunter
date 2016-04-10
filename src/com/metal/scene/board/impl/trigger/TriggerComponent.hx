package com.metal.scene.board.impl.trigger;

import com.metal.config.SfxManager;
import com.metal.enums.MonsVo;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgCamera;
import com.metal.message.MsgItr;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.manager.AppearManager;
import com.metal.proto.manager.ModelManager;
import com.metal.proto.manager.MonsterManager;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.board.impl.GameMap;
import com.metal.scene.board.impl.trigger.TriggerType;
import com.metal.unit.actor.api.IActor;
import com.metal.unit.actor.impl.MTActor;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
/**
 * ...
 * @author 3D
 */
class TriggerComponent extends Component
{

	public function new(info:Dynamic) 
	{
		super();
		_info = info;
		type = info.name;
	}
	
	public var type:String = TriggerType.None;
	
	private var _info:Dynamic;//当前事件object
	private var _actor:IActor;
	
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
			case TriggerType.NewBie:
				//trace("id"+_info.custom.resolve("id"));
				key = _actor.x >= _info.x;
				if (key) {
					GameProcess.root.notify(MsgView.NewBie, Std.parseInt(_info.custom.resolve("id")));
					dispose();
				};
			case TriggerType.VictoryPlace:
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
			case TriggerType.ShowMonster:
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
						GameProcess.SendUIMsg(MsgUI.BossPanel, ModelManager.instance.getProto(resID).res);
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
			
			case TriggerType.ShowCameraMonster:
				key = _actor.x >= _info.x;
				if (!key) return;
				notify(MsgBoard.BindHideEntity, {loop:false, random:false});
				//cast(owner.getComponent(GameMap), GameMap).cmd_BindHideEntity(false,false);				
				dispose();
				
			case TriggerType.ShowRandomMonster:
				key = _actor.x >= _info.x;
				if (!key) return;
				notify(MsgBoard.BindHideEntity, {loop:true, random:true});
				//cast(owner.getComponent(GameMap), GameMap).cmd_BindHideEntity(true,true);				
				dispose();
				
			case TriggerType.Lock:
				key = _actor.x >= _info.x;
				//trace(_info.x);
				if (key) {
					notify(MsgCamera.Lock, true);
					
					var id:Int = Std.parseInt(_info.custom.resolve("id"));
					var enemies:Array<Int> = AppearManager.instance.getProto(id).enemies.copy();
					notify(MsgBoard.AddTrigger, {data:enemies, roll:false});
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
				
			case TriggerType.UnLock:
				key = _actor.x >= _info.x;
				if (key) {
					notify(MsgCamera.Lock, false);
					//删掉
					dispose();
				}
			case TriggerType.NorMalLock:
				key = _actor.x >= _info.x;
				if (key) {
					notify(MsgCamera.Lock, true);
					//删掉
					dispose();
				}
			
			case TriggerType.CallMonsters:
				//当前index=0位置的数据长度为0时 移除index0 把切割后的index0怪物数组发出去 
				if (_info != null && Reflect.getProperty(_info, "showKey")) {
					//DC.beginProfile("call monster");
					_info.voInfo.shift();
					if (_info.voInfo.length > 0) {
						notify(MsgBoard.MonsterShow, _info.voInfo[0]);
						//GameProcess.NotifyUI(MsgUIUpdate.UpdateThumb, _info.voInfo.length);
					}else {
						
						var isRunMap = cast(owner.getComponent(GameMap), GameMap).mapData.runKey;
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
			case TriggerType.ClearUnLock:
				//当前index=0位置的数据长度为0时 移除index0 把切割后的index0怪物数组发出去 
				if (_info != null && Reflect.getProperty(_info, "showKey")) {
					//trace("ClearUnLock");
					notify(MsgCamera.Lock, false);
					_info.showKey = false;
					dispose();
				}
		}
		
	}
	
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgItr.Destory:
				cmd_Destory(userData);
			case MsgItr.AddLockEnemey:
				cmd_AddLockEnemey(userData);
		}
	}
	
	/**此方法 只在B段地图控制出场怪物数据的处理*/
	private function cmd_Destory(userData:Dynamic):Void
	{
		if (_info == null) return;
		var id:Int = userData.id;
		switch(type){
			case TriggerType.CallMonsters:
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
			case TriggerType.ClearUnLock:
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
		if (type == TriggerType.ClearUnLock){
			_info.arrInfo = _info.arrInfo.concat(userData);
			trace("add lock: "+_info.arrInfo.length);
		}
	}
	
	/**把添加的怪物组id塞到怪物列表中
	 * 用于判断是否杀光当前地图所有怪物过关
	 * **/
	public function addMonsterInEnemies(arr:Array<Int>):Void
	{
		var battle = owner.getComponent(BattleResolver);
		for (id in arr) {
			battle._gameMap.enemies.push(id);
		}
	}
}