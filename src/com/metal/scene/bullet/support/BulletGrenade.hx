package com.metal.scene.bullet.support;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.TextrueSpritemap;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.metal.config.ResPath;
import com.metal.config.SfxManager;
import com.metal.enums.Direction;
import com.metal.message.MsgItr;
import com.metal.proto.impl.BulletInfo;
import com.metal.scene.board.impl.BattleResolver;
import com.metal.scene.bullet.api.BulletHitInfo;
import com.metal.scene.bullet.api.BulletRequest;
import com.metal.scene.bullet.impl.BulletEntity;
import com.metal.unit.actor.impl.BaseActor;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.actor.impl.UnitActor;
import com.metal.unit.render.ViewDisplay;
import openfl.geom.Point;
/**
 * 主角手雷
 * @author 3D
 */
class BulletGrenade extends BulletEntity
{

	private var _bulletGraphic:TextrueSpritemap;
	private var _box:Image;
	/**运动轨迹辅助参数**/
	private var xSpeed:Float;
	private var ySpeed:Float;
	private var t0:Float = 0;//x轴
	private var t1:Float = 30;//y轴
	private var g:Float = 0.9;//重力加速度
	private var angel:Float = 0;
	private var _dir:Bool;//默认向右
	private var _startPoint:Point;//丢出去的x,y
	/**延后检测出屏幕时间*/
	private var _delay:Int;
	private var _collides:Array<Entity>;
	
	public function new(x:Float=0, y:Float=0) 
	{
		super(x, y);
	}
	override private function onDispose():Void 
	{
		_bulletGraphic.destroy();
		_bulletGraphic = null;
		super.onDispose();
	}
	
	override public function setInfo(info:BulletInfo):Void
	{
		super.setInfo(info);
		_collides = [];
		//_bulletGraphic = new Image(ResPath.getBulletRes(info.img));
		var atlas:TextureAtlasFix = TextureAtlasFix.loadTexture(ResPath.getBulletRes(info.img));
		if(_bulletGraphic==null){
			_bulletGraphic = new TextrueSpritemap(atlas);
		}else {
			_bulletGraphic.resetTexture(atlas);
		}
		_bulletGraphic.add("grende", atlas.getReginCount(), 25, false);
		
		_bulletGraphic.play("grende", true);
		_bulletGraphic.scale = 1;
		
		if (_box != null)
			_box.destroy();
		_box = Image.createCircle(Std.int(_bulletGraphic.height * 0.5));
		_box.centerOO();
		setHitboxTo(_box);
		graphic = _bulletGraphic;
		t0 = 0;
		_delay = 60;
	}
	override public function start(req:BulletRequest):Void 
	{
		super.start(req);
		//trace(x + ":" + y);
		var parabola = y - req.info.param * 0.5;// * HXP.screen.scale;//从屏幕底部算起
		_dir = req.dir == Direction.RIGHT;
		x += (_dir)?90: -50; //偏移起始
		
		var dis = 220 * HXP.screen.scale;
		var pos:Point = new Point((_dir?x + dis:x - dis), parabola);//704刚好是落地的Y
		var actor:BaseActor = cast req.attacker.getComponent(MTActor);
		if (actor == null)
			actor = cast req.attacker.getComponent(UnitActor);
		if (actor!=null && actor.acceleration.x != 0) {
			var velocity = (compute(0, actor.acceleration.x, 0)) * 0.3 * HXP.elapsed +1;
			trace(velocity + ">>" + pos.x + ">>star:" + x);
			if (velocity > 1.15)
				velocity = 1.15;
			pos.x = pos.x * velocity;
		}
		xSpeed = (pos.x - x) / t1;
		ySpeed = (((pos.y - y) - ((g * t1) * (t1 / 2))) / t1);
		//_fightPoint = new Point(_attacker.getComponent(MTActor).x, _attacker.getComponent(MTActor).y);
		_startPoint = new Point(x, y);
		
		_bulletGraphic.centerOO();
		_effectReq.angle = 90;
		req.targetX = 0;
	}
	override public function update():Void 
	{
		if (isDisposed)
			return;
		super.update();
		moveGrenade();
		if (_collides.length==0) {
			onCollide();
		}
		_delay--;
		if (_delay <= 0) {
			if (computeInCamera()) {
				//trace("not in camera");
				if (scene != null) 
					recycle();
			}
		}
	}
	
	/**抛物线丢雷*/
	private function moveGrenade():Void{
		t0++;
		//x轴要根据朝向
		x = _startPoint.x + t0 * xSpeed;
		y = _startPoint.y + (( -80 + (t0 * ySpeed)) + (((g * t0) * t0) / 2));
		var randomA:Float = Math.random() * 10 + 20;
		angel = angel +(_dir? -randomA:randomA);
		_bulletGraphic.angle = angel;// * 180 / Math.PI + 180;
		
	}
	
	override function onCollide():Void 
	{
		if (_collides.length > 0) return;
		collideTypesInto(_collideTypes, x, y, _collides);
		if (_collides.length > 0) {
			SfxManager.getAudio(AudioType.Canon).play();
			for (e in _collides) 
			{
				if(e.type != "solid")
				{
					var avatar:ViewDisplay = cast(e, ViewDisplay);
					var hit = new BulletHitInfo();
					hit.target = avatar.owner;
					hit.atk = _hitInfo.atk;
					hit.fix = _hitInfo.fix;
					hit.buffId = _hitInfo.buffId;
					hit.buffTarget = _hitInfo.buffTarget;
					hit.buffTime = _hitInfo.buffTime;
					hit.renderType = BattleResolver.resolveAtk(_hitInfo.critPor);
					owner.notify(MsgItr.BulletHit, hit);
				}
			}
			commitEffect();
			recycle();
		}
	}
	
}