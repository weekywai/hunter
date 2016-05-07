package com.metal;
import com.haxepunk.HXP;
import com.metal.component.GameSchedual;
import com.metal.config.FilesType;
import com.metal.config.ItemType;
import com.metal.config.UnitModelType;
import com.metal.message.MsgBoard;
import com.metal.message.MsgMission;
import com.metal.message.MsgNet;
import com.metal.message.MsgStartup;
import com.metal.message.MsgUI;
import com.metal.message.MsgUI2;
import com.metal.proto.ProtoUtils;
import com.metal.proto.impl.ItemProto.ItemBaseInfo;
import com.metal.proto.manager.GoodsProtoManager;
import com.metal.scene.board.api.BoardFaction;
import com.metal.unit.UnitInfo;
import com.metal.utils.BagUtils;
import com.metal.utils.FileUtils;
import haxe.Serializer;
import haxe.Unserializer;
import pgr.dconsole.DC;

/**
 * ...
 * @author weeky
 */
class DevCheat
{
	public function new() 
	{
		init();
	}
	
	private function init()
	{
		DC.init();
		#if !debug
		DC.setProfilerKey(192);
		#end
		//DC.showConsole();
		//DC.showMonitor();
		DC.registerCommand(cmd_GM, "GM", "", "Type GM [command-name] for more info");
		DC.registerCommand(cmd_AddMonster, "add", "", "Type GM [command-name] for more info");
		DC.registerCommand(cmd_Mission, "task", "", "Type GM [command-name] for more info");
		DC.registerCommand(cmd_Login, "login", "", "Type GM [command-name] for more info");
		DC.registerCommand(cmd_Bag, "bag", "", "Type GM [command-name] for more info");
		DC.registerCommand(cmd_Regist, "reg", "", "Type GM [command-name] for more info");
		DC.registerCommand(cmd_EndBattle, "end", "", "Type GM [command-name] for more info");
		DC.registerCommand(cmd_ShowEntity, "entity", "", "Type GM [command-name] for more info");
	}
	
	private function cmd_GM(args:Array<String>):Void
	{
		var input:String = "";
		if (args[0] == null){
			DC.log("GM command is null");
			return;
		}
		
		for (i in args) 
		{
			input += i +" ";
		}
		//Network.instance.NetworkSendPacket(Client_GM_CMD.SNew(input));
	}

	private function cmd_AddMonster(args:Array<String>):Void
	{
		var input:String = "";
		if (args[0] == null){
			DC.log("GM command is null");
			return;
		}
		
		for (i in args) 
		{
			input += i +" ";
		}
		if (args[1] == null)
			args[1] = "1";
		for (j in 0...Std.parseInt(args[1])) 
		{
			var unit:UnitInfo = new UnitInfo();
			unit.faction = BoardFaction.Enemy;
			unit.simType = UnitModelType.Unit;
			unit.id = Std.parseInt(args[0]);
			unit.x = HXP.width * 0.5 + HXP.camera.x;
			unit.y = HXP.height * 0.5;
			GameProcess.root.notify(MsgBoard.CreateUnit, unit);
		}
		
		//Network.instance.NetworkSendPacket(Client_GM_CMD.SNew(input));
	}
	private function cmd_Mission(args:Array<String>):Void
	{
		var input:String = "";
		if (args[0] == null){
			DC.log("GM command is null");
			return;
		}
		for (i in args) 
		{
			input += i +" ";
		}
		trace(input + "   ::===");
		
		GameProcess.root.notify(MsgMission.Add, args);
	}
	/**跳过登录*/
	private function cmd_Login(args:Array<String>):Void
	{
		//if (args[0] == null){
			//DC.log("GM command is null");
			//return;
		//}
		GameProcess.SendUIMsg(MsgUI2.GMLogin,args);
	}
	/*背包增加物品*/
	private function cmd_Bag(args:Array<String>):Void
	{
		var input:String = "";
		if (args[0] == null){
			DC.log("GM command is null");
			return;
		}
		var map:Map<Int,ItemBaseInfo> = new Map();
		var bagInfo = BagUtils.bag;
		var newArr:Array<Int> = new Array();
		var goodsInfo:ItemBaseInfo = null;
		for (i in 0...Std.parseInt(args[1]))
		{
			goodsInfo = GoodsProtoManager.instance.getItemById(Std.parseInt(args[0]));
			if (goodsInfo != null)
			{
				newArr.push(goodsInfo.ID);
			}
		}
		GameProcess.root.notify(MsgNet.UpdateBag, { type:1, data:newArr } );
	}
	
	private function cmd_Regist(args:Array<String>):Void 
	{
		var input:String = "";
		if (args[0] == null){
			DC.log("GM command is null");
			return;
		}
		
		for (i in args) 
		{
			input += i +" ";
		}
		if (args[1] == null)
			args[1] = "1";
	}
	private function cmd_EndBattle(args:Array<String>):Void 
	{
		var input:String = "";
		GameProcess.SendUIMsg(MsgUI.BattleFailure);
		GameProcess.SendUIMsg(MsgUI2.Control, false);
		GameProcess.root.notify(MsgStartup.Finishbattle);
	}
	
	private function cmd_ShowEntity(args:Array<String>):Void 
	{
		var entities = [];
		HXP.scene.getAll(entities);
		trace(entities);
		DC.log("GM command is null");
		
	}

	//private function clone():ItemBaseInfo
	//{
		//return new ItemBaseInfo();
	//}
	private function test(str:String)
	{
		trace(str);
	}
}