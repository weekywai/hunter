package com.metal.message;
/**
 * 输入消息
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	SetInputEnable,
	LostFocus,		//
	UIJoystickInput,	//方向键
	UIInput,			//UI按键
	HoldFire,			//持续攻击
	Attack,				//持续攻击
	DirAttack,			//方向攻击
	Melee,				//刀砍
	Aim,				//瞄准
	ThrowBomb			//扔炸弹
]))
class MsgInput {}