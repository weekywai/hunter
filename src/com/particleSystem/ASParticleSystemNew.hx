package com.particleSystem;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.Atlas;
import com.haxepunk.graphics.atlas.AtlasData.AtlasDataType;
import com.haxepunk.graphics.atlas.AtlasRegion;
import com.haxepunk.HXP;
import com.particleSystem.ASMacros;
import com.particleSystem.ASParticleSystem.ASUPDATE_PARTICLE_IMP;
import com.particleSystem.ASPointExtensions;
import com.particleSystem.ASTypes.ASBlendFunc;
import com.particleSystem.ASTypes.ASColor4F;
import com.particleSystem.ASTypes.GL;
import com.particleSystem.ASTypes.Mode;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
import openfl.display.Tilesheet;


class ASParticleSystemNew extends Graphic
{
	inline static var kCCParticleModeGravity = 0;/** Gravity mode (A mode) */
	inline static var kCCParticleModeRadius = 1;/** Radius mode (B mode) */
	
	inline static var kCCPositionTypeFree = 0;
	inline static var kCCPositionTypeRelative = 1;
	inline static var kCCPositionTypeGrouped = 2;
	
	inline static var kCCParticleDurationInfinity = 0;
	inline static var kCCParticleStartSizeEqualToEndSize = 1;
	inline static var kCCParticleStartRadiusEqualToEndRadius = 2;
	
	private var _region:AtlasRegion;
	private var _sourceRect:Rectangle;
	public var position:Point;
	
	public var duration :Float;
	public var elapsed :Float;

	public var posVar :Point;

	public var angle :Float;
	public var angleVar :Float;


	public var emitterMode :Int;// A or B
	var mode :Mode;

	public var startSize :Float;
	public var startSizeVar :Float;
	var endSize :Float;
	var endSizeVar :Float;

	var life :Float;
	var lifeVar :Float;

	var startColor :ASColor4F;
	var startColorVar :ASColor4F;
	var endColor :ASColor4F;
	var endColorVar :ASColor4F;

	var startSpin :Dynamic = 0;
	var startSpinVar :Dynamic = 0;
	var endSpin :Dynamic = 0;
	var endSpinVar :Dynamic = 0;


	var particles :Array<ASParticle>;
	public var totalParticles :Int;
	public var particleCount :Int = 0;

	var emissionRate :Float;
	var emitCounter :Float;

	var texture_ :Bitmap;
	
	var positionType_ :Int;

	var particleIdx :Int;

	var updateParticleImp :ASUPDATE_PARTICLE_IMP;
	var updateParticleSel :Dynamic;
	var assetsPath:String;
	var textureName:String;
	var lastTime:Int;

	var 					tilesheet:Tilesheet;
	var 					particleBMD:BitmapData;
	var 					drawList:Array<Float>;

	public var 				addBlendMode:Bool;

	public var gravity (get_gravity, set_gravity) :Point;
	public var speed (get_speed, set_speed) :Float;
	public var speedVar (get_speedVar, set_speedVar) :Float;
	public var tangentialAccel (get_tangentialAccel, set_tangentialAccel) :Float;
	public var tangentialAccelVar (get_tangentialAccelVar, set_tangentialAccelVar) :Float;
	public var radialAccel (get_radialAccel, set_radialAccel) :Float;
	public var radialAccelVar (get_radialAccelVar, set_radialAccelVar) :Float;

	public var startRadius (get_startRadius, set_startRadius) :Float;
	public var startRadiusVar (get_startRadiusVar, set_startRadiusVar) :Float;
	public var endRadius (get_endRadius, set_endRadius) :Float;
	public var endRadiusVar (get_endRadiusVar, set_endRadiusVar) :Float;			
	public var rotatePerSecond (get_rotatePerSecond, set_rotatePerSecond) :Float;
	public var rotatePerSecondVar (get_rotatePerSecondVar, set_rotatePerSecondVar) :Float;

	public var texture (get_texture, set_texture) :Bitmap;
	public var blendFunc :ASBlendFunc;

	public var blendAdditive (get_blendAdditive, set_blendAdditive) :Bool;

