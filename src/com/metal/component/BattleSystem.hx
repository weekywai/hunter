package com.metal.component;
import com.haxepunk.HXP;
import com.metal.config.BattleGradeConditionType;
import com.metal.config.PlayerPropType;
import com.metal.config.RoomMissionType;
import com.metal.manager.ResourceManager;
import com.metal.message.MsgBoard;
import com.metal.message.MsgItr;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.proto.impl.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.DuplicateInfo;
import com.metal.proto.impl.GradeConditionInfo;
import com.metal.proto.manager.GradeConditionManager;
import com.metal.proto.manager.MapInfoManager;
import com.metal.utils.effect.Animator;
import com.metal.utils.effect.component.EffectType;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import haxe.Timer;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import motion.Actuate;


/**
 * ...
 * @author li
 */
class BattleSystem extends Component
{

	/**宝箱数量*/
	private var _chestNum(default, default):Int; 
	/**副本信息*/
	private var _duplicateInfo:DuplicateInfo;
	/**该副本的房间列表*/
	private var _roomArray:Array<String>;
	private var _finishRoom:StringMap<Bool>;
	/**副本进度**/
	private var _curMap:Int = 0;
	public var curMap(get, null):Int;
	private function get_curMap():Int
	{
		return _curMap;
	}
	private var _endGame:Bool = false;
	private var _talks:IntMap<Array<String>>;
	//分数
	public var _socre:Int;
	public function Score():Int {
		return _socre;
	}
	//杀boss数
	public var _totalKillBoss:Int;
	public function TotalKillBoss():Int {
		return _totalKillBoss;
	}
	private var _clear:Bool;
	
	/**倒计时的显示文档*/
	private var _countDown:Int;
	private var _timer:Timer;
	private var _usedtime:Int;
	private var _pauseTimerCount:Bool;
	
	/**生存关产怪时间间隔*/
	private var buildSpace:Int = 5;
	/**任务类型*/
	private var _missionType:Int;
	
	/**暂停战斗计时*/
	public function setPauseCountDown(pause:Bool)
	{
		//trace("setPauseCountDown");
		_pauseTimerCount = pause;
	}
	/**战斗倒计时*/
	private function setCountDown()
	{
		_pauseTimerCount = false;
		_countDown = _duplicateInfo.TimeLimit;
		_usedtime = 0;
		_missionType = MapInfoManager.instance.getRoomInfo(Std.parseInt(currentRoomId())).MissionType;
		//trace("_countDown: "+_countDown);
		//-1为无限时间
		//trace("_countDown: "+_countDown);
		if (_countDown!=-1) {
			_timer = new Timer(1000);
			_timer.run = function() {
				//trace("runOnce");
				if (!GameProcess.instance.isPausing() && !_pauseTimerCount) {	
					//trace("timer running");		
					GameProcess.NotifyUI(MsgUIUpdate.UpdateCountDown, _countDown);
					_countDown--;
					_usedtime++;
					//if (_usedtime % buildSpace==0 && _missionType==RoomMissionType.Survive)
					if (_missionType==RoomMissionType.Survive)
					{
						notify(MsgBoard.BindHideEntity, {loop:false, random:true});
					}					
				}
			}			
		}
	}
	private function disposeTimer()
	{
		trace("disposeTimer");
		if (_timer != null) 
		{
			_timer.stop();
			_timer = null;
		}
	}
	
	/**获取当前房间ID*/
	public function currentRoomId():String
	{
		return _roomArray[_curMap];
	}
	
	public function currentStage():DuplicateInfo
	{
		return _duplicateInfo;
	}
	public function BuffRate():Float
	{
		return _duplicateInfo.BuffRate;
	}
	
