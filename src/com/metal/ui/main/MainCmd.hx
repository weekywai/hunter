package com.metal.ui.main;
import com.metal.config.BagType;
import com.metal.config.EquipProp;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.message.MsgUIUpdate;
import com.metal.player.utils.PlayerUtils;
import com.metal.proto.ProtoUtils;
import com.metal.proto.impl.PlayerInfo;
import com.metal.proto.impl.StrengthenInfo;
import com.metal.proto.manager.ModelManager;
import com.metal.ui.BaseCmd;
import com.metal.ui.noviceGuide.GuideCmd;
import com.metal.utils.BagUtils;
import de.polygonal.core.event.IObservable;
import ru.stablex.ui.UIBuilder;
import ru.stablex.ui.widgets.Bmp;
import ru.stablex.ui.widgets.Box;
import ru.stablex.ui.widgets.Button;
import ru.stablex.ui.widgets.Radio;
import ru.stablex.ui.widgets.Text;
import ru.stablex.ui.widgets.Tip;
import ru.stablex.ui.widgets.Widget;
import spinepunk.SpriteActor;

using com.metal.proto.impl.ItemProto;
/**
 * ...
 * @author hyg
 */
class MainCmd extends BaseCmd
{
	
	private var _model:SpriteActor;
	private var _mainTLView:Widget;
	private var novCmd:GuideCmd ;
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
		}
	}
	override function onInitComponent():Void 
	{
		SfxManager.getAudio(AudioType.t001).play();
		_mainTLView = UIBuilder.get("main");
		_widget = UIBuilder.get("UIMain");
		sendMsg(MsgUI2.Loading, false);
		super.onInitComponent();
		
		/**初始化文件数据读取*/
		showModel();
		updatePlayerType(null);
		onClick();
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
		super.onDispose();
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
		//活动
		_widget.getChildAs("shopBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				sendMsg(MsgUI2.Task);
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText29);
			}
		//奖励
		_widget.getChildAs("rewardBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				sendMsg(MsgUI.Reward);
				notify(MsgUIUpdate.UpdataReturnBtn,false);
			}
		//消息
		_widget.getChildAs("newsBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				sendMsg(MsgUI2.oneNews);
			}
		//游戏设置
		_widget.getChildAs("gameSetBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				sendMsg(MsgUI2.GameSet);
				notify(MsgUIUpdate.UpdataReturnBtn,false);
			}
		//闯关
		_widget.getChildAs("battleBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				sendMsg(MsgUI.Through);
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText13);
			}
		//副本
		_widget.getChildAs("endlessBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				sendMsg(MsgUI.EndlessCopy);
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText15);
			}
		//锻造
		//_widget.getChildAs("strengthenBtn", Button).onPress = function(e)
			//{
				//SfxManager.getAudio(AudioType.Btn).play();
				//sendMsg(MsgUI.Forge);
				//notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText19);
			//}
		//仓库
		_widget.getChildAs("warehouseBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				sendMsg(MsgUI.Warehouse, BagType.OPENTYPE_STORE);
				notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText24);
			}
		//技能
		//_widget.getChildAs("skillBtn", Button).onPress = function(e)
			//{
				//SfxManager.getAudio(AudioType.Btn).play();
				//sendMsg(MsgUI.Skill);
				//notify(MsgUIUpdate.UpdataReturnBtn, false);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText25);
			//}
			
		//装备
		_widget.getChildAs("leftEquipBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
				sendMsg(MsgUI.Warehouse, BagType.OPENTYPE_WEAPON);
				notify(MsgUIUpdate.UpdataReturnBtn, true);
				//notifyRoot(MsgView.NewBie,NoviceOpenType.NoviceText24);
			}
		//护甲
		_widget.getChildAs("rightEquipBtn", Button).onPress = function(e)
			{
				SfxManager.getAudio(AudioType.Btn).play();
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
		if (_model != null && _model.parent != null) 
			_model.parent.removeChild(_model);
		_model = null;
		var info = PlayerUtils.getInfo();
		var modelInfo = ModelManager.instance.getProto(info.data.ROLEID);
		var modelContainer:Widget = _widget.getChildAs("modelStage", Widget);
		if (modelContainer.numChildren > 0) modelContainer.removeChildren();
		_model = new SpriteActor(ResPath.getModelRoot("player", modelInfo.res), 'model',1.7, modelInfo.skin);
		//_model = new SpriteActor('model/player/M0001/', 'model',1.7);
		var id = PlayerUtils.getUseWeaponId();
		_model.setAttachment("gun_1", "gun_" + id);
		
		modelContainer.addChild(_model);
		_model.point(112, 39);
		_model.setAnimation('idle_1');
	}
	
	/**更换模型数据*/
	private function cmd_UpdateModel(data:Dynamic):Void
	{
		showModel();
		updatePlayerType(data);
	}
	/**更新角色属性*/
	private function updatePlayerType(data:Dynamic):Void
	{
		//bug 可能重复操作
		var playerInfo:PlayerInfo = PlayerUtils.getInfo();
		_widget.getChildAs("playerName", Text).text = "昵称：" + playerInfo.data.NAME;
		var weapon:EquipInfo = ProtoUtils.castType(BagUtils.bag.getItemByKeyId(playerInfo.data.WEAPON));
		var armData:EquipInfo = ProtoUtils.castType(BagUtils.bag.getItemByKeyId(playerInfo.data.ARMOR));
		var leftBtn:Button = _widget.getChildAs("leftEquipBtn", Button);
		var rightBtn:Button = _widget.getChildAs("rightEquipBtn", Button);
		if (leftBtn.numChildren > 0) leftBtn.removeChildren();
		if (rightBtn.numChildren > 0) rightBtn.removeChildren();
		if (weapon != null && weapon.ResId != null)
		{
			//trace(playerInfo.data.WEAPON+"::"+weapon.ID +">>"+weapon.ResId);
			var weaponIco = UIBuilder.create(Box, { 
							skinName:'forgeImg12',
							children : [
								UIBuilder.create(Box, { skinName : "forgelvImg" + weapon.Color, children : [
									UIBuilder.create(Bmp, { src:'icon/' + weapon.ResId + '.png' } )
								] } )
							]});
			leftBtn.addChild(weaponIco);
		}
		if (armData != null && armData.ResId != null) {
			var armIco = UIBuilder.create(Box, { 
				skinName:'forgeImg12',
				children : [
					UIBuilder.create(Box, { skinName : "forgelvImg" + armData.Color, children : [
						UIBuilder.create(Bmp, { src:'icon/' + armData.ResId + '.png' } )
					] } )
				]
			});
			rightBtn.addChild(armIco);
		}
		var curWeapon:StrengthenInfo = EquipProp.Strengthen(weapon, weapon.vo.strLv);
		var maxWeapon:StrengthenInfo = EquipProp.Strengthen(weapon, weapon.MaxStrengthenLevel);
		//trace(weapon);
		var curAtk = EquipProp.compute(weapon.Att, curWeapon.Attack);
		var maxAtk = EquipProp.compute(weapon.Att, maxWeapon.Attack);
		
		var curArm:StrengthenInfo = EquipProp.Strengthen(armData, armData.vo.strLv);
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
		
		_widget.getChildAs("Att", Text).text = Std.string(Std.int(playerInfo.data.FIGHT + curAtk + playerInfo.data.MAX_HP + curHP));
	}
}