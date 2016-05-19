package com.metal.message;

/**
 * ...
 * @author weeky
 */
@:build(de.polygonal.core.event.ObserverMacro.create
([
	BulletHit, 		//子弹
	Melee, 			//近身
	Destory,
	Score,
	Gold,
	KillBoss,
	AddLockEnemey
	
]))
class MsgItr{}