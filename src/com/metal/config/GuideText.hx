package com.metal.config;

/**
 * ...
 * @author 
 */
class GuideText
{
	static public inline var SkillName0:String = "手榴弹";
	static public inline var SkillName1:String = "空中支援";
	static public inline var SkillName2:String = "超级火力";
	static public inline var SkillName3:String = "离子护罩";
	static public inline var SkillName4:String = "治疗";
	
	static public inline var SkillDes0:String = "使用手榴弹攻击10码内所以敌人，造成3倍武器攻击伤害。";
	static public inline var SkillDes1:String = "求救总部释放远程武器支持，对所有敌人造成10倍武器攻击的伤害";
	static public inline var SkillDes2:String = "进入暴走状态，攻击和攻击速度增加100%，持续15秒。";
	static public inline var SkillDes3:String = "免疫一切伤害，持续10秒。";
	static public inline var SkillDes4:String = "恢复50%的生命值。";
	
	static public inline var SkillPrice1:String = "充值任意金额";
	static public inline var SkillPrice2:String = "累计充值10元";
	static public inline var SkillPrice3:String = "累计充值50元";
	static public inline var SkillPrice4:String = "累计充值100元";
	
	static public inline function Duplicate(type:Int):String {
		switch(type) {
			case 9:	return "无尽副本";
			case 10:return "护甲副本";
			case 11:return "武器副本金钱副本";
			case 12:return "金钱副本";
			default: return "";
		}
		
	}
	public function new() 
	{
		
	}
	
}