	public var positionType /*(get_positionType, set_positionType)*/ :Int;

	public var autoRemoveOnFinish /*(get_autoRemoveOnFinish, set_autoRemoveOnFinish)*/ :Bool;

	public function new()
	{
		super();
		emitCounter = 0.;
		elapsed = 0.;
		//trace("ASParticleSystemNew :: new");
		
		//setAtlasRegion(new BitmapData(HXP.width, HXP.height,true,0));
	}



	public static function particleWithFile (plistFile:String,pAssets:String) :ASParticleSystemNew
	{
		
		//trace("ASParticleSystemNew :: particleWithFile - "+plistFile + " - assets: "+pAssets);

		return new ASParticleSystemNew().initWithFile (plistFile+".plist",pAssets);
	}


	public function initWithFile (plistFile:String,pAssets:String) :ASParticleSystemNew
	{
		
		assetsPath = pAssets;
		var path :String = pAssets+plistFile;
		//trace("ASParticleSystemNew :: particleWithFile - "+path);

		var dict :NSDictionary = NSDictionary.dictionaryWithContentsOfFile (path );
		
		if (dict == null) throw "Particles: file not found";
		return this.initWithDictionary ( dict );
	}


	public function initWithDictionary (dictionary:NSDictionary) :ASParticleSystemNew
	{
		//trace("<164>get the something element null(dictionary):"+dictionary);
		var maxParticles :Int = dictionary.valueForKey ( "maxParticles" );
		//trace("<166>get the something element null(maxParticles):"+maxParticles);
		// this, not super
		this.initWithTotalParticles ( maxParticles );
		
		// angle
		angle = dictionary.valueForKey ( "angle" );
		angleVar = dictionary.valueForKey ( "angleVariance" );
		
		// duration
		duration = dictionary.valueForKey ( "duration" );
		//trace("<177>get the something element null(duration):"+duration);
		// color
		var r:Float,g:Float,b:Float,a:Float;
		
		r = dictionary.valueForKey ( "startColorRed" );
		g = dictionary.valueForKey ( "startColorGreen" );
		b = dictionary.valueForKey ( "startColorBlue" );
		a = dictionary.valueForKey ( "startColorAlpha" );
		startColor = {r:r,g:g,b:b,a:a};
		
		r = dictionary.valueForKey ( "startColorVarianceRed" );
		g = dictionary.valueForKey ( "startColorVarianceGreen" );
		b = dictionary.valueForKey ( "startColorVarianceBlue" );
		a = dictionary.valueForKey ( "startColorVarianceAlpha" );
		startColorVar = {r:r,g:g,b:b,a:a};
		
		r = dictionary.valueForKey ( "finishColorRed" );
		g = dictionary.valueForKey ( "finishColorGreen" );
		b = dictionary.valueForKey ( "finishColorBlue" );
		a = dictionary.valueForKey ( "finishColorAlpha" );
		endColor = {r:r,g:g,b:b,a:a};
		
		r = dictionary.valueForKey ( "finishColorVarianceRed" );
		g = dictionary.valueForKey ( "finishColorVarianceGreen" );
		b = dictionary.valueForKey ( "finishColorVarianceBlue" );
		a = dictionary.valueForKey ( "finishColorVarianceAlpha" );
		endColorVar = {r:r,g:g,b:b,a:a};
		
		// particle size
		startSize = dictionary.valueForKey ( "startParticleSize" );
		startSizeVar = dictionary.valueForKey ( "startParticleSizeVariance" );
		endSize = dictionary.valueForKey ( "finishParticleSize" );
		endSizeVar = dictionary.valueForKey ( "finishParticleSizeVariance" );
		
		// position variation
		posVar = new Point();
		//position = new Point();

		var x :Dynamic = dictionary.valueForKey ( "positionx" );
		var y :Dynamic = dictionary.valueForKey ( "positiony" );
		if (x == null) {
			x = dictionary.valueForKey ( "sourcePositionx" );
			y = dictionary.valueForKey ( "sourcePositiony" );
		}
		position = new Point (x,y);
		
		posVar.x = dictionary.valueForKey ( "positionVariancex" );
		posVar.y = dictionary.valueForKey ( "positionVariancey" );
		#if neko
			if (posVar.x == null) {
				posVar.x = dictionary.valueForKey ( "sourcePositionVariancex" );
				posVar.y = dictionary.valueForKey ( "sourcePositionVariancey" );
			}
		#else
		#end
		// Spinning
		startSpin = dictionary.valueForKey ( "rotationStart" );
		if (startSpin == null) startSpin = 0;
		startSpinVar = dictionary.valueForKey ( "rotationStartVariance" );
		if (startSpinVar == null) startSpinVar = 0;
		endSpin = dictionary.valueForKey ( "rotationEnd" );
		endSpinVar = dictionary.valueForKey ( "rotationEndVariance" );
		if (endSpin == null) endSpin = 0;
		if (endSpinVar == null) endSpinVar = 0;
		emitterMode = dictionary.valueForKey ( "emitterType" );

		// Mode A: Gravity + tangential accel + radial accel
		mode = {
			A:{ gravity:new Point(), dir: new Point(), speed:.0, speedVar:.0, tangentialAccel:.0, tangentialAccelVar:.0, radialAccel:.0, radialAccelVar:.0 },
			B:{startRadius:.0, startRadiusVar:.0, endRadius:.0, endRadiusVar:.0, rotatePerSecond:.0, rotatePerSecondVar:.0,deltaRadius: .0,angle: .0,degreesPerSecond: .0,radius: .0 }
		};
		
		if( emitterMode == kCCParticleModeGravity ) {

			//trace("particle system - A");

			// gravity
			mode.A.gravity.x = dictionary.valueForKey ( "gravityx" );
			mode.A.gravity.y = -dictionary.valueForKey ( "gravityy" );
			//mode.A.gravity.y *= -1;


			//
			// speed
			mode.A.speed = dictionary.valueForKey ( "speed" );
			mode.A.speedVar = dictionary.valueForKey ( "speedVariance" );
			
			// radial acceleration			
			var tmp :Null<Float> = dictionary.valueForKey ( "radialAcceleration" );
			mode.A.radialAccel = tmp != null ? tmp : 0.0;
			
			tmp = dictionary.valueForKey ( "radialAccelVariance" );
			mode.A.radialAccelVar = tmp != null ? tmp : 0.0;
						
			// tangential acceleration
			tmp = dictionary.valueForKey ( "tangentialAcceleration" );
			mode.A.tangentialAccel = tmp != null ? tmp : 0.0;
			
			tmp = dictionary.valueForKey ( "tangentialAccelVariance" );
			mode.A.tangentialAccelVar = tmp != null ? tmp : 0.0;
		}
		
		
		// or Mode B: radius movement
		else if( emitterMode == kCCParticleModeRadius ) {

			trace("particle system - B");

			var maxRadius :Float = dictionary.valueForKey ( "maxRadius" );
			var maxRadiusVar :Float = dictionary.valueForKey ( "maxRadiusVariance" );
			var minRadius :Float = dictionary.valueForKey ( "minRadius" );
			
			mode.B.startRadius = maxRadius;
			mode.B.startRadiusVar = maxRadiusVar;
			mode.B.endRadius = minRadius;
			mode.B.endRadiusVar = 0;
			mode.B.rotatePerSecond = dictionary.valueForKey ( "rotatePerSecond" );
			mode.B.rotatePerSecondVar = dictionary.valueForKey ( "rotatePerSecondVariance" );

		} else {
			throw "Invalid emitterType in config file";
		}
		
		// life span
		life = dictionary.valueForKey ( "particleLifespan" );
		lifeVar = dictionary.valueForKey ( "particleLifespanVariance" );				
		
		// emission Rate
		emissionRate = totalParticles/life;

		//Set our blend mode
		if(dictionary.valueForKey("blendFuncDestination") == "1" && dictionary.valueForKey("blendFuncSource") == 770)
		{
			addBlendMode = true;
		}

		else
			addBlendMode = false;

	/**
	LOAD TEXTURE MAP ... ER TILE SHEET
	Fix so that it uses texture map from plist
	**/

		
		// texture		
		// Try to get the texture from the cache
		textureName = dictionary.valueForKey ( "textureFileName" );

		//trace("Texturename = "+textureName);

		//Generate our tilesheet
		//particleBMD = Assets.getBitmapData(assetsPath+textureName);
		particleBMD = HXP.getBitmap(assetsPath+textureName);
			
		tilesheet = new Tilesheet(particleBMD);
		//Center the particle
		tilesheet.addTileRect(new Rectangle (0, 0, particleBMD.width, particleBMD.height), new Point(particleBMD.width / 2, particleBMD.height / 2));
		setAtlasRegion(HXP.getBitmap(assetsPath + textureName));
		var tex :Bitmap = null;//CCTextureCache.sharedTextureCache().addImage ( textureName );

		if( tex != null )
			this.texture = tex;

		else {

			var textureData :String = dictionary.valueForKey ( "textureImageData" );
			var data = null;
		}

		//init our draw list
		drawList = new Array();
		
		return this;
	}

