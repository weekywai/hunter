package com.metal.message;
/**
 * ...
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([		
	SetParent,
	UpdateGrid,	
	AddChild,
	ChangeMapSpeed,
	AddDisplayEntity,
	RemoveCmd,			//移除界面cmd
	NewBie				//新手帮助
]))
class MsgView {}