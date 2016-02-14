package com.metal.scene.effect.impl;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.metal.scene.effect.api.IEffect;
import com.metal.scene.effect.support.EffectBoom1;
import com.metal.scene.effect.support.EffectBoom2;
import com.metal.scene.effect.support.EffectImage;
import com.metal.scene.effect.support.EffectSkeleton;
import com.metal.scene.effect.support.EffectText;
import com.metal.scene.effect.support.EffectTexture;
import haxe.ds.IntMap;

/**
 * ...
 * @author weeky
 */
using com.metal.enums.EffectEnum.EffectAniType;
class EffectFactory
{
	public static var instance(default, null):EffectFactory = new EffectFactory();
	
	private var _class:IntMap<Class<Entity>>;
	public function new() 
	{
		_class = new IntMap();
		_class.set(EffectAniType.Image, EffectImage);
		_class.set(EffectAniType.Texture, EffectTexture);
		_class.set(EffectAniType.Skeleton, EffectSkeleton);
		_class.set(EffectAniType.Boom1, EffectBoom1);
		_class.set(EffectAniType.Boom2, EffectBoom2);
		_class.set(EffectAniType.Text, EffectText);
	}
	
	public function createEffect(type:Int):IEffect
	{
		var cls = _class.get(type);
		if (cls == null) throw ("Effect teamplate not found : " + type);
		var entity = HXP.scene.create(cls, false);
		return untyped entity;
	}
}