	public function initWithTotalParticles ( numberOfParticles:Int ) :ASParticleSystemNew
	{
		//trace("ASParticleSystemNew - initWithTotalParticles - "+numberOfParticles);

		totalParticles = numberOfParticles;
		
		particles = new Array();
		
		// default, active
		active = true;
		
		positionType_ = kCCPositionTypeFree;
		
		// by default be in mode A:
		emitterMode = kCCParticleModeGravity;
				
		
		autoRemoveOnFinish = false;
		
		updateQuadWithParticle(null, null);

		return this;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		trace("ASParticleEngine :: destroy");
		particles = null;
		texture_ = null;
	}


	//! Add a particle to the emitter
	public function addParticle () :Bool
	{
		if ( this.isFull() ) {
			return false;
		}
		var particle :ASParticle = new ASParticle();
		particles.push(particle);
		
		//超过总粒子数量
		if (particles.length > totalParticles) {
			particles.shift();
		//particleCount--;
		}
	
		//trace("ParticleSystem :: addParticle");

		this.initParticle ( particle );		
		particleCount++;
		
		return true;
	}
	//! Initializes a particle
	public function initParticle (particle:ASParticle)
	{
		// timeToLive
		// no negative life. prevent division by 0
		particle.timeToLive = life + lifeVar * ASMacros.RANDOM_MINUS1_1();	
		particle.timeToLive = Math.max(0,particle.timeToLive);

		// position
		
		particle.pos.x = position.x + posVar.x * ASMacros.RANDOM_MINUS1_1();
		particle.pos.x *= ASConfig.ASCONTENT_SCALE_FACTOR;
		particle.pos.y = position.y + posVar.y * ASMacros.RANDOM_MINUS1_1();
		particle.pos.y *= ASConfig.ASCONTENT_SCALE_FACTOR;
		
		// Color
		var start :ASColor4F = {
			r : ASPointExtensions.clampf( startColor.r + startColorVar.r * ASMacros.RANDOM_MINUS1_1(), 0, 1),
			g : ASPointExtensions.clampf( startColor.g + startColorVar.g * ASMacros.RANDOM_MINUS1_1(), 0, 1),
			b : ASPointExtensions.clampf( startColor.b + startColorVar.b * ASMacros.RANDOM_MINUS1_1(), 0, 1),
			a : ASPointExtensions.clampf( startColor.a + startColorVar.a * ASMacros.RANDOM_MINUS1_1(), 0, 1)
		};


		
		var end :ASColor4F = {
			r : ASPointExtensions.clampf( endColor.r + endColorVar.r * ASMacros.RANDOM_MINUS1_1(), 0, 1),
			g : ASPointExtensions.clampf( endColor.g + endColorVar.g * ASMacros.RANDOM_MINUS1_1(), 0, 1),
			b : ASPointExtensions.clampf( endColor.b + endColorVar.b * ASMacros.RANDOM_MINUS1_1(), 0, 1),
			a : ASPointExtensions.clampf( endColor.a + endColorVar.a * ASMacros.RANDOM_MINUS1_1(), 0, 1)
		};


		
		particle.color = start;

		particle.deltaColor = {
			r: (end.r - start.r) / particle.timeToLive,
			g: (end.g - start.g) / particle.timeToLive,
			b: (end.b - start.b) / particle.timeToLive,
			a: (end.a - start.a) / particle.timeToLive
		};
		
		

		// size
		var startS :Float = startSize + startSizeVar * ASMacros.RANDOM_MINUS1_1();
		startS = Math.max(0, startS); // No negative value
		startS *= ASConfig.ASCONTENT_SCALE_FACTOR;
		
		particle.size = startS;
		if( endSize == kCCParticleStartSizeEqualToEndSize )
			particle.deltaSize = 0;
		else {
			var endS :Float = endSize + endSizeVar * ASMacros.RANDOM_MINUS1_1();
			endS = Math.max(0, endS);	// No negative values
			endS *= ASConfig.ASCONTENT_SCALE_FACTOR;
			particle.deltaSize = (endS - startS) / particle.timeToLive;
		}
		
		// rotation
		var startA :Float = startSpin + startSpinVar * ASMacros.RANDOM_MINUS1_1();
		var endA :Float = endSpin + endSpinVar * ASMacros.RANDOM_MINUS1_1();
		particle.rotation = startA;
		particle.deltaRotation = (endA - startA) / particle.timeToLive;
		
		// position
		if( positionType_ == kCCPositionTypeFree ) {
			var p :Point = new Point(0,0);
			particle.startPos = ASPointExtensions.mult (p,ASConfig.ASCONTENT_SCALE_FACTOR );
		}
		else if( positionType_ == kCCPositionTypeRelative ) {

			var position_ = new Point(this.x,this.y);

			particle.startPos = ASPointExtensions.mult (position_,ASConfig.ASCONTENT_SCALE_FACTOR );
		}
		


		// direction

		//Custom hack to match particle designer / cocos 2d angle 90 degrees shoots upwards, not downards as expected
		var a :Float = ASMacros.ASDEGREES_TO_RADIANS( 360 - (angle + angleVar * ASMacros.RANDOM_MINUS1_1()) );	

		// Mode Gravity: A
		if( emitterMode == kCCParticleModeGravity ) {

			var v :Point = new Point (Math.cos( a ), Math.sin( a ));
			var s :Float = mode.A.speed + mode.A.speedVar * ASMacros.RANDOM_MINUS1_1();

			s *= ASConfig.ASCONTENT_SCALE_FACTOR;

			// direction
			particle.mode.A.dir = ASPointExtensions.mult (v,s );

			// radial accel
			particle.mode.A.radialAccel = mode.A.radialAccel + mode.A.radialAccelVar * ASMacros.RANDOM_MINUS1_1();
			particle.mode.A.radialAccel *= ASConfig.ASCONTENT_SCALE_FACTOR;
			
			// tangential accel
			particle.mode.A.tangentialAccel = mode.A.tangentialAccel + mode.A.tangentialAccelVar * ASMacros.RANDOM_MINUS1_1();
			particle.mode.A.tangentialAccel *= ASConfig.ASCONTENT_SCALE_FACTOR;

		}
		
		// Mode Radius: B
		else {
			// Set the default diameter of the particle from the source position
			var startRadius :Float = mode.B.startRadius + mode.B.startRadiusVar * ASMacros.RANDOM_MINUS1_1();
			var endRadius :Float = mode.B.endRadius + mode.B.endRadiusVar * ASMacros.RANDOM_MINUS1_1();

			startRadius *= ASConfig.ASCONTENT_SCALE_FACTOR;
			endRadius *= ASConfig.ASCONTENT_SCALE_FACTOR;
			
			particle.mode.B.radius = startRadius;

			if( mode.B.endRadius == kCCParticleStartRadiusEqualToEndRadius )
				particle.mode.B.deltaRadius = 0;
			else
				particle.mode.B.deltaRadius = (endRadius - startRadius) / particle.timeToLive;
		
			particle.mode.B.angle = a;
			particle.mode.B.degreesPerSecond = ASMacros.ASDEGREES_TO_RADIANS (mode.B.rotatePerSecond + mode.B.rotatePerSecondVar * ASMacros.RANDOM_MINUS1_1());
			
		}	
	}

