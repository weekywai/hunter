package com.metal.proto.impl;

/**
 * ...
 * @author 3D
 */
class EquipItemBaseInfo extends ItemBaseInfo
{

	public function new() 
	{
		super();
		
	}
	
	/**strength_level （uint） 强化等级**/
	public var itemStr:Int;
	/**特性描述**/
	//public var Characteristic:String;
	/**装备类型**/
	public var equipType:Int;
	/**强化经验**/
	public var strExp:Int=0;
	
}