	public function new() 
	{
		super();
		
		_roomArray = new Array();
		_finishRoom = new StringMap();
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		super.onUpdate(type, source, userData);
		switch(type) {
			case MsgStartup.GameInit:
				cmd_GameInit(userData);
			case MsgStartup.FinishMap:
				cmd_FinishMap(userData);
			case MsgStartup.TransitionMap:
				cmd_TransitionMap(userData);
			case MsgStartup.Finishbattle:
				cmd_Finishbattle(userData);
			case MsgStartup.BattleClear:
				cmd_BattleClear(userData);
			case MsgItr.Score:
				cmd_Score(userData);
			case MsgItr.KillBoss:
				cmd_KillBoss(userData);
			case MsgStartup.NewBieGame:
				cmd_NewBieGame(userData);
			case MsgStartup.Start:
				cmd_Start(userData);
			case MsgStartup.PauseCountDown:
				setPauseCountDown(userData);
		}
	}
	/**切换场景**/
	private function changeMap():Void
	{
		notifyDirect("GameBoard", MsgStartup.Reset);
		HXP.scene.end();
		if (_clear){
			ResourceManager.instance.unLoadAll();
			_clear = false;
		}
		GameProcess.SendUIMsg(MsgUI.BossPanel);
		GameProcess.NotifyUI(MsgUIUpdate.StartBattle|MsgStartup.Start);
		notifyDirect("GameBoard",MsgStartup.Start);
		
		_missionType = MapInfoManager.instance.getRoomInfo(Std.parseInt(currentRoomId())).MissionType;		
	}
	var conditionTypeArr:Array<Int>;
	var conditionArr:Array<String>;
	/**通关评级条件*/
	private function findGradeCondition(duplicateInfo:DuplicateInfo)
	{
		if (duplicateInfo==null) 
		{
			//trace("_duplicateInfo==null");
			return;
		}
		var gradeCondition:GradeConditionInfo;
		conditionTypeArr = new Array();
		conditionArr = new Array();
		for (i in duplicateInfo.GradeCondition) 
		{
			gradeCondition = GradeConditionManager.instance.getGradeConditionInfo(Std.parseInt(i));
			conditionTypeArr.push(gradeCondition.ConditionType);
			conditionArr.push(gradeCondition.Condition);
		}
	}
	
	/**通关评级*/
	private function rate(data:Dynamic):Int
	{
		var rateStarNum:Int = 0;
		var reachArr:Array<Bool> = new Array();
		var hpPercent:Float = data.hp;
		var rebornTime:Int = data.times;
		for (i in 0...conditionTypeArr.length) 
		{
			switch (conditionTypeArr[i]) 
			{
				case BattleGradeConditionType.Hp:
					reachArr.push(hpPercent > Std.parseFloat(conditionArr[i]));
				case BattleGradeConditionType.RebornTime:
					reachArr.push(rebornTime < Std.parseInt(conditionArr[i]));
				case BattleGradeConditionType.TimeCost:
					reachArr.push(_usedtime < Std.parseInt(conditionArr[i]));					
				default:	
					trace("There is no this type, please check the xml");
			}
			if (reachArr[i]) rateStarNum++;
		}		
		trace("reachArr: " + reachArr);
		notify(MsgStartup.UpdateStar, { mapId:_duplicateInfo.Id, starNum:rateStarNum } );	
		return rateStarNum;
	}
	private function cmd_GameInit(userData:Dynamic):Void {
		_endGame = false;
		_clear = false;
		_duplicateInfo = userData;
		_roomArray = _duplicateInfo.RoomId;
		for (i in _roomArray) 
		{
			_finishRoom.set(i, false);
		}
		
		_talks = new IntMap();
		if (_duplicateInfo.DuplicateType != 9) {
			if(_duplicateInfo.BossFeatures!=""){
				var ary = _duplicateInfo.BossFeatures.split("|");
				for (j in 0...ary.length) 
				{
					_talks.set(j, ary[j].split("&"));
				}
				//0:start 1:end
			}
		}
		_curMap = 0;
		_totalKillBoss = 0;
		_socre = 0;
		
		
		var info:PlayerInfo = PlayerUtils.getInfo();
		var hpMax = info.data.MAX_HP;
		var mpMax = info.data.MAX_MP;
		info.data.HP = hpMax;
		info.data.MP = mpMax;
		Animator.start(this, "", EffectType.OPEN, null, true, startGame);
		GameProcess.instance.startGame();
		notifyDirect("GameBoard",MsgStartup.Reset);
		GameProcess.NotifyUI(MsgUIUpdate.StartBattle);
		notifyDirect("GameBoard",MsgStartup.Start);
		setCountDown();
		findGradeCondition(_duplicateInfo);
	}
	private function startGame()
	{
		//	notifyRoot(MsgView.NewBie, 6);
		//trace("cmd_GameInit: " + _duplicateInfo.DuplicateType);
		if (_duplicateInfo.DuplicateType != 9) {
			GameProcess.SendUIMsg(MsgUI2.InitThumb, _roomArray.length);
		}
		Actuate.tween(this, 0.5, { } ).onComplete(GameProcess.root.notify, [MsgView.NewBie, 6]);
	}
	private function cmd_FinishMap(userData:Dynamic):Void
	{
		if (_finishRoom.exists(userData)) {
			_finishRoom.remove(userData);
			_finishRoom.set(userData, true);
		}
		//for (key in _finishRoom.keys()) 
		//{
			//if (!_finishRoom.get(key))
				//
		//}
	}
	
