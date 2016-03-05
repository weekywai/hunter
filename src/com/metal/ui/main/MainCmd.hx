package com.metal.ui.main;
import com.metal.component.GameSchedual;
import com.metal.config.BagType;
import com.metal.config.EquipProp;
import com.metal.config.FilesType;
import com.metal.config.PlayerPropType;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.enums.NoviceOpenType;
import com.metal.message.MsgPlayer;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.message.MsgView;
import com.metal.player.utils.PlayerInfo;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.impl.ArmsInfo;
import com.metal.proto.impl.StrengthenInfo;
import com.metal.proto.impl.WeaponInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.proto.manager.ModelManager;
import com.metal.ui.BaseCmd;
import com.metal.ui.noviceGuide.NoviceCourseCmd;
import com.metal.utils.FileUtils;
import de.polygonal.core.event.IObservable;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Box;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.MainStack;
import ru.stablex.ui.widgets.Radio;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Tip;
import ru.stablex.ui.widgets.Widget;
import spinepunk.SpriteActor;


/**
 * ...
 * @author hyg
 */
class MainCmd extends BaseCmd
{
	
	private var _model:SpriteActor;
	private var mainStack:MainStack;
	private var _mainTLView:Widget;
	private var novCmd:NoviceCourseCmd ;
	public static var main_cmd:MainCmd = new MainCmd();
	public function new() 
	{
		super();
	}
	override public function onUpdate(type:Int, sender:IObservable, userData:Dynamic):Void
	{
		switch(type){
			case MsgUIUpdate.UpdateModel:
				cmd_UpdateModel(userData);
			case MsgUIUpdate.OpenThrough:
				openThrough();
			case MsgUIUpdate.OpenCopy:
				openCopy();
		}
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_mainTLView = UIBuilder.get("main");
		_widget = UIBuilder.get("UIMain");
		sendMsg(MsgUI2.Loading, false);
		super.onInitComponent();
		
		initFileData();
		
		mainStack = UIBuilder.getAs("allView", MainStack);
		//showModel();
		onClick();
		
		
	}
	
	/**初始化文件数据读取*/
	private function initFileData():Void
	{
		showModel();
	}
	override function onClose():Void 
	{
		dispose();
		super.onClose();
	}
	override function onDispose():Void 
	{
		//if (_model != null && _model.parent!=null)
			//_model.parent.removeChild(_model);
		//_model = null;
		//_widget.free();
		//_widget = null;
		//mainStack = null;
		super.onDispose();
	}
	
