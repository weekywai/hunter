package com.metal.unit.bevtree.data;

import com.metal.unit.bevtree.BevNodeInputParam;
import openfl.geom.Point;

/**
 * 输入数据
 * @author li
 */
class MonsterInputData extends BevNodeInputParam
{
	public var CurrentAttackTimes:Float; 	//当前攻击次数
	public var MaxAttackTimes:Float; 		//最大攻击上限
	public var CurrentAppearTimes:Float; 	//当前出场时间
	public var MaxAppearTimes:Float; 		//最大出场时间上限
	public var WarningRadius:Float; 		//警戒范围
	public var AttackingRadius:Float; 		//攻击范围
	public var MaxHp:Float; 				//最大血量
	public var CurrentHP:Float; 			//当前血量
	public var TargetPoint:Point; 			//目标坐标
	public var AttackMelee:Bool; 			//近身攻击
	public var SelfPoint:Point; 			//自身坐标
	public var BornPoint:Point;				//出生点
	public var isPatrol:Int; 				//是否具备巡逻属性 1:站桩 2:巡逻
	public var isEscape:Int;				//是否具备逃跑属性 1:不逃跑 2:逃跑
	public var CurrentStatus:String;		//怪物当前状态
	public var isFirstIn05:Bool;			//生命值第一次处于生命值上限0%-5%之间(不包含0%，0%时死亡)
	public var isFirstIn20:Bool;			//生命值第一次处于生命值上限5%-20%之间
	public var isFirstIn40:Bool;			//生命值第一次处于生命值上限20%-40%之间
	public var isFirstIn60:Bool;			//生命值第一次处于生命值上限40%-60%之间
	public var isFirstIn80:Bool;			//生命值第一次处于生命值上限60%-80%之间
	public var isSummon1:Bool;				//是否释放过召唤1
	public var isSummon2:Bool;				//是否释放过召唤2
	public var isSummon3:Bool;				//是否释放过召唤3
	public var BaseAttackTime:Float;		//攻击间隔
	public var isOnAttackStatus:Bool;		//是否在攻击状态
	public var BaseIdleTime:Float;			//待机间隔
	public var isOnIdleStatus:Bool;			//是否在待机状态
	public var BaseMoveTime:Float;			//移动时间
	public var Victory:Bool;				//胜利状态
	
	public function new() 
	{
		super();
		initData();
	}
	
	private function initData():Void
	{
		CurrentAttackTimes = 0; 	
		MaxAttackTimes = 0; 		
		CurrentAppearTimes = 0; 	
		MaxAppearTimes = 0; 		
		WarningRadius = 0; 		
		AttackingRadius = 0; 		
		MaxHp = 0; 				
		CurrentHP = 0; 			
		TargetPoint = null; 			
		SelfPoint = null; 			
		isPatrol = 0; 				
		isFirstIn05 = false;				
		isFirstIn20 = false;				
		isFirstIn40 = false;	
		isFirstIn60 = false;
		isFirstIn80 = false;
		isSummon1 = false;				
		isSummon2 = false;				
		isSummon3 = false;	
		BaseAttackTime = 0;
		isOnAttackStatus = false;
		BaseMoveTime = 0;
	}
	
}