package com.metal.config;
import com.haxepunk.Sfx;
import haxe.EnumTools;
import haxe.EnumTools.EnumValueTools;
//import haxe.ds.ObjectMap;

/**
 * 音乐播放 SfxManager.Audios.get(BGMType.b001).play();
 * @author weeky
 */
enum AudioType {
	Btn;
	t001;
	Gun;
	ShotGun;
	MachineGun;
	LaserGun;
	Fire;
	Grenade;
	Canon;
	Missile;
	Land;
	WalkFloor;
	WalkSand;
	DeadPlayer;
	DeadHuman;
	DeadMachine;
	DeadBoss;
	BossEnter;
	Buff;
	UpGrade;
	Cut;
}
enum BGMType {
	b001;
	b011;
	b012;
	b013;
	b021;
	b022;
	b023;
	b031;
	b032;
	b033;
	Victory;
}

class SfxManager
{
	static public var Audios:Map<String,Sfx> = new Map();
	static public var BGMS:Map<String,Sfx> = new Map();
	static private var audioPaths:Map<String,String> = new Map();
	static private var _BGM:Sfx = null;
	
	static private var _StopSound:Bool;
	static public var StopSound(get, set):Bool;
	static private function set_StopSound(value:Bool):Bool
	{
		if (_StopSound == value)
			return _StopSound;
		_StopSound = value;
		if (!_StopSound) {
			for (key in Audios.keys()) 
			{
				Audios.get(key).stop();
			}
		}
		return _StopSound;
	}
	static private function get_StopSound():Bool { return _StopSound; }
	
	static private var _StopBGM:Bool;
	static public var StopBGM(get, set):Bool;
	static private function set_StopBGM(value:Bool):Bool
	{
		if (_StopBGM == value)
			return _StopBGM;
		_StopBGM = value;
		if(_BGM != null){
			if (!_StopBGM)
				_BGM.stop();
			else
				_BGM.play(1,0,true);
		}
		return _StopBGM;
	}
	static private function get_StopBGM():Bool { return _StopBGM; }
	
	static public function playBMG(name:Dynamic, volume:Float = 1, loop:Bool = true):Void 
	{
		if (_BGM != null)
			_BGM.stop();
			
		_BGM = getBGM(name);
		if (_StopBGM)
			_BGM.play(volume, 0, loop);
	}
	private static var _empty:Sfx;
	
	public function new() 
	{
		_empty = new Sfx(null,null, true);
		setAudio(BGMType.b001,  "sfx/bg/b001.ogg");
		setAudio(BGMType.b011,  "sfx/bg/b011.ogg");
		setAudio(BGMType.b012,  "sfx/bg/b012.ogg");
		setAudio(BGMType.b013,  "sfx/bg/b013.ogg");
		setAudio(BGMType.b021,  "sfx/bg/b021.ogg");
		setAudio(BGMType.b022,  "sfx/bg/b022.ogg");
		setAudio(BGMType.b023,  "sfx/bg/b023.ogg");
		setAudio(BGMType.b031,  "sfx/bg/b031.ogg");
		setAudio(BGMType.b032,  "sfx/bg/b032.ogg");
		setAudio(BGMType.b033,  "sfx/bg/b033.ogg");
		
		
		setAudio(BGMType.Victory,  "sfx/bg/b041.ogg");
		setAudio(AudioType.Btn,  "sfx/sound/u001.ogg");
		setAudio(AudioType.t001,  "sfx/sound/t001.ogg");
		setAudio(AudioType.Gun,  "sfx/sound/a001.ogg");
		setAudio(AudioType.Cut,  "sfx/sound/a005.ogg");
		setAudio(AudioType.ShotGun,  "sfx/sound/a003.ogg");
		setAudio(AudioType.MachineGun,  "sfx/sound/a002.ogg");
		setAudio(AudioType.LaserGun,  "sfx/sound/a004.ogg");
		setAudio(AudioType.Fire,  "sfx/sound/a101.ogg");
		setAudio(AudioType.Grenade,  "sfx/sound/a102.ogg");
		setAudio(AudioType.Canon,  "sfx/sound/a103.ogg");
		setAudio(AudioType.Missile,  "sfx/sound/a104.ogg");
		
		setAudio(AudioType.WalkFloor,  "sfx/sound/r001.ogg");
		setAudio(AudioType.WalkSand,  "sfx/sound/r002.ogg");
		setAudio(AudioType.DeadPlayer,  "sfx/sound/d001.ogg");
		setAudio(AudioType.DeadHuman,  "sfx/sound/d002.ogg");
		setAudio(AudioType.DeadMachine,  "sfx/sound/d003.ogg");
		setAudio(AudioType.DeadBoss,  "sfx/sound/d004.ogg");
		setAudio(AudioType.BossEnter,  "sfx/sound/t021.ogg");
		setAudio(AudioType.Buff,  "sfx/sound/t042.ogg");
		setAudio(AudioType.UpGrade,  "sfx/sound/t031.ogg");
		
	}
	
	static private function setAudio(name:Dynamic, path:String):Void
	{
		audioPaths.set(Std.string(name), path);
	}
	static public function getSound(name:Dynamic):Sfx
	{
		var id = Std.string(name);
		var s = Audios.get(id);
		if (s == null) {
			s = new Sfx(audioPaths.get(id));
			Audios.set(id, s);
		}
		return s;
	}
	static public function getBGM(name:Dynamic):Sfx
	{
		var id = Std.string(name);
		var s = BGMS.get(id);
		if (s == null) {
			s = new Sfx(audioPaths.get(id));
			BGMS.set(id, s);
		}
		return s;
	}
	
	static public function getAudio(name:Dynamic):Sfx
	{
		var sfx:Sfx = null;
		if (Std.is(name, AudioType)) {
			if (!_StopSound)
				sfx = _empty;
			else
				sfx = getSound(name);
		}else if(Std.is(name, BGMType)){
			if (!_StopBGM)
				sfx = _empty;
			else
				sfx = getBGM(name);
		}
		
		return sfx;
	}
	
	static public function getEnumType(name:Dynamic = null):Dynamic 
	{
		
		var list = EnumTools.getConstructors(BGMType);
		if(Lambda.has(list, name))
			return EnumTools.createByName(BGMType, name);
		return null;
	}
	
}