	/*打开关卡界面*/
	private function openThrough():Void
	{
		mainStack.show("through");
		sendMsg(MsgUI.Through);
		
	}
	/**单开副本模式界面*/
	private function openCopy():Void
	{
		mainStack.show("endless");
		sendMsg(MsgUI.EndlessCopy);
	}
	override function onShow():Void 
	{
		sendMsg(MsgUI2.Loading, false);
	}
	/**按钮点击声音
	 *      ***********************需优化！！！！
	 * */
	private function onClick():Void
	{
		mainStack = UIBuilder.getAs("allView", MainStack);
		//活动
		_widget.getChildAs("shopBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				mainStack.show("activity");
				sendMsg(MsgUI2.Task);
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText29);
			}
		//奖励
		_widget.getChildAs("rewardBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				mainStack.show("reward");
				sendMsg(MsgUI.Reward);
				notify(MsgUIUpdate.UpdataReturnBtn,false);
			}
		//消息
		_widget.getChildAs("newsBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				mainStack.show("news");
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				sendMsg(MsgUI2.oneNews);
			}
		//游戏设置
		_widget.getChildAs("gameSetBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play(); 
				mainStack.show("gameSet");
				sendMsg(MsgUI2.GameSet);
				notify(MsgUIUpdate.UpdataReturnBtn,false);
			}
		//闯关
		_widget.getChildAs("battleBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				mainStack.show("through");
				sendMsg(MsgUI.Through);
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText13);
			}
		//副本
		_widget.getChildAs("endlessBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				mainStack.show("endless");
				sendMsg(MsgUI.EndlessCopy);
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText15);
			}
		//锻造
		//_widget.getChildAs("strengthenBtn", Button).onPress = function(e)
			//{
				//SfxManager.getAudio(AudioType.Btn).play();
				//mainStack.show("forge");
				//sendMsg(MsgUI.Forge);
				//notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText19);
			//}
		//仓库
		_widget.getChildAs("warehouseBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				mainStack.show("warehouse");
				sendMsg(MsgUI.Warehouse, BagType.OPENTYPE_STORE);
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText24);
			}
		//技能
		//_widget.getChildAs("skillBtn", Button).onPress = function(e)
			//{
				//SfxManager.getAudio(AudioType.Btn).play();
				//mainStack.show("skill");
				//sendMsg(MsgUI.Skill);
				//notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText25);
			//}
			
		//装备
		_widget.getChildAs("leftEquipBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				mainStack.show("warehouse");
				sendMsg(MsgUI.Warehouse, BagType.OPENTYPE_WEAPON);
				notify(MsgUIUpdate.UpdataReturnBtn, true);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText24);
			}
		//护甲
		_widget.getChildAs("rightEquipBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				mainStack.show("warehouse");
				sendMsg(MsgUI.Warehouse, BagType.OPENTYPE_ARMS);
				notify(MsgUIUpdate.UpdataReturnBtn, true);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText24);
			}
			
		/**四大按钮*/
		_widget.getChildAs("leftUpBtn_1", Radio).onPress = function(e)
		{
			SfxManager.getAudio(AudioType.Btn).play();
			
		}
		_widget.getChildAs("leftDownBtn_1", Radio).onPress = function(e)
		{
			SfxManager.getAudio(AudioType.Btn).play();
		}
		_widget.getChildAs("rightUpBtn_1", Radio).onPress = function(e)
		{
			SfxManager.getAudio(AudioType.Btn).play();
			//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText11);
		}
		_widget.getChildAs("rightDownBtn_1", Radio).onPress = function(e)
		{
			SfxManager.getAudio(AudioType.Btn).play();
			//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText18);
		}
	}
	
	/** 展示模型 */
	private function showModel():Void 
	{
		var info = PlayerUtils.getInfo();
		var modelInfo = ModelManager.instance.getProto(info.getProperty(PlayerPropType.ROLEID));
		var modelContainer:Widget = _widget.getChildAs("modelStage", Widget);
		if (modelContainer.numChildren > 0) modelContainer.removeChildren();
		_model = new SpriteActor(ResPath.getModelRoot("player", modelInfo.res), 'model',1.7, modelInfo.skin);
		//_model = new SpriteActor('model/player/M0001/', 'model',1.7);
		var id = PlayerUtils.getUseWeaponId();
		//_model.setAttachment("gun_1", "gun_" + id);
		
		modelContainer.addChild(_model);
		_model.point(112, 39);
		_model.setAnimation('idle_1');
		
		updatePlayerType(null);
		
	}
	
	/**更换模型数据*/
	private function cmd_UpdateModel(data:Dynamic):Void
	{
		if (_model != null && _model.parent != null) 
			_model.parent.removeChild(_model);
		_model = null;
		
		var info = PlayerUtils.getInfo();
		//trace(info.getProperty(PlayerPropType.ROLEID));
		var modelInfo = ModelManager.instance.getProto(info.getProperty(PlayerPropType.ROLEID));
		var modelContainer:Widget = _widget.getChildAs("modelStage", Widget);
		//trace(modelInfo.skin);
		_model = new SpriteActor(ResPath.getModelRoot("player", modelInfo.res), 'model',1.7, modelInfo.skin);
		if(modelContainer.numChildren>0)modelContainer.removeChildren();
		_model.point(112, 39);
		modelContainer.addChild(_model);
		var id = PlayerUtils.getUseWeaponId();
		//_model.setAttachment("gun_1", "gun_" + id);
		_model.setAnimation('idle_1');
		updatePlayerType(data);
	}
	/**更新角色属性*/
	private function updatePlayerType(data:Dynamic):Void
	{
		//bug 可能重复操作
		var schedual = cast(GameProcess.root.getComponent(GameSchedual), GameSchedual);
		var playerInfo:PlayerInfo = schedual.playerInfo;
		_widget.getChildAs("playerName", Text).text = "昵称：" + playerInfo.Name;
		//_widget.getChildAs("HP", Text).text = "" + playerInfo.getProperty(PlayerPropType.MAX_HP);
		//trace(data);
		//var weapon:WeaponInfo =  cast GoodsProtoManager.instance.getItemById(playerInfo.getProperty(PlayerPropType.WEAPON));
		//trace(schedual.equipBagData.itemArr[0].itemId);
		//trace(playerInfo.getProperty(PlayerPropType.WEAPON));
		//var weapon:WeaponInfo = cast schedual.equipBagData.getItem(playerInfo.getProperty(PlayerPropType.WEAPON));
		var weapon:WeaponInfo = cast schedual.equipBagData.getItemByKeyId(playerInfo.getProperty(PlayerPropType.WEAPON));
		//trace("playerInfo.getProperty(PlayerPropType.WEAPON): "+playerInfo.getProperty(PlayerPropType.WEAPON));
		//trace("weapon: " + weapon);
		//for (i in 0...schedual.equipBagData.itemArr.length) 
		//{
			//trace("schedual.equipBagData: "+schedual.equipBagData.itemArr[i].keyId);
			//trace("schedual.equipBagData: "+schedual.equipBagData.itemArr[i].itemId);
			//trace("currentBullet: "+schedual.equipBagData.itemArr[i].currentBullet);
			//trace("currentBackupBullet: "+schedual.equipBagData.itemArr[i].currentBackupBullet);
		//}
		
		//var armData:ArmsInfo = cast GoodsProtoManager.instance.getItemById(playerInfo.getProperty(PlayerPropType.ARMOR));
		var armData:ArmsInfo = cast schedual.equipBagData.getItemByKeyId(playerInfo.getProperty(PlayerPropType.ARMOR));
		
		var leftBtn:Button = _widget.getChildAs("leftEquipBtn", Button);
		var rightBtn:Button = _widget.getChildAs("rightEquipBtn", Button);
		if (leftBtn.numChildren > 0) leftBtn.removeChildren();
		if (rightBtn.numChildren > 0) rightBtn.removeChildren();
		if (weapon != null&& weapon.ResId!=null)
		{
			var weaponIco = UIBuilder.create(Box, { 
							skinName:'forgeImg12',
							children : [
								UIBuilder.create(Box, { skinName : "forgelvImg" + weapon.InitialQuality, children : [
									UIBuilder.create(Bmp, { src:'icon/' + weapon.ResId + '.png' } )
								] } )
							]
						});
			
			leftBtn.addChild(weaponIco);
		}
		if (armData != null && armData.ResId != null) {
			var armIco = UIBuilder.create(Box, { 
				skinName:'forgeImg12',
				children : [
					UIBuilder.create(Box, { skinName : "forgelvImg" + armData.InitialQuality, children : [
						UIBuilder.create(Bmp, { src:'icon/' + armData.ResId + '.png' } )
					] } )
				]
			});
			rightBtn.addChild(armIco);
		}
		var curWeapon:StrengthenInfo = EquipProp.Strengthen(weapon, weapon.strLv);
		var maxWeapon:StrengthenInfo = EquipProp.Strengthen(weapon, weapon.MaxStrengthenLevel);
		//trace(weapon);
		var curAtk = EquipProp.compute(weapon.Att, curWeapon.Attack);
		var maxAtk = EquipProp.compute(weapon.Att, maxWeapon.Attack);
		
		var curArm:StrengthenInfo = EquipProp.Strengthen(armData, armData.strLv);
		var maxArm:StrengthenInfo = EquipProp.Strengthen(armData, armData.MaxStrengthenLevel);
		var curHP = EquipProp.compute(armData.Hp, curArm.HPvalue);
		var maxHP = EquipProp.compute(armData.Hp, maxArm.HPvalue);
		//trace(curArm.HPvalue + ":>" +maxArm.HPvalue+":>"+ curHP / maxHP);
		
		
		var atk = _widget.getChild("attValue");
		var defen = _widget.getChild("defensValue");
		atk.scaleX = curAtk / maxAtk;
		defen.scaleX = curHP / maxHP;
		atk.tip = UIBuilder.create(Tip,{skinName:"TipBgImg1", padding:22});
		defen.tip = UIBuilder.create(Tip,{skinName:"TipBgImg1", padding:22});
		if (atk.scaleX < 1)
			atk.tip.text = "您距离最强者还差" + Math.floor((1 - atk.scaleX)*100) + "%";
		else 
			atk.tip.text = "您的攻击力已经是最强！期待新版本的发布吧！";
			
		if (defen.scaleX < 1)
			defen.tip.text = "您距离最强者还差" + Math.floor((1 - defen.scaleX)*100) + "%";
		else 
			defen.tip.text = "您的攻击力已经是最强！期待新版本的发布吧！";
		
		_widget.getChildAs("Att", Text).text = Std.string(Std.int(playerInfo.getProperty(PlayerPropType.FIGHT) + curAtk + playerInfo.getProperty(PlayerPropType.MAX_HP) + curHP));
	}
}