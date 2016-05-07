package com.metal.unit.stat;
import com.metal.message.MsgActor;
import com.metal.message.MsgItr;
import com.metal.message.MsgStat;
import com.metal.proto.impl.MonsterInfo;
import com.metal.proto.impl.SkillInfo;
import com.metal.proto.manager.BuffManager;
import com.metal.proto.manager.ScoreManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.api.IActor;
import com.metal.unit.actor.impl.UnitActor;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import haxe.ds.IntMap;
import pgr.dconsole.DC;

/**
 * 角色状态管理(Buff)
 * @author weeky
 */
class UnitStat extends Component implements IStat
{
	public var hpMax(default, null):Int;
	public var hp(default, null):Int;
	private var _damageModify:Array<Int>;
	public function damageModify():Array<Int> { return _damageModify; };
	public var atk(default, null):Int;
	public var speedAdd(default, null):Float = 1;
	public var shootspanAdd(default, null):Float = 1;
	public function findStatusByKey(key:Int):Buff {
		if (_buffs.exists(key)) {
			var list = _buffs.get(key);
			//默认返回首个技能
			return untyped list.head.val;
		}
		return null;
	}
	private var _holdFire:Bool=false;
	public var holdFire(get, set):Bool;
	private function get_holdFire():Bool{return _holdFire;}
	private function set_holdFire(value:Bool):Bool
	{
		_holdFire = value;
		return _holdFire;
	}
	// Buff
	private var _buffs:IntMap<List<Buff>>;
	public function MyBuff():Array<Buff> { return null; }
	public function ScoreRate():Float { return 1; }
	private var _actor:IActor;
	private var _info:MonsterInfo;
	
	public function new() 
	{
		super();
		_buffs = new IntMap();
	}
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = owner.getComponent(UnitActor);
		_info = owner.getPropertyByCls(MonsterInfo);
		hpMax = _info.MaxHp;
		hp = _info.MaxHp;
		//trace(hp + ">>" + hpMax);
		atk = _info.Atk;
		var skill:SkillInfo = owner.getPropertyByCls(SkillInfo);
		if(skill != null)
			_damageModify = skill.Effect;
	}
	
	override function onDispose():Void 
	{
		for (key in _buffs.keys()) 
		{
			var list = _buffs.get(key);
			for (buff in list.iterator()) 
			{
				buff.dispose();
			}
			list.clear();
			_buffs.remove(key);
		}
		_info = null;
		_buffs = null;
		_damageModify = null;
		super.onDispose();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgActor.Injured:
				cmd_Injured(userData);
			case MsgStat.AddSubStatus:
				cmd_AddSubStatus(userData);
			case MsgStat.RemoveSubStatus:
				cmd_RemoveSubStatus(userData);
			case MsgStat.ChangeSpeed:
				cmd_ChangeSpeed(userData);
		}
	}
	
	private function cmd_ChangeSpeed(userData:Dynamic):Void
	{
		trace("setp1");
		speedAdd = userData[0];
		shootspanAdd = userData[1];
	}
	
	private function cmd_AddSubStatus(userData:Dynamic):Void
	{
		addSubStatus(userData);
	}
	private function cmd_RemoveSubStatus(userData:Dynamic):Void
	{
		var buff:Buff = userData;
		if (_buffs.exists(buff.kind)) {
			var buffs:List<Buff> = _buffs.get(buff.kind);
			buffs.remove(buff);
			buff.dispose();
		}
	}
	
	private function cmd_Injured(userData:Dynamic):Void
	{
		hp = Std.int(hp - userData.damage);
		if (ActorState.IsDestroyed(_actor.stateID)){
			trace("IsDestroyed");
			return;
		}
		//trace(hp + ">>" + userData);
		if (hp <= 0) {
			var score:Int = ScoreManager.instance.getInfo(_info.ScoreType).Score;
			//trace("score " + _socre + " rate: "+targetStat.ScoreRate());
			score = Math.round(score * ScoreRate());
			GameProcess.root.notify(MsgItr.Score, score);
			if (_actor.faction == BoardFaction.Boss || _actor.faction == BoardFaction.Boss1) {
				GameProcess.root.notify(MsgItr.KillBoss);
			}
			DC.log(owner.name + " Destroyed hp: " + hp + " score: "+score);
			notify(MsgActor.Destroying);
		}
	}
	
	private function addHp(hp:Int, hpMod:Int):Void
	{
		var changeHp:Int = hpMod;
		if (hp < 0) {
			changeHp = Std.int(-(Math.abs(changeHp) - Math.abs(hp)));
			hp = 0;
		}
		if (hp > hpMax) hp = hpMax;
	}
	
	private function addSubStatus(userData:Dynamic):Void
	{
		var statInfo:StatInfo = new StatInfo();
		
		statInfo.buffInfo = BuffManager.instance.getProto(userData.id);
		//trace(userData.id+" "+statInfo.buffInfo);
		statInfo.time = userData.time;
		statInfo.stat = this;
		if(userData.hp!=null)
			statInfo.damage = userData.hp;
		
		/**队列记录buff*/
		var overlaps:List<Buff>;
		var buff:Buff;
		if (_buffs.exists(statInfo.buffInfo.kind)) {
			overlaps = _buffs.get(statInfo.buffInfo.kind);
			if (overlaps.length > statInfo.buffInfo.overlap){
				buff = overlaps.pop();
				buff.dispose();
			} 
			overlaps.add(createBuff(statInfo));
		} else {
			overlaps = new List<Buff>();
			overlaps.add(createBuff(statInfo));
			_buffs.set(statInfo.buffInfo.kind, overlaps);
		}
	}
	private function createBuff(info:StatInfo):Buff
	{
		var buff = new Buff();
		buff.initInfo(info);
		owner.addComponent(buff);
		return buff;
	}
}