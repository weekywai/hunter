package com.metal.config;

/**
 * 物品ID表
 * @author weeky
 */
class ItemType
{
	/**装备*/
	public static inline var  IK1_EQUIP:Int = 1;
	/**可使用类*/
	public static inline var  IK1_CANUSE:Int = 2;
	/**材料*/
	public static inline var  IK1_VOUCHER:Int = 3;
	/**凭证*/
	public static inline var  IK1_OTHER:Int = 4;
	/**货币*/
	public static inline var  IK1_MONEY:Int = 5;
	/**资源*/
	public static inline var  IK1_RESOURCES:Int = 6;
	/**枪械1*/
	public static inline var  IK2_GON:Int = 1;
	/**时装2*/
	public static inline var  IK2_FASHION:Int = 2;
	/**宠物3*/
	public static inline var  IK2_PET:Int = 3;
	/**枪械进阶材料4*/
	public static inline var  IK2_GON_PROMOTED:Int = 4;
	/**枪械强化材料5*/
	public static inline var  IK2_GON_UPGRADE:Int = 5;
	/**宠物进阶材料6*/
	//public static inline var  IK2_PET_PROMOTED:Int = 6;
	/**宠物强化材料7*/
	//public static inline var  IK2_PET_UPGRADE:Int = 7;
	/**钻石14*/
	public static inline var  IK2_DIAMOND:Int = 8;
	/**金币15*/
	public static inline var  IK2_GOLD:Int = 9;
	/**经验16*/
	public static inline var  IK2_EXP:Int = 10;
	/**体力17*/
	public static inline var  IK2_ENERGY:Int = 11;
	/**积分18*/
	public static inline var  IK2_POINT:Int = 12;
	/**护甲13*/
	public static inline var  IK2_ARM:Int = 13;
	/**BUFF 类道具**/
	public static inline var IK2_BUFF:Int = 14;
	/**开启副本的钥匙**/
	public static inline var IK2_PROPS:Int = 15;
	
	/**进阶材料1 ID**/
	public static inline var AdvanceMaterial_1:Int = 10104;
	/**进阶材料2 ID**/
	public static inline var AdvanceMaterial_2:Int = 10105;
	/**进阶材料3 ID**/
	public static inline var AdvanceMaterial_3:Int = 10106;
	
	/**用于接口判断**/
	public static inline var NORMAL_TYPE:Int = 1;
	public static inline var EQUIP_TYPE:Int = 2;
	public static inline var ARMS_TYPE:Int = 3;//护甲
	
	
	
	public function new() 
	{
	}
}