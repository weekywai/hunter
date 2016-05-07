package com.metal.ui.controller;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Touch;
import com.metal.component.BagpackSystem;
import com.metal.component.BattleSystem;
import com.metal.component.GameSchedual;
import com.metal.config.GuideText;
import com.metal.config.ItemType;
import com.metal.config.PlayerPropType;
import com.metal.config.ResPath;
import com.metal.config.RoomMissionType;
import com.metal.config.SfxManager;
import com.metal.config.StageType;
import com.metal.enums.BagInfo;
import com.metal.enums.MapVo;
import com.metal.manager.UIManager.TipsType;
import com.metal.message.MsgActor;
import com.metal.message.MsgBoard;
import com.metal.message.MsgInput;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.proto.impl.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ItemProto.ItemBaseInfo;
import com.metal.proto.manager.MapInfoManager;
import com.metal.scene.board.impl.GameMap;
import com.metal.ui.warehouse.WarehouseCmd;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.stat.PlayerStat;
import com.metal.unit.weapon.impl.WeaponFactory.WeaponType;
import com.metal.utils.BagUtils;
import com.metal.utils.CountDown;
import de.polygonal.core.es.EntityUtil;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.SimEntity;
import motion.Actuate;
import motion.easing.Quad;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.BmpText;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Progress;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Widget;
using com.metal.enums.Direction;
/**
 * ...
 * @author hyg
 */
class ControllCmd extends BaseCmd
{
	private var _wheel:Wheel;
	private var currentPoint:Point;
	private var aRadius:Float = 100;
	private var _example:Widget;
	private var _leftBtn:Button;
	private var _rightBtn:Button;
	private var _attackBtn:Button;
	private var _jumpBtn:Button;
	private var _knifeBtn:Button;
	private var _skillBtns:Array<Button>;
	private var _tips:Widget;
	/**方向键触控区域大小*/
	private var _maxTouchW:Float;
	private var status:Direction;
	private var touchID:Int;
	
	private var _hpBar:Progress;
	private var _mpBar:Progress;
	private var _hptext:Text;
	private var _mptext:Text;
	private var _bossHp:Text;
	private var _socre:Text;
	private var _center:Widget;
	private var _thumb:Widget;
	
	private var _mapW:Float;
	private var _runKey:Bool;
	private var _battle:BattleSystem;
	private var _slice:Float;
	private var _count:Int;
	//boss 信息
	private var _bossPanel:Widget;
	private var _player:SimEntity;
	
	private var _playerInfo:PlayerInfo;
	/**没有操作时间*/
	private var _controlTime:Int;
	private var _onShowgo:Bool;
	private var _inputEnable:Bool = false;
	
	private var stat:PlayerStat;
	/**倒计时的显示文档*/
	private var _timeLimit:BmpText;
	private var _originX:Float; 
	private var _originY:Float;
	private var _afterScaleX:Float;
	private var _afterScaleY:Float;
	
	private var _bulletTxt:Text;
	
	private var _holdFire:Bool;
	
	private var _weaponArr:Array<Button>;
	
	private var _usingTipArr:Array<Text>;
	/**表示有3个装备格*/
	private var _weaponNum:Int = 3;
	private var _weaponInfoArr:Array<ItemBaseInfo>;
	private	var _lastWeaponIndex:Int;
	
	private var _mission:Text;
		
	
	public function new() 
	{
		super();
	}
	function setWeaponPanel()
	{
		_weaponArr = new Array();
		_usingTipArr = new Array();
		_weaponInfoArr = new Array();
		_lastWeaponIndex = 0;
		var gameSchedual:GameSchedual = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual);
		