	private inline function setAtlasRegion(source:AtlasDataType)
	{
		_region = Atlas.loadImageAsRegion(source);
		blit = false;

		if (_region == null)
			throw "Invalid source image.";

		_sourceRect = new Rectangle(0, 0, _region.width, _region.height);
	}
	override public function renderAtlas(layer:Int, point:Point, camera:Point) 
	{
		_point.x = point.x + x - camera.x * scrollX;
		_point.y = point.y + y - camera.y * scrollY;

		var sx = HXP.screen.fullScaleX, sy = HXP.screen.fullScaleY;
		//_region.draw(Math.floor(_point.x * sx), Math.floor(_point.y * sy), layer, sx, sy);
		draw();
	}

	public function draw()
	{
		//Clear context
		HXP.sprite.graphics.clear();
		
		var TILE_FIELDS = 9; // x+y+index+scale+rotation+alpha
		var particle;
		//trace("see the list" + particles);
		for(i in 0...particles.length)
		{
			particle = particles[i];

			//Setup our tile fields?
			var index = i * TILE_FIELDS;

			drawList[index] = particle.pos.x;
			drawList[index + 1] = particle.pos.y;
			//drawList[index + 2] = 0; // sprite index
			drawList[index + 3] = particle.size/particleBMD.width;			//Scale
			drawList[index + 4] = particle.rotation;	//Rotation
			drawList[index + 5] = particle.color.r;
			drawList[index + 6] = particle.color.g;
			drawList[index + 7] = particle.color.b;
			drawList[index + 8] = particle.color.a;			//Alpha
			_region.draw(particle.pos.x, particle.pos.y, 0, particle.size / particleBMD.width, particle.size / particleBMD.width, particle.rotation, particle.color.r, particle.color.g, particle.color.b, particle.color.a);
		}
	//tilesheet.getTileUVs
	//draw our particle system
		//if(addBlendMode == true)
			//tilesheet.drawTiles(HXP.sprite.graphics, drawList, true, 
			//Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_ALPHA | Tilesheet.TILE_RGB | Tilesheet.TILE_BLEND_ADD);

		//else
			//tilesheet.drawTiles(HXP.sprite.graphics, drawList, true, 
			//Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_ALPHA | Tilesheet.TILE_RGB | Tilesheet.TILE_BLEND_NORMAL);
	}

