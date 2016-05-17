package com.metal;
import com.metal.config.ResPath;
import com.metal.message.MsgNet;
import com.metal.message.MsgPlayer;
import com.metal.network.RemoteSqlite;
import com.metal.proto.manager.ActorPropertyManager;
import com.metal.proto.manager.AdvanceManager;
import com.metal.proto.manager.AppearManager;
import com.metal.proto.manager.BattlePrepareManager;
import com.metal.proto.manager.BuffManager;
import com.metal.proto.manager.BulletManager;
import com.metal.proto.manager.ChestManager;
import com.metal.proto.manager.DecompositionManager;
import com.metal.proto.manager.DiamondManager;
import com.metal.proto.manager.DuplicateManager;
import com.metal.proto.manager.EffectManager;
import com.metal.proto.manager.FilterManager;
import com.metal.proto.manager.ForgeManager;
import com.metal.proto.manager.Gold_Manager;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.proto.manager.GradeConditionManager;
import com.metal.proto.manager.LiveNessManager;
import com.metal.proto.manager.MapInfoManager;
import com.metal.proto.manager.ModelManager;
import com.metal.proto.manager.MonsterAppeatManager;
import com.metal.proto.manager.MonsterManager;
import com.metal.proto.manager.NewsManager;
import com.metal.proto.manager.NoviceManager;
import com.metal.proto.manager.PlayerModelManager;
import com.metal.proto.manager.ScoreManager;
import com.metal.proto.manager.SkillManager;
import com.metal.proto.manager.TaskManager;
import com.metal.proto.manager.QuestsManager;
import com.metal.proto.manager.TreasuerHuntManager;
import com.metal.utils.LoginFileUtils;
import openfl.Assets;


/**
 * 加载资源
 * @author weeky
 */
class LoadSource
{
	private var _praseProto:Map<String, Dynamic>;
	
	public var isLoaded(default, null):Bool = false;
	public function new() 
	{
		_praseProto = new Map();
		/*_praseProto.set("prop_actor", ActorPropertyManager);
		_praseProto.set("prop_item", GoodsProtoManager);
		_praseProto.set("prop_quest", QuestsManager);
		_praseProto.set("prop_stage", DuplicateManager);
		_praseProto.set("prop_stageroom", MapInfoManager);
		_praseProto.set("prop_gradeCondition", GradeConditionManager);
		_praseProto.set("prop_model", ModelManager);
		_praseProto.set("prop_monster", MonsterManager);
		_praseProto.set("prop_bullet", BulletManager);
		_praseProto.set("prop_skill", SkillManager);
		_praseProto.set("prop_effects", EffectManager);
		_praseProto.set("prop_strengthen", ForgeManager);
		_praseProto.set("prop_decomposition", DecompositionManager);
		_praseProto.set("prop_battle_prepare", BattlePrepareManager);
		_praseProto.set("prop_monster_appear", AppearManager);
		_praseProto.set("prop_appear", MonsterAppeatManager);
		_praseProto.set("prop_level_up_equip", AdvanceManager);
		_praseProto.set("prop_diamond_shop", DiamondManager);
		_praseProto.set("prop_filter", FilterManager);
		_praseProto.set("prop_buff", BuffManager);
		_praseProto.set("prop_buy_chest", ChestManager);
		_praseProto.set("prop_buy_chest_group", TreasuerHuntManager);
		_praseProto.set("prop_score", ScoreManager);
		_praseProto.set("prop_partner", PlayerModelManager);
		_praseProto.set("prop_Live_Ness", LiveNessManager);
		_praseProto.set("prop_task", TaskManager);
		_praseProto.set("prop_gold_shop", Gold_Manager);
		_praseProto.set("prop_text", NoviceManager);
		_praseProto.set("prop_news", NewsManager);*/
		parseProto();
	}
	
	private function parseProto()
	{
		/*var source:String;
		var xml:Xml; 
		for (key in _praseProto.keys()) 
		{
			source = ResPath.getProto(key);
			//trace(key);
			xml = Xml.parse(Assets.getText(source));
			_praseProto.get(key).instance.appendXml(xml);
			_praseProto.remove(key);
		}*/
		isLoaded = true;
		//trace("MsgNet.AssignAccount");
		//GameProcess.root.notify(MsgNet.AssignAccount);
		GameProcess.root.notify(MsgPlayer.UpdateInitFileData, null);
	}
	
	
}