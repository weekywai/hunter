package com.metal.scene.trigger;

import com.metal.enums.MonsVo;
import com.metal.message.MsgItr;
import com.metal.proto.manager.AppearManager;
import de.polygonal.core.sys.SimEntity;

/**
 * 地图事件层信息存储
 * @author 3D
 */
class Trigger
{
	public var events(default, null):Array<TriggerComponent>;
	public var owner:SimEntity;
	public var UnlockTrigger:TriggerComponent;
	
	public function new(e:SimEntity) 
	{
		owner = e;
		events = [];
	}

	/**
	 * B创建怪物出场CP
	 */
	public function setMonsterShow(arr:Array<Array<String>>):Void
	{
		var tempArr:Array <Array<MonsVo>> = new Array();
		//转换arr
		for (temp in arr) {
			tempArr.push(concatArr(temp[2].split("&")));
		}
		var obj = { name:TriggerEventType.CallMonsters, voInfo:tempArr, showKey:false };
		var tc:TriggerComponent = new TriggerComponent(obj, this);
		events.push(tc);
		setActiveByType(TriggerEventType.CallMonsters);
	}
	
	/**
	 * 非B创建怪物出场CP
	 */
	public function setMonsterShowNoB(enemies:Array<Int>):Void
	{
		if (UnlockTrigger != null && !UnlockTrigger.isDisposed) {
			trace("add: "+enemies.length);	
			UnlockTrigger.onNotify(MsgItr.AddLockEnemey, owner, enemies);
		}else {
			trace("new: "+enemies.length);
			var obj = { name:TriggerEventType.ClearUnLock, arrInfo:enemies, showKey:false };	
			UnlockTrigger = new TriggerComponent(obj, this);
			UnlockTrigger.setActive();
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
		var itr = events.iterator();
		//var e = itr.next();
		//var c:Int = 0;
		//while (e != null) {
			//trace("type:"+e.type);
			//e = itr.next();
			//c++;
			//trace("count:"+c);
		//}
		var removeList = [];
		for(trigger in events)
		{
			//trace(trigger.type+">>"+type);
			if (trigger.type == type) {
				//trace(trigger.type +">>" + events.length);
				trigger.setActive();
				removeList.push(trigger);
			}
		}
		for (i in removeList) 
		{
			events.remove(i);
		}
	}
	
	
	public function parseEvent(obj:Dynamic):Void
	{
		var tc:TriggerComponent = new TriggerComponent(obj, this);
		events.push(tc);
	}
	
	public function reset():Void 
	{
		for (comp in events) 
		{
			(cast comp).dispose();
		}
		events = [];
		UnlockTrigger = null;
	}
	
}