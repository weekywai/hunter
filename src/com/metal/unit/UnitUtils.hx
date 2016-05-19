package com.metal.unit;
import com.metal.component.GameSchedual;
import com.metal.message.MsgActor;
import com.metal.scene.board.api.BoardFaction;
import de.polygonal.core.sys.SimEntity;
import de.polygonal.core.time.Timebase;
import openfl.Lib;
import pgr.dconsole.DC;

/**
 * ...
 * @author weeky
 */
class UnitUtils
{
	/**
	 * 创建单元
	 */
	private static var _lastUintTime:Float = .0;
	private static var _index:Int =0;
	public static function createUnit(type:String, id:Int, faction:Int, x:Float, y:Float, ai:String = null):SimEntity {
		//var now = Lib.getTimer();
		//DC.beginProfile("createUnit");
		var manager:GameSchedual = GameProcess.instance.getComponent(GameSchedual);
		//trace(id+">>"+type);
		var entity:SimEntity = manager.createSimEntity(type, id);
		_index++;
		entity.keyId = _index;
		entity.notify(MsgActor.InitFaction, {"faction":faction, "id":id});
		// 更新位置
		entity.notify(MsgActor.PosForceUpdate, {"x":x, "y":y});
		// 更新动作
		entity.notify(MsgActor.Stand);
		// 初始化AI
		if(ai!=null)
			entity.notify(MsgActor.InitAI, ai);
		
		//_lastUintTime = now - _lastUintTime;
		//trace(_lastUintTime);
		//DC.endProfile("createUnit");
		return entity;
	}
	
	public static function createDropItem(type:String, id:Int, faction:Int, x:Float, y:Float):SimEntity {
		var manager:GameSchedual = GameProcess.instance.getComponent(GameSchedual);
		var entity:SimEntity = manager.createSimEntity(type, id);
		entity.notify(MsgActor.InitFaction, {"faction":faction, "id":id});
		// 更新位置
		entity.notify(MsgActor.PosForceUpdate, { "x":x, "y":y } );
		
		return entity;
	}
	
	public static function createNPC(type:String, id:Int, faction:Int, x:Float, y:Float):SimEntity {
		var manager:GameSchedual = GameProcess.instance.getComponent(GameSchedual);
		var entity:SimEntity = manager.createSimEntity(type, id);
		entity.notify(MsgActor.InitFaction, {"faction":faction, "id":id});
		// 更新位置
		entity.notify(MsgActor.PosForceUpdate, { "x":x, "y":y } );
		
		return entity;
	}
	
}