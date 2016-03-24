package com.metal.component;

import com.metal.enums.MonsVo;
import com.metal.message.MsgBoard;
import com.metal.message.MsgItr;
import com.metal.message.MsgStartup;
import com.metal.proto.manager.AppearManager;
import com.metal.scene.board.impl.trigger.TriggerComponent;
import com.metal.scene.board.impl.trigger.TriggerType;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;

/**
 * trigger map
 * @author weeky
 */
class TriggerSystem extends Component
{
	private var _events:Array<TriggerComponent>;
	private var _unlockTrigger:TriggerComponent;
	
	public function new() 
	{
		super();
		_events = [];
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
	}
	
	override function onDispose():Void 
	{
		cmd_reset();
		_events = null;
		super.onDispose();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgBoard.CreateTrigger:
				cmd_create(userData);
			case MsgBoard.StartTrigger:
				cmd_start(userData);
			case MsgBoard.AddTrigger:
				cmd_add(userData);
			case MsgStartup.Reset:
				cmd_reset();
		}
		super.onUpdate(type, source, userData);
	}
	
	private function cmd_create(userData:Dynamic):Void
	{
		var tc:TriggerComponent = new TriggerComponent(userData);
		_events.push(tc);
	}
	private function cmd_start(userData:Dynamic)
	{
		setActiveByType(TriggerType.NewBie);
		setActiveByType(TriggerType.ShowMonster);
		setActiveByType(TriggerType.Lock);
		setActiveByType(TriggerType.UnLock);
		setActiveByType(TriggerType.CallMonsters);
		setActiveByType(TriggerType.NorMalLock);
		setActiveByType(TriggerType.VictoryPlace);
		setActiveByType(TriggerType.ShowCameraMonster);
		setActiveByType(TriggerType.ShowRandomMonster);
	}
	
	private function cmd_reset():Void 
	{
		for (comp in _events) 
		{
			(cast comp).dispose();
		}
		_events = [];
		_unlockTrigger = null;
	}
	
	private function cmd_add(userData:Dynamic)
	{
		if (userData.roll)
			setMonsterShow(userData.data);
		else
			setMonsterShowNoB(userData.data);
	}
	
	/**
	 * B段创建怪物出场CP
	 */
	private function setMonsterShow(arr:Array<Array<String>>):Void
	{
		var tempArr:Array <Array<MonsVo>> = new Array();
		//转换arr
		for (temp in arr) {
			tempArr.push(concatArr(temp[2].split("&")));
		}
		var obj = { name:TriggerType.CallMonsters, voInfo:tempArr, showKey:false };
		var tc:TriggerComponent = new TriggerComponent(obj);
		_events.push(tc);
		setActiveByType(TriggerType.CallMonsters);
	}
	
	/**
	 * 非B段创建怪物出场CP
	 */
	private function setMonsterShowNoB(enemies:Array<Int>):Void
	{
		if (_unlockTrigger != null && !_unlockTrigger.isDisposed) {
			trace("add: "+enemies.length);	
			_unlockTrigger.onUpdate(MsgItr.AddLockEnemey, owner, enemies);
		}else {
			trace("new: "+enemies.length);
			var obj = { name:TriggerType.ClearUnLock, arrInfo:enemies, showKey:false };	
			_unlockTrigger = new TriggerComponent(obj);
			owner.addComponent(_unlockTrigger);
		}
	}
	
	/**转换怪物组为详细的怪物列表*/
	private function concatArr(arr:Array<String>):Array<MonsVo> {
		var temp:Array<MonsVo> = new Array();
		var vo:MonsVo;
		for (id in arr) {
			var tempArr:Array<Int> = AppearManager.instance.getProto(Std.parseInt(cast id)).enemies.copy();
			for (monId in tempArr) {
				vo = new MonsVo(monId,Std.parseInt(id));
				temp.push(vo);
			}
		}
		return temp;
	}
	
	/**
	 * 把种类为type的事件cp都添加到En上去
	 * **/
	public function setActiveByType(type:String)
	{
		var itr = _events.iterator();
		//var e = itr.next();
		//var c:Int = 0;
		//while (e != null) {
			//trace("type:"+e.type);
			//e = itr.next();
			//c++;
			//trace("count:"+c);
		//}
		var removeList = [];
		for(trigger in _events)
		{
			//trace(trigger.type+">>"+type);
			if (trigger.type == type) {
				//trace(trigger.type +">>" + _events.length);
				_owner.addComponent(trigger);
				removeList.push(trigger);
			}
		}
		for (i in removeList) 
		{
			_events.remove(i);
		}
	}
}