		for (i in 0..._weaponNum) 
		{
			_weaponArr.push(_widget.getChildAs("weapon" + i, Button));
			_usingTipArr.push(_widget.getChildAs("usingTip" + i, Text));
		}		
		//设置首发武器
		var weaponInfo:ItemBaseInfo = BagUtils.bag.getItemByKeyId(_playerInfo.data.WEAPON);
		_weaponInfoArr.push(weaponInfo);
		WarehouseCmd.setWeaponBmp(weaponInfo, _weaponArr[0]);
		_weaponArr[0].onPress = function(e) { setUsingWeapon(0); };
		//设置备用武器
		for (i in 1..._weaponNum) 
		{
			weaponInfo = BagUtils.bag.backupWeaponArr.get(i);
			_weaponInfoArr.push(weaponInfo);
			if (weaponInfo!=null) 
			{
				_weaponArr[i].onPress = function(e) {setUsingWeapon(i);	};
			}
			WarehouseCmd.setWeaponBmp(weaponInfo, _weaponArr[i]);
		}
		
		//首次设置武器，不更换人物模型，因为别处已更改
		setUsingWeapon(0,false);
	}
	
	function setUsingWeapon(index:Int,setModel:Bool=true)
	{
		for (i in 0..._weaponNum) 
		{
			_usingTipArr[i].visible = (i==index);
		}
		if (!setModel) return;
		//修改人物模型和参数
		var bagData:BagInfo = GameProcess.root.getComponent(BagpackSystem).bagData;
		bagData.setBackup(_weaponInfoArr[_lastWeaponIndex],  _weaponInfoArr[index].vo.sortInt);
		notifyRoot(MsgNet.UpdateInfo, { type:PlayerProp.WEAPON, data: _weaponInfoArr[index]} );
		GameProcess.root.notify(MsgPlayer.ChangeWeapon, { type:WeaponType.Shoot } );	
		notify(MsgUIUpdate.UpdateBullet, _weaponInfoArr[index]);
		
		_lastWeaponIndex = index;
	}
	
	override function onInitComponent():Void 
	{
		//trace("initControl");
		_wheel = new Wheel();
		_maxTouchW = Lib.current.stage.stageWidth * 0.2;
		status = NONE;
		touchID = -1;
		_widget = UIBuilder.get("controller");
		_leftBtn = _widget.getChildAs("leftBtn", Button);
		_rightBtn = _widget.getChildAs("rightBtn", Button);
		//计算控制按钮中心点
		_center = _widget.getChild("dirPanel");
		_wheel.cPoint = new Point(_center.x, _center.y);
		currentPoint = _wheel.cPoint;
		_count = 0;
		_slice = 0;
		_mapW = 0;
		_controlTime = 0;
		_onShowgo = false;
		_battle = GameProcess.root.getComponent(BattleSystem);
		_holdFire = false;
		_attackBtn = _widget.getChildAs("attackBtn", Button);
		_jumpBtn = _widget.getChildAs("jumpBtn", Button);
		_knifeBtn = _widget.getChildAs("knifeBtn", Button);
		
		_timeLimit = _widget.getChildAs("timeLimit", BmpText);
		_timeLimit.label.visible = false;
		_originX = _timeLimit.label.x;
		_originY = _timeLimit.label.y;
		_afterScaleX = _timeLimit.label.x - _timeLimit.label.width / 2;
		_afterScaleY = _timeLimit.label.y - _timeLimit.label.height / 2;
		
		_bulletTxt=_widget.getChildAs("bulletTxt", Text);
		//判断是否隐藏技能锁
		var skillshow = GameProcess.root.getComponent(GameSchedual).skillData;
		_skillBtns = [];
		for (i in 0...5) 
		{
			var btn:Button = _widget.getChildAs("skill" + i, Button);
			_skillBtns.push(btn);
			if (i == 0) {
				btn.onRelease = onSkillHandler;
			}else {
				btn.onRelease = (skillshow[i - 1] == 0)?onSkillBuy:onSkillHandler;
				btn.getChild("lock").visible = (skillshow[i - 1] == 0);
			}
		}
		
		_tips = _widget.getChild("tips");
		
		
		_hpBar = _widget.getChildAs("hpBar", Progress);
		_mpBar = _widget.getChildAs("mpBar", Progress);
		
		_hptext = _widget.getChildAs("hpPercent", Text);
		_mptext = _widget.getChildAs("mpPercent", Text);
		_bossHp = _widget.getChildAs("mpPercent", Text);
		_socre = _widget.getChildAs("score", Text);
		if (!Input.multiTouchSupported) {
			if (HXP.stage != null) HXP.stage.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDown);
		}
		
		_playerInfo = PlayerUtils.getInfo();
		var icon = UIBuilder.create(Bmp, {
			widthPt:100,
			src:ResPath.getIconPath(Std.string(_playerInfo.res), ResPath.ModelIcon),
			leftPt:7,
			topPt:0
		});
		_widget.getChild("playerBar").addChild(icon);
		super.onInitComponent();
		
		_widget.getChildAs("stopGame", Button).onRelease = stopGame;
		_thumb = _widget.getChild("thumb");
		setWeaponPanel();
		_mission = _widget.getChildAs("mission", Text);
		//cmd_AssignPlayer();
	}
	private function cmd_UpdateBullet(userData:Dynamic)
	{
		if(userData!=null)
		_bulletTxt.text = "子弹数 "+userData.vo.Bullets+"/"+userData.vo.Clips;
	}
	//mp闪烁效果
	var addnum:Float = 0;
	private function shine(e:Event)
	{
		if (stat.mp > stat.mpMax / 2) {
			if (_mpBar.alpha != 1)_mpBar.alpha = 1;
			return;
		}
		if (_mpBar.alpha>=1) 
		{
			addnum = -0.02;
		}else if (_mpBar.alpha<=0.4) 
		{
			addnum = 0.02;
		}
		_mpBar.alpha += addnum;
	}
	//hp闪烁效果
	var addnum1:Float=0;
	private function shine1(e:Event)
	{
		if (stat.hp > stat.hpMax / 2) {
			if (_hpBar.alpha != 1)_hpBar.alpha = 1;
			return;
		}
		if (_hpBar.alpha>=1) 
		{
			addnum1 = -0.02;
		}else if (_hpBar.alpha<=0.4) 
		{
			addnum1 = 0.02;
		}
		_hpBar.alpha += addnum1;
	}
	private function touchAera()
	{
		_center.x = 0;
		_center.y = Lib.current.stage.stageHeight * 0.4;
		_center.w = Lib.current.stage.stageWidth * 0.6;
		_center.h = Lib.current.stage.stageHeight * 0.6;
		_center.alpha = 0.4;
	}
	/**暂停游戏*/
	private function stopGame(e:MouseEvent):Void
	{
		if (!_inputEnable)
			return;
		sendMsg(MsgUI2.StopGame);
	}
	
	/**接收UIManager消息，需要继承转发给 widget 更新数据*/
	override public function onUpdate(type:Int, sender:IObservable, userData:Dynamic):Void {
		
		switch(type){
			case MsgUIUpdate.UpdateInfo:
				cmd_UpdateInfo(userData);
			case MsgUIUpdate.UpdateScore:
				cmd_updateScore(userData);
			case MsgUI2.SkillCD:
				cmd_SkillCD(userData);
			//case MsgUI.BossPanel:
				//cmd_bossFight(userData);
			case MsgUIUpdate.BossInfoUpdate:
				cmd_BossInfoUpdate(userData);
			case MsgUIUpdate.NewBieUI:
				cmd_NewBieUI(userData);
			//case MsgUIUpdate.UpdateThumb:
				//cmd_UpdateThumb(userData);
			case MsgBoard.AssignPlayer:
				cmd_AssignPlayer();
			case MsgUIUpdate.UpdateCountDown:
				cmd_UpdateCountDown(userData);		
			case MsgUIUpdate.UpdateMissionTxt:
				cmd_UpdateMissionTxt(userData);				
			case MsgUI2.InitThumb:
				cmd_InitThumb(userData);
			case MsgUIUpdate.StartBattle:
				cmd_Start(userData);
			case MsgUI2.FinishBattleTip:
				cmd_FinishBattleTip(userData);
			case MsgInput.SetInputEnable:
				cmd_SetInputEnable(userData);
			case MsgUIUpdate.UpdateBullet:
				cmd_UpdateBullet(userData);			
		}
	}
	private function cmd_UpdateCountDown(userData:Dynamic):Void
	{
		var countDown:Int = userData;
		//trace("countDown: "+countDown);
		if (countDown < 0) return;	
		if (countDown >= 10) {
			if(!_timeLimit.label.visible)_timeLimit.label.visible = true;
			//if (_timeLimit.format.color == 0xFF0000)_timeLimit.format.color = 0xFFFFFF;
			_timeLimit.text = CountDown.changeSenForTxt(countDown);
		}else if (countDown >= 0) {
			if(!_timeLimit.label.visible)_timeLimit.label.visible = true;
			//if (_timeLimit.format.color != 0xFF0000)_timeLimit.format.color = 0xFF0000;
			_timeLimit.text = CountDown.changeSenForTxt(countDown);
			Actuate.tween(_timeLimit.label, 0.8, { scaleX:2, scaleY:2,alpha:0.01,x: _afterScaleX ,y: _afterScaleY } ).onComplete(function() {
				_timeLimit.label.scaleX = 1;
				_timeLimit.label.scaleY = 1;
				_timeLimit.label.alpha = 1;
				_timeLimit.label.x = _originX;
				_timeLimit.label.y = _originY;							
			});	
			if (countDown == 0) {
				if (_mission.text == " 目标：在指定时间内存活") 
				{
					SfxManager.playBMG(BGMType.Victory);
					PlayerUtils.getPlayer().notify(MsgActor.Victory);
					trace("MsgActor.Victory");
					GameProcess.root.notify(MsgStartup.BattleClear);
					trace("MsgStartup.BattleClear");
				}else {
					//通知角色死亡
					PlayerUtils.getPlayer().notify(MsgActor.Destroying);
					//战斗结束
					sendMsg(MsgUI.BattleFailure);
					GameProcess.root.notify(MsgStartup.Finishbattle);
				}								
			}
		}
	}
	override function onDispose():Void 
	{
		if (!Input.multiTouchSupported) {
			if (HXP.stage != null) {
				HXP.stage.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDown);
				HXP.stage.removeEventListener(MouseEvent.MOUSE_UP, thumb_mouseUp);
				HXP.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumb_mouseMove);
			}
		}
		_skillBtns = null;
		_player = null;
		_playerInfo = null;
		_leftBtn = null;
		_rightBtn = null;
		_jumpBtn = null;
		_knifeBtn = null;
		
		currentPoint = null;
		status = null;
		_battle = null;
		_wheel.dispose();
		_wheel = null;
		super.onDispose();
	}
	
	override public function onTick(timeDelta:Float) 
	{
		super.onTick(timeDelta);
		if (!isInit) return;
		if (isDisposed) return;
		//if (_battle!=null && _battle.curMap != 1)
			//updateThumb();
		var s = _wheel.setDirection(currentPoint);
		if (s == NONE){
			if(status != NONE)
				_player.notify(MsgInput.UIJoystickInput, s);
		}else{
			_player.notify(MsgInput.UIJoystickInput, s);
		}
		status = s;
		showPressed();
		
		if (Input.multiTouchSupported) {
			Input.touchPoints(onTouch);
			if(!Lambda.has(Input.touchOrder, touchID)) {
				touchID = -1;
				currentPoint = _wheel.cPoint;
			}
		}
		
		//if (!_runKey && !_onShowgo){
			//var time = Lib.getTimer() - _controlTime;
			//if (time >= 5000)
				//showGoTips();
		//}
		if (_player!=null && _holdFire) 
		{
			_player.notify(MsgInput.HoldFire, true);
		}
	}
	private function onAttackPress(e):Void 
	{
		//_player.notify(MsgInput.HoldFire, true);
		_holdFire = true;
	}
	private function onAttackRelease(e):Void
	{
		_holdFire = false;
		_player.notify(MsgInput.HoldFire, _holdFire);
	}
	private function onJumpPress(e):Void 
	{
		_player.notify(MsgInput.UIInput, { type:ActorState.Jump } );
		
	}
	private function onKnifePress(e):Void 
	{
		_player.notify(MsgInput.UIInput, { type:ActorState.Melee } );
		_player.notify(MsgInput.Melee, true);
		//trace("onKnifePress");		
	}
	
	private function onSkillHandler(e:MouseEvent):Void 
	{
		if (!_inputEnable)
			return;
		var btn : Button = cast(e.currentTarget, Button);
		btn.disabled = true;
		switch(btn.name) {
			case "skill0":
				_player.notify(MsgInput.UIInput, {type:ActorState.Skill, data:PlayerPropType.SKILL1});
				//_player.notify(MsgPlayer.ChangeSkill, _playerInfo.getProperty(PlayerPropType.SKILL1));
			case "skill1":
				_player.notify(MsgInput.UIInput, {type:ActorState.Skill, data:PlayerPropType.SKILL2});
				//_player.notify(MsgPlayer.ChangeSkill, _playerInfo.getProperty(PlayerPropType.SKILL2));
			case "skill2":
				_player.notify(MsgInput.UIInput, {type:ActorState.Skill, data:PlayerPropType.SKILL3});
				//_player.notify(MsgPlayer.ChangeSkill, _playerInfo.getProperty(PlayerPropType.SKILL3));
			case "skill3":
				_player.notify(MsgInput.UIInput, {type:ActorState.Skill, data:PlayerPropType.SKILL4});
				//_player.notify(MsgPlayer.ChangeSkill, _playerInfo.getProperty(PlayerPropType.SKILL4));
			case "skill4":
				_player.notify(MsgInput.UIInput, {type:ActorState.Skill, data:PlayerPropType.SKILL5});
				//_player.notify(MsgPlayer.ChangeSkill, _playerInfo.getProperty(PlayerPropType.SKILL5));
		}
	}
	
	private var _clickBtn:Button;
	private function onSkillBuy(e:MouseEvent):Void 
	{
		_clickBtn = cast(e.currentTarget, Button);
		var price:String = "";
		switch(_clickBtn.name) {
			case "skill1":
				price = GuideText.SkillDes1+"\n"+GuideText.SkillPrice1;
			case "skill2":
				price = GuideText.SkillDes2+"\n"+GuideText.SkillPrice2;
			case "skill3":
				price = GuideText.SkillDes3+"\n"+GuideText.SkillPrice3;
			case "skill4":
				price = GuideText.SkillDes4+"\n"+GuideText.SkillPrice4;
		}
		sendMsg(MsgUI.Tips, { msg:price, type:TipsType.buyTip, callback:buyFun} );
		//var tipCmd:TipCmd = new TipCmd();
		//tipCmd.callbackFun.addOnce(buyFun);
		GameProcess.instance.pauseGame(true);
	}
	
	private function buyFun(flag:Bool):Void
	{
		if (flag) {
			var zuanshi:Int = 0;
			var index:Int = 0;
			switch(_clickBtn.name){
				case "skill1":
					index = 2;
					zuanshi = 50;
				case "skill2":
					index = 3;
					zuanshi = 100;
				case "skill3":
					index = 4;
					zuanshi = 500;
				case "skill4":
					index = 5;
					zuanshi = 1000;
			}
			_clickBtn.getChild("lock").free();
			_clickBtn.onRelease = onSkillHandler;
			_clickBtn = null;
			
			notifyRoot(MsgPlayer.UpdateGem, zuanshi);
			notifyRoot(MsgPlayer.UpdateSkill, index);
		}
		GameProcess.instance.pauseGame(false);
	}
	private function thumb_mouseDown(event:MouseEvent):Void
	{
		//应用方向键时，先判断是否按在其他按键上
		if (event.target.name.substr(0,5)=="skill" || event.target.name.substr(0,6)=="weapon") 
		{
			//trace("event.target.name: "+event.target.name);
			return;
		}
		
		var touchPoint = new Point(Input.mouseX, Input.mouseY);
		if (Point.distance(_wheel.cPoint, touchPoint) <= _maxTouchW)
		{
			if (HXP.stage != null) HXP.stage.addEventListener(MouseEvent.MOUSE_MOVE, thumb_mouseMove);
			currentPoint = touchPoint;
		}
		if (HXP.stage != null) HXP.stage.addEventListener(MouseEvent.MOUSE_UP, thumb_mouseUp);
	}
	private function thumb_mouseMove(event:MouseEvent):Void
	{
		var touchPoint = new Point(Input.mouseX, Input.mouseY);
		var disPos = Point.distance(_wheel.cPoint, touchPoint);
		if (disPos > aRadius && disPos <= _maxTouchW)
		{
			currentPoint = _wheel.ccpAdd(_wheel.cPoint, _wheel.ccpMult(_wheel.ccpNormalize(_wheel.ccpSub(touchPoint, _wheel.cPoint)), aRadius));
		}
		else if(disPos < aRadius)
		{
			currentPoint = touchPoint;
		}
		else
		{
			currentPoint = _wheel.cPoint;
			HXP.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumb_mouseMove);
		}
	}
	
	private function thumb_mouseUp(event:MouseEvent):Void
	{
		currentPoint = _wheel.cPoint;
		if (HXP.stage != null) {
			HXP.stage.removeEventListener(MouseEvent.MOUSE_UP, thumb_mouseUp);
			HXP.stage.removeEventListener(MouseEvent.MOUSE_MOVE, thumb_mouseMove);
		}
	}
	
	private function onTouch(e:Touch)
	{
		/*if (Lambda.has(Input.touchOrder, e.id) && touchID != e.id)
			return;*/
		
		var touchPoint = new Point(e.startX, e.startY);
		//var touchPoint = new Point(e.x/Main.Scale, e.x/Main.Scale);
		//var touchPoint = new Point(Input.mouseFlashX, Input.mouseFlashY);
		//DC.log(touchPoint+">>"+Input.mouseFlashX + ":" + Input.mouseFlashY+"<<"+Main.Scale);
		var disPos = Point.distance(_wheel.cPoint, touchPoint);
		if (disPos <= _maxTouchW)
		{
			touchID = e.id;
			if (!Lambda.has(Input.touchOrder, touchID))
				Input.touchOrder.push(touchID);
			
			if (disPos > aRadius && disPos <= _maxTouchW)
			{
				currentPoint = _wheel.ccpAdd(_wheel.cPoint, _wheel.ccpMult(_wheel.ccpNormalize(_wheel.ccpSub(touchPoint, _wheel.cPoint)), aRadius));
			}
			else if(disPos < aRadius)
			{
				currentPoint = touchPoint;
			}
			else
			{
				currentPoint = _wheel.cPoint;
			}
		}
	}
	
	private function showPressed():Void 
	{
		if (status == LEFT) {
			_leftBtn.alpha = 1;
			_rightBtn.alpha = 0.6;
		}else if (status == RIGHT) {
			_leftBtn.alpha = 0.5;
			_rightBtn.alpha = 1;
		}else {
			_leftBtn.alpha = _rightBtn.alpha = 0.6;
		}
	}
	
	
	private function cmd_UpdateInfo(userData):Void 
	{
		if (_playerInfo == null) return;
		_hpBar.value =  stat.hp / stat.hpMax * 100;
		_mpBar.value =  stat.mp / stat.mpMax * 100;
		_hptext.text = Std.string(stat.hp);
		_mptext.text = Std.string(stat.mp);
	}
	
	private function cmd_updateScore(userData)
	{
		_socre.text = Std.string(userData);
	}
	
	private function cmd_NewBieUI(userData)
	{
		_widget.getChildAs("stopGame", Button).visible = false;
	}
	
	
	public function showBossPanel(userData):Void 
	{
		if (userData == null)
		{
			if(_bossPanel!=null)
				_widget.getChild("BossPanel").removeChild(_bossPanel);
			return;
		}
		if(_bossPanel == null)
			_bossPanel = UIBuilder.buildFn("ui/fight/bossBar.xml")();
		else {
			var ico = _bossPanel.getChild("ico");
			if (ico != null)
				_bossPanel.removeChild(ico);
		}
		
		var icon = UIBuilder.create(Bmp, {
			name:"ico",
			src:ResPath.getIconPath(userData, ResPath.ModelIcon),
			rightPt:14,
			topPt:24
		});
		_bossPanel.addChild(icon);
		trace("Boss name:"+_battle.currentStage().BossName);
		_bossPanel.getChildAs("name", Text).text = _battle.currentStage().BossName;
		_widget.getChild("BossPanel").addChild(_bossPanel);
	}
	private function cmd_BossInfoUpdate(userData):Void
	{
		if (_bossPanel == null)
			return;
		_bossPanel.getChildAs("bossHP", Progress).value = userData.percent;
		_bossPanel.getChildAs("hpPercent", Text).text = Std.string(userData.hp < 0?0:userData.hp);
	}
	
	private function cmd_AssignPlayer()
	{
		_player = PlayerUtils.getPlayer();
		stat = _player.getComponent(PlayerStat);
		_jumpBtn.onPress = onJumpPress;
		_knifeBtn.onPress = onKnifePress;
		_attackBtn.onPress = onAttackPress;
		_attackBtn.onRelease = onAttackRelease;
		_jumpBtn.onPress = onJumpPress;
		_knifeBtn.onPress = onKnifePress;
		_hpBar.addEventListener(Event.ENTER_FRAME, shine1);
		_mpBar.addEventListener(Event.ENTER_FRAME, shine);
		cmd_UpdateInfo(null);
		cmd_UpdateBullet(stat.weapon);
		var map = EntityUtil.findBoardComponent(GameMap);
		notify(MsgUIUpdate.UpdateMissionTxt, MapInfoManager.instance.getRoomInfo(Std.parseInt(map.mapData.mapId)).MissionType);
	}
	
	private function cmd_SkillCD(userData:Dynamic):Void
	{
		var time:Int = userData.time;
		var timeStr:String = Std.string(time != 0?time:"");
		var id:Int = userData.id;
		var index:Int = -1;
		if (id == _playerInfo.data.SKILL1)  index = 0;
		else if (id == _playerInfo.data.SKILL2) index = 1;
		else if (id == _playerInfo.data.SKILL3) index = 2;
		else if (id == _playerInfo.data.SKILL4) index = 3;
		else if (id == _playerInfo.data.SKILL5) index = 4;
		if (index == -1)
			return;
		_skillBtns[index].text = timeStr;
		if (time == 0) _skillBtns[index].disabled = false;
	}
	
	//private function cmd_UpdateThumb(userData:Dynamic):Void
	//{
		//if (_battle.currentStage().DuplicateType == 9)
			//return;
		//var player = _thumb.getChild("thumbPlayer");
		//if (_count == 0){
			//_count = userData;
			//updateThumb();
		//}else {
			////_count = _count - 1;
		//}
		//var holder = _thumb.getChild("thumbHolder");
		//var slice = _slice / _count;
		//Actuate.tween(_thumb.getChild("thumbPlayer"), 0.5, { x:player.x + slice } );
	//}
	
	private function cmd_InitThumb(userData:Dynamic):Void
	{
		//trace("cmd_InitThumb");
		if (_battle.currentStage().DuplicateType == StageType.Endless)
			return;
		//隐藏关卡进度条
		_thumb.visible = false;
		var count:Int = userData;
		var holder = _thumb.getChild("thumbHolder");
		_slice = holder.w / count;
		for(i in 0...count){
			var bmp = UIBuilder.create(Bmp, { skinName:"fightThumb2", x:_slice * i + _slice } );
			holder.addChild(bmp);
		}
		var mapData:MapVo = EntityUtil.findBoardComponent(GameMap).mapData;
		_mapW = mapData.map.fullWidth;
		_runKey = mapData.runKey;
		
	}
	private function cmd_UpdateMissionTxt(userData:Dynamic):Void
	{
		//trace("cmd_UpdateMissionTxt");
		switch (userData) 
		{
			case RoomMissionType.Kill_All:
				_mission.text = " 目标：消灭所有敌人";
			case RoomMissionType.Reach_Destination:
				_mission.text = " 目标：到达终点";
			case RoomMissionType.Survive:
				_mission.text = " 目标：在指定时间内存活";
			default:				
		} 
		
		_mission.label.alpha = 0.01;
		Actuate.tween(_mission.label, 2, { alpha:1 } );	
	}
	private function cmd_Start(userData:Dynamic):Void
	{
		trace("cmd_Start");
		//_battle = GameProcess.root.getComponent(BattleSystem);
		for (btn in _skillBtns) 
		{
			btn.text = "";
			btn.disabled = false;
		}		
		GameProcess.root.notify(MsgStartup.PauseCountDown, false);
		//notify(MsgUIUpdate.UpdateMissionTxt, MapInfoManager.instance.getRoomInfo(Std.parseInt(EntityUtil.findBoardComponent(GameMap).mapData.mapId)).MissionType);
		//trace("notify(MsgUIUpdate.UpdateMissionTxt");
		//_skill0Btn.text = _skill1Btn.text = _skill2Btn.text = _skill3Btn.text = _skill4Btn.text = "";
		//_skill0Btn.disabled = _skill1Btn.disabled = _skill2Btn.disabled = _skill3Btn.disabled = _skill4Btn.disabled = false;
	}
	private function cmd_FinishBattleTip(userData:Dynamic):Void
	{
		var tipPanel = _widget.getChild("tips");
		var tips1 = _widget.getChildAs("passTips1",Bmp);
		var tips2 = _widget.getChildAs("passTips2", Bmp);
		tipPanel.topPt = 0;
		if (userData == 0) {
			tipPanel.visible = true;
			tips1.visible = true;
			Actuate.tween(tips1, 0.2, { leftPt:-100 }).ease(Quad.easeIn).reverse().onComplete(function() {
				Actuate.transform(tips1, 0.2).color(0xffffff).reverse();
			});
			Actuate.tween(tips2, 0.2, { leftPt:200 }).ease(Quad.easeIn).reverse().onComplete(function() {
				Actuate.transform(tips2, 0.2).color(0xffffff).reverse();
			});
		}else if (userData == 1) {
			tipPanel.visible = true;
			tipPanel.topPt = -10;
			tips1.visible = false;
			Actuate.tween(tips2, 0.2, { leftPt:-100 }).ease(Quad.easeIn).reverse().onComplete(function() {
				Actuate.transform(tips2, 0.2).color(0xffffff).reverse();
			});
		}else {
			tipPanel.visible = false;
		}
	}
	private function cmd_SetInputEnable(userData:Dynamic)
	{
		_inputEnable = userData;
	}
	//private function updateThumb():Void
	//{
		//var holder = _thumb.getChild("thumbHolder");
		//var actor = _player.getComponent(MTActor);
		//
		//_thumb.getChild("thumbPlayer").x =  (actor.x / _mapW) * _slice + _battle.curMap*_slice;
		////trace(holder.w +">>" + actor.x +">>>"+ _mapW);
	//}
	override function onClose():Void 
	{
		dispose();
		super.onClose();
	}
	private function showGoTips()
	{
		_onShowgo = true;
		var go = _widget.getChild("goTips"); 
		go.visible = true;
		Actuate.tween(go,0.6,{visible:false}).repeat(3).onComplete(function() {
		//TweenX.to(go, { visible:false }, 0.6).repeat(3).interval( 0.3 ).onFinish(function() {
			go.visible = false;
			_controlTime = Lib.getTimer();
			_onShowgo = false;
		}).onRepeat(function() {
			go.visible = true;
		});
	}
}