	private function cmd_Finishbattle(userData:Dynamic)
	{
		if (_endGame) return;
		_endGame = true;
		GameProcess.instance.endGame();
		disposeTimer();
		//GameProcess.SendUIMsg(MsgUI.BattleResult, userData);//胜利界面
		//GameProcess.SendUIMsg(MsgUI.BattleFailure, userData);//失败
	}
	
	private function cmd_BattleClear(userData:Dynamic)
	{
		trace("cmd_BattleClear");
		var count = _curMap;
		count++;
		if (count < _roomArray.length) {
			GameProcess.SendUIMsg(MsgUI2.FinishBattleTip, 1);
		} else if (count >= _roomArray.length - 1) {
			GameProcess.SendUIMsg(MsgUI2.FinishBattleTip, 0);
			if (_duplicateInfo.DuplicateType != 9) {
				if (_talks.exists(1))
					GameProcess.SendUIMsg(MsgUI2.Dilaogue, _talks.get(1));
			}
		}
		//notify(MsgCamera.Lock, true);
	}
	
	private function cmd_TransitionMap(userData:Dynamic):Void
	{
		_curMap++;
		//trace(_roomArray);
		if (_curMap < _roomArray.length) {
			GameProcess.SendUIMsg(MsgUI2.FinishBattleTip, -1);
			Animator.start(this, "", EffectType.SCREEN_CLOSE_EAT, null, true, changeMap);
			//changeMap();
		}
		else if (_curMap >= _roomArray.length-1){
			//notify(MsgStartup.Reset);
			_duplicateInfo.setRate(rate(userData));
			var result:Int = 0;
			notify(MsgStartup.Finishbattle, result);
			GameProcess.SendUIMsg(MsgUI2.Control, false);
			GameProcess.SendUIMsg(MsgUI.BattleResult, _duplicateInfo);//胜利界面
			
			notify(MsgStartup.BattleResult, _duplicateInfo);			
		}
	}
	
	private function cmd_NewBieGame(userData:Dynamic):Void {
		_endGame = false;
		_duplicateInfo = new DuplicateInfo();
		_duplicateInfo.DuplicateType = 1;
		_duplicateInfo.Id = 1;
		_duplicateInfo.DropItem;
		
		_roomArray = [userData];
		for (i in _roomArray) 
		{
			_finishRoom.set(i, false);
		}
		_curMap = 0;
		_totalKillBoss = 0;
		_socre = 0;
		
		var info:PlayerInfo = PlayerUtils.getInfo();
		var hpMax = info.data.MAX_HP;
		info.data.HP = hpMax;
		
		GameProcess.instance.startGame();
		notifyDirect("GameBoard", MsgStartup.Reset);
		GameProcess.NotifyUI(MsgUIUpdate.StartBattle);
		notifyDirect("GameBoard",MsgStartup.Start);
	}
	
	private function cmd_Start(userData:Dynamic):Void
	{
		if (_duplicateInfo.DuplicateType != 9 ) {
			if(_duplicateInfo.BossName=="" && _curMap == 0){
				if (_talks.exists(0)){
					GameProcess.SendUIMsg(MsgUI2.Dilaogue, _talks.get(0));
				}
			}else if (_duplicateInfo.BossName != "" && _curMap == 2) {
				if (_talks.exists(0))
					GameProcess.SendUIMsg(MsgUI2.Dilaogue, _talks.get(0));
			}
		}
	}
	
	private function cmd_Score(userData:Dynamic):Void
	{
		_socre += userData;
		GameProcess.NotifyUI(MsgUIUpdate.UpdateScore, _socre);
	}
	private function cmd_KillBoss(userData:Dynamic):Void
	{
		_totalKillBoss++;
		_clear = true;
	}
	//发送房间号给地图
	private function sendRoomIdToMap():Void
	{
		
	}
	
	override function onDispose():Void 
	{
		_duplicateInfo = null;
		_roomArray = null;
		super.onDispose();
	}
	
}