package com.metal.unit.ai.type;
import com.metal.unit.bevtree.BevNode;

/**
 * ...
 * @author li
 */
class AiFactory
{
	public static var instance(get, null):AiFactory;
	private static function get_instance():AiFactory {
		if (instance == null)
			instance = new AiFactory();
		return instance; 
	}
	
	public function new() 
	{
		
	}
	
	public function createAI(type:Int):BevNode
	{
		var ai:BevNode;
		//trace("type :: " + type);
		switch(type) {
			case 0: ai = new RoleAI().createAI(); //主角ai
			case 1: ai = new Humanoid1().createAI(); //种植站桩
			case 2: ai = new Humanoid2().createAI(); //种植追击（到攻击范围内攻击）
			case 3: ai = new Humanoid3().createAI(); //种植追击（追到身边）
			case 4: ai = new HelicopterAI1().createAI(); //进场站桩
			case 5: ai = new HelicopterAI3().createAI(); //进场追击（到攻击范围内攻击）
			case 6: ai = new HelicopterAI2().createAI(); //进场追击（追到身边）
			case 7: ai = new BossAI1().createAI();	//b031
			case 8: ai = new BossAI2().createAI(); //b011
			case 9: ai = new BossAI3().createAI(); //b021
			case 10: ai = new BossAI4().createAI(); //b041
			case 11: ai = new BossAI5().createAI(); //b001
			case 12: ai = new EliteAI().createAI(); //精英AI
			//case 9: ai = new NpcAI().createAI(); //npc
			default: ai = new Humanoid1().createAI();
		}
		
		return ai;
	}
	
}