	public function stopSystem ()
	{
		active = false;
		elapsed = duration;
		emitCounter = 0;
	}
	public function resetSystem ()
	{
		active = true;
		elapsed = 0;
		for(particleIdx in 0...particleCount) {
			var p :ASParticle = particles[particleIdx];
			p.timeToLive = 0;
		}
	}
	//! whether or not the system is full
	inline public function isFull () :Bool
	{
		return (particleCount == totalParticles);
	}




	// ParticleSystem - MainLoop
	override public function update() 
	{
		super.update();
		//trace("ASParticleSystemNew - update");

		if( active && emissionRate > 0 ) {
			var rate :Float = 1.0 / emissionRate;
			emitCounter += HXP.elapsed;
			while ( particleCount < totalParticles && emitCounter > rate ) {
				this.addParticle();
				emitCounter -= rate;
			}
			
			elapsed += HXP.elapsed;
			if(duration != -1 && duration < elapsed)
				this.stopSystem();
		}
		
		particleIdx = 0;
		
		var currentPosition :Point = new Point(0,0);
		
		if( positionType_ == kCCPositionTypeFree ) {
			currentPosition = new Point(0,0);
			currentPosition.x *= ASConfig.ASCONTENT_SCALE_FACTOR;
			currentPosition.y *= ASConfig.ASCONTENT_SCALE_FACTOR;
		}
		else if( positionType_ == kCCPositionTypeRelative ) {

			var position_ = new Point(this.x,this.y);
			currentPosition = position_;
			currentPosition.x *= ASConfig.ASCONTENT_SCALE_FACTOR;
			currentPosition.y *= ASConfig.ASCONTENT_SCALE_FACTOR;
		}

		
		while( particleIdx < particleCount )
		{
			var p :ASParticle = particles[particleIdx];
			
			// life
			p.timeToLive -= HXP.elapsed;

			

			if( p.timeToLive > 0 ) {
				
				// Mode A: gravity, direction, tangential accel & radial accel
				if( emitterMode == kCCParticleModeGravity ) 
				{

					var tmp, radial, tangential :Point;
					
					radial = new Point(0,0);
					// radial acceleration
					if(p.pos.x > 0 || p.pos.y > 0)
						radial = ASPointExtensions.normalize(p.pos);
					tangential = radial;

					radial = ASPointExtensions.mult(radial,p.mode.A.radialAccel);

					// tangential acceleration
					var newy :Float = tangential.x;
					tangential.x = - tangential.y;
					tangential.y = newy;
					tangential = ASPointExtensions.mult (tangential,p.mode.A.tangentialAccel );

					// (gravity + radial + tangential) * dt
					//tmp = radial.add ( tangential ).add ( mode.A.gravity );

					tmp = ASPointExtensions.add(radial,tangential);
					tmp = ASPointExtensions.add(tmp,mode.A.gravity);

					tmp = ASPointExtensions.mult (tmp,HXP.elapsed );
					p.mode.A.dir = ASPointExtensions.add(p.mode.A.dir,tmp);
					tmp = ASPointExtensions.mult (p.mode.A.dir,HXP.elapsed );
					p.pos = ASPointExtensions.add (p.pos,tmp);
				}
				
				// Mode B: radius movement
				else {			
					// Update the angle and radius of the particle.
					p.mode.B.angle += p.mode.B.degreesPerSecond * HXP.elapsed;
					p.mode.B.radius += p.mode.B.deltaRadius * HXP.elapsed;
					
					p.pos.x = - Math.cos(p.mode.B.angle) * p.mode.B.radius;
					p.pos.y = - Math.sin(p.mode.B.angle) * p.mode.B.radius;
				}
				
				// color
				p.color.r += (p.deltaColor.r * HXP.elapsed);
				p.color.g += (p.deltaColor.g * HXP.elapsed);
				p.color.b += (p.deltaColor.b * HXP.elapsed);
				p.color.a += (p.deltaColor.a * HXP.elapsed);
				
				// size
				p.size += (p.deltaSize * HXP.elapsed);
				p.size = Math.max( 0, p.size );
				
				// angle
				p.rotation += (p.deltaRotation * HXP.elapsed);
							
				//
				// update values in quad
				//
				
				var newPos :Point = null;
				
				if( positionType_ == kCCPositionTypeFree || positionType_ == kCCPositionTypeRelative ) {
					
					var diff :Point = ASPointExtensions.sub( currentPosition, p.startPos );
					newPos = ASPointExtensions.sub(p.pos, diff);
					
				} else
					newPos = p.pos;
				
	/**

	UPDATE PARTICLE IN EITHER POINT OR QUAD SYSTEM
	**/
				//updateParticleImp.SEL (this, updateParticleSel, p, newPos);
				// update particle counter
				particleIdx++;
				
			} else {
				// life < 0

				//trace("Life < 0");

				//If this is not the last particle
				if( particleIdx != particleCount-1 )
				{
					
					//particles[particleIdx] = particles[particleCount-1];
					//removeChild(particles[particleIdx].test);

					//Remove particle
					particles.splice(particleIdx,1);
				}
					
				particleCount--;
				
				if( particleCount == 0 && autoRemoveOnFinish ) {
					//this.unscheduleUpdate();
					//parent.removeChild(this);
					throw "remove";
					return;
				}
			}
		}
		
	#if ASENABLE_PROFILERS
		CCProfilingEndTimingBlock(_profilingTimer);
	#end
		
	#if ASUSES_VBO
		this.postStep();
	#end
	}

	public function updateQuadWithParticle (particle:ASParticle, pos:Point) :Void
	{
		// should be overriden
	}

	public function postStep ()
	{
		// should be overriden
	}

	// ParticleSystem - CCTexture protocol

	public function set_texture (texture:Bitmap) :Bitmap
	{
		if (texture_ != null)
			texture_ = null;
		texture_ = texture;

		// If the new texture has No premultiplied alpha, AND the blendFunc hasn't been changed, then update it
		if( texture_ != null  /*&&
			   ( blendFunc.src == ASBLEND_SRC && blendFunc.dst == ASBLEND_DST )*/)
		{
			blendFunc.src = GL.SRC_ALPHA;
			blendFunc.dst = GL.ONE_MINUS_SRC_ALPHA;
		}
		return texture_;
	}

	public function get_texture () :Bitmap
	{
		return texture_;
	}

	// ParticleSystem - Additive Blending
	public function set_blendAdditive ( additive:Bool ) :Bool
	{
		if( additive ) {
			blendFunc.src = GL.SRC_ALPHA;
			blendFunc.dst = GL.ONE;

		} else {
			
	/*		if( texture_ != null && ! texture_.hasPremultipliedAlpha ) {
				blendFunc.src = GL.SRC_ALPHA;
				blendFunc.dst = GL.ONE_MINUS_SRC_ALPHA;
			} else {
				blendFunc.src = ASMacros.ASBLEND_SRC;
				blendFunc.dst = ASMacros.ASBLEND_DST;
			}*/
		}
		return additive;
	}

	public function get_blendAdditive () :Bool
	{
		return false;//( blendFunc.src == GL.SRC_ALPHA && blendFunc.dst == GL.ONE);
	}

	// ParticleSystem - Properties of Gravity Mode 
	public function set_tangentialAccel ( t:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.tangentialAccel = t;
	}
	public function get_tangentialAccel () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.tangentialAccel;
	}

	public function set_tangentialAccelVar ( t:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.tangentialAccelVar = t;
	}
	public function get_tangentialAccelVar () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.tangentialAccelVar;
	}

	public function set_radialAccel ( t:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.radialAccel = t;
	}
	public function get_radialAccel () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.radialAccel;
	}

	public function set_radialAccelVar ( t:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.radialAccelVar = t;
	}
	public function get_radialAccelVar () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.radialAccelVar;
	}

	public function set_gravity ( g:Point ) :Point
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.gravity = g;
	}
	public function get_gravity () :Point
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.gravity;
	}

	public function set_speed ( speed:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.speed = speed;
	}
	public function get_speed () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.speed;
	}

	public function set_speedVar ( speedVar:Float ) :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.speedVar = speedVar;
	}
	public function get_speedVar () :Float
	{
		if (emitterMode != kCCParticleModeGravity) throw "Particle Mode should be Gravity";
		return mode.A.speedVar;
	}

	// ParticleSystem - Properties of Radius Mode

	public function set_startRadius ( startRadius:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.startRadius = startRadius;
	}
	public function get_startRadius () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.startRadius;
	}

	public function set_startRadiusVar ( startRadiusVar:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.startRadiusVar = startRadiusVar;
	}
	public function get_startRadiusVar () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.startRadiusVar;
	}

	public function set_endRadius ( endRadius:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.endRadius = endRadius;
	}
	public function get_endRadius () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.endRadius;
	}

	public function set_endRadiusVar ( endRadiusVar:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.endRadiusVar = endRadiusVar;
	}
	public function get_endRadiusVar () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.endRadiusVar;
	}

	public function set_rotatePerSecond ( degrees:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.rotatePerSecond = degrees;
	}
	public function get_rotatePerSecond () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.rotatePerSecond;
	}

	public function set_rotatePerSecondVar ( degrees:Float ) :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.rotatePerSecondVar = degrees;
	}
	public function get_rotatePerSecondVar () :Float
	{
		if (emitterMode != kCCParticleModeRadius) throw "Particle Mode should be Radius";
		return mode.B.rotatePerSecondVar;
	}
}
