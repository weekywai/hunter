package com.haxepunk.graphics;

import com.haxepunk.graphics.AnimationFix;
import com.haxepunk.graphics.atlas.TextureAtlasFix;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import haxe.ds.StringMap;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import signals.Signal1;

/**
 * ...
 * @author weeky
 */
class TextrueSpritemap extends Image
{
	/**
	 * If the animation has stopped.
	 */
	public var complete:Bool;

	/**
	 * Optional callback function for animation end.
	 */
	public var animationEnd:Signal1<String>;

	/**
	 * Animation speed factor, alter this to speed up/slow down all animations.
	 */
	public var rate:Float;
	
	
	/**
	 * Constructor.
	 * @param	source			Source TextrueAtlas.
	 * @param	frameWidth		Frame width.
	 * @param	frameHeight		Frame height.
	 * @param	callback		Optional callback function for animation end.
	 */
	public function new(source:TextureAtlasFix, autoPlay:Bool = true)
	{
		complete = true;
		rate = 1;
		_anims = new StringMap<AnimationFix>();
		_timer = _frame = 0;
		blit = false;
		_atlas = source;
		var names:Iterator<String> = _atlas.getRegionNames();
		_frameCount = _atlas.getReginCount();
		_region = _atlas.getRegion(names.next());
		
		animationEnd = new Signal1();

		_imageWidth = Std.int(_region.width);
		_imageHeight = Std.int(_region.height);
		_rect = new Rectangle(0, 0, _imageWidth, _imageHeight);
		super(_region, _rect);
		

		updateBuffer();
		active = autoPlay;
		//trace(_region.center+"::::"+originX);
	}
	
	override public function destroy() 
	{
		if(animationEnd!=null)
		animationEnd.removeAll();
		animationEnd = null;
		_atlas = null;
		_rect = null;
		_anims = null;
		_anim = null;
		super.destroy();
	}
	
	public function resetTexture(source:TextureAtlasFix, ?callbackFun:Dynamic):Void 
	{
		complete = true;
		rate = 1;
		_anims = new StringMap<AnimationFix>();
		_timer = _frame = 0;
		_atlas = source;
		var names:Iterator<String> = _atlas.getRegionNames();
		_frameCount = _atlas.getReginCount();
		_region = _atlas.getRegion(names.next());
		
		if(animationEnd!=null){
			animationEnd.removeAll();
			if (callbackFun != null)
				animationEnd.addOnce(callbackFun);
		}

		_imageWidth = Std.int(_region.width);
		_imageHeight = Std.int(_region.height);
		_rect = new Rectangle(0, 0, _imageWidth, _imageHeight);

		updateBuffer();
		//active = true;
	}
	/** @private Creates the buffer. */
	override private function createBuffer()
	{
		if (_imageWidth == 0) _imageWidth = Std.int(_sourceRect.width);
		if (_imageHeight == 0) _imageHeight = Std.int(_sourceRect.height);
		_buffer = HXP.createBitmap(_imageWidth, _imageHeight, true);
		_bufferRect = _buffer.rect;
	}
	/**
	 * Updates the spritemap's buffer.
	 */
	override public function updateBuffer(clearBefore:Bool = false)
	{
		if (blit)
		{
			// get position of the current frame
			_rect.x = _rect.width * _frame;
			_rect.y = Std.int(_rect.x / _imageWidth) * _rect.height;
			_rect.x %= _imageWidth;
			if (flipped) _rect.x = (_imageWidth - _rect.width) - _rect.x;

			// render it repeated to the buffer
			var xx:Int = Std.int(_offsetX) % _imageWidth,
				yy:Int = Std.int(_offsetY) % _imageHeight;
			if (xx >= 0) xx -= _imageWidth;
			if (yy >= 0) yy -= _imageHeight;
			HXP.point.x = xx;
			HXP.point.y = yy;
			while (HXP.point.y < _imageHeight)
			{
				while (HXP.point.x < _imageWidth)
				{
					_buffer.copyPixels(_source, _sourceRect, HXP.point);
					HXP.point.x += _sourceRect.width;
				}
				HXP.point.x = xx;
				HXP.point.y += _sourceRect.height;
			}

			// tint the buffer
			if (_tint != null) _buffer.colorTransform(_bufferRect, _tint);
			super.updateBuffer(clearBefore);
		}
		else
		{
			super.updateBuffer(clearBefore);
			_region = _atlas.getRegionByIndex(_frame);
			//originX = Std.int(width / 2);
			//originY = Std.int(height / 2);
			
		}
		//if (_flipped) _rect.x = (_imageWidth - _rect.width) - _rect.x;
	}
	
	/** Renders the image. */
	override public function renderAtlas(layer:Int, point:Point, camera:Point)
	{
		//atlasSet(layer, point, camera);
		atlasSetImage(layer, point, camera);
	}
	private function atlasSetImage(layer:Int, point:Point, camera:Point):Void 
	{
		var sx = scale * scaleX,
			sy = scale * scaleY,
			fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY;
		_point.x = point.x + x - originX - camera.x * scrollX;
		_point.y = point.y + y - originY - camera.y * scrollY;
		
		if (angle == 0)
		{
			if (!(sx == 1 && sy == 1))
			{
				_point.x = (point.x + x - originX * sx - camera.x * scrollX);
				_point.y = (point.y + y - originY * sy - camera.y * scrollY);
			}
			
			if (_flipped)
				_point.x += _sourceRect.width * sx;
			_point.x = Math.floor(_point.x * fsx);
			_point.y = Math.floor(_point.y * fsy);

			_region.draw(_point.x, _point.y, layer,
				sx * fsx * (_flipped ? -1 : 1), sy * fsy, angle,
				_red, _green, _blue, _alpha);
		}
		else
		{
			var theta = angle * HXP.RAD;
			var cos = Math.cos(theta);
			var sin = Math.sin(theta);

			if (flipped) sx *= -1;

			var b = sx * fsx * sin;
			var a = sx * fsx * cos;

			var d = sy * fsy * cos;
			var c = sy * fsy * -sin;

			var tx = -originX  * sx,
				ty = -originY * sy;
			var tx1 = tx * cos - ty * sin;
			ty = ((tx * sin + ty * cos) + originY + _point.y) * fsy;
			tx = (tx1 + originX + _point.x ) * fsx;

			_region.drawMatrix(Std.int(tx), Std.int(ty), a, b, c, d, layer, _red, _green, _blue, _alpha);
		}
	}
	private function atlasSet(layer:Int, point:Point, camera:Point):Void 
	{
		//trace("before:"+_flipped+":::"+_point);
		_point.x = point.x + x - originX - camera.x * scrollX;
		_point.y = point.y + y - originY - camera.y * scrollY;
		//trace("after:"+_flipped+":::"+_point+":::"+camera+":::"+scrollX);
		if (_flipped) {
			//if(angle == 0)
				//_point.x += (_sourceRect.width - _region.offset.x);
			//else
				_point.x += (_sourceRect.width);
		}
		var fsx = HXP.screen.fullScaleX,
			fsy = HXP.screen.fullScaleY,
			sx = fsx * scale * scaleX,
			sy = fsy * scale * scaleY,
			x = 0.0, y = 0.0;

		while (y < _imageHeight)
		{
			while (x < _imageWidth)
			{
				_region.draw(Math.floor((_point.x + x) * fsx), Math.floor((_point.y + y) * fsy),
					layer, sx * (_flipped ? -1 : 1), sy, angle,
					_red, _green, _blue, _alpha);
				x += _sourceRect.width;
			}
			x = 0;
			y += _sourceRect.height;
		}
	}
	
	/** @private Updates the animation. */
	override public function update()
	{
		//super.update();
		//trace(_anim.name +"  ::  " + complete);
		if (_anim != null && !complete)
		{
			//trace(_anim.name +"  :--:  " + complete);
			_timer += (HXP.fixed ? _anim.frameRate / HXP.frameRate : _anim.frameRate * HXP.elapsed) * rate; 
			if (_timer >= 1)
			{
				while (_timer >= 1)
				{
					_timer --;
					_index ++;
					
					//if (_index == _anim.frameCount)
					//trace(_index+"  "+ _frameCount+"  "+_anim.name);
					if (_index == _frameCount)
					{
						//trace(_anim.loop+"  "+_anim.name);
						if (_anim.loop)
						{
							_index = 0;
							
							//if (animationEnd.numListeners> 0) 
								animationEnd.dispatch(_anim.name);
						}
						else
						{
							_index = _anim.frameCount - 1;
							complete = true;
							//if (animationEnd.numListeners> 0) 
								animationEnd.dispatch(_anim.name);
							break;
						}
					}
				}
				if (_anim != null) {
					if (_anim.frames.length <= _index)//TODO modify  length=1 index必须=0
						_frame = Std.int(_anim.frames[0]);
					else
						_frame = Std.int(_anim.frames[_index]);
				}
				updateBuffer();
			}
		}
	}

	/**
	 * Add an Animation.
	 * @param	name		Name of the animation.
	 * @param	frames		Array of frame indices to animate through.
	 * @param	frameRate	Animation speed.
	 * @param	loop		If the animation should loop.
	 * @return	A new Anim object for the animation.
	 */
	public function add(state:String, frameCount:Int, frameRate:Float = 0, loop:Bool = true):AnimationFix
	{
		var frames:Array<Int> = [];
		for (i in 0...frameCount)
		{
			frames[i] = i;
		}
		var name:String = state;
		var anim:AnimationFix = new AnimationFix(name, frames, frameRate, loop);
		_anims.set(name, anim);
		anim.parent = this;
		return anim;
	}

	/**
	 * Plays an animation.
	 * @param	name		Name of the animation to play.
	 * @param	reset		If the animation should force-restart if it is already playing.
	 * @return	Anim object representing the played animation.
	 */
	public function play(name:String = "", reset:Bool = false):AnimationFix
	{
		if (!reset && _anim != null && _anim.name == name) return _anim;
		if (_anims.exists(name))
		{
			
			_anim = _anims.get(name);
			//trace("exites:: "+_anim.name);
			_timer = _index = 0;
			_frame = _anim.frames[0];
			complete = false;
		}
		else
		{
			//trace("null:: "+_anim.name);
			_anim = null;
			_frame = _index = 0;
			complete = true;
		}
		updateBuffer();
		return _anim;
	}

	/**
	 * Gets the frame index based on the column and row of the source image.
	 * @param	column		Frame column.
	 * @param	row			Frame row.
	 * @return	Frame index.
	 */
	public inline function getFrame(column:Int = 0, row:Int = 0):Int
	{
		return 0;
	}

	/**
	 * Sets the current display frame based on the column and row of the source image.
	 * When you set the frame, any animations playing will be stopped to force the frame.
	 * @param	column		Frame column.
	 * @param	row			Frame row.
	 */
	public function setFrame(starFrame:Int = 0, endFrame:Int = 0)
	{
		_index = starFrame;
		_frameCount = endFrame;
		updateBuffer();
	}

	/**
	 * Sets the frame to the frame index of an animation.
	 * @param	name	Animation to draw the frame frame.
	 * @param	index	Index of the frame of the animation to set to.
	 */
	public function setAnimFrame(name:String, index:Int)
	{
		var frames:Array<Int> = _anims.get(name).frames;
		index = index % frames.length;
		if (index < 0) index += frames.length;
		frame = frames[index];
	}

	/**
	 * Sets the current frame index. When you set this, any
	 * animations playing will be stopped to force the frame.
	 */
	public var frame(get, set):Int;
	private function get_frame():Int { return _frame; }
	private function set_frame(value:Int):Int
	{
		_anim = null;
		//value %= _frameCount;
		//if (value < 0) value = _frameCount + value;
		if (_frame == value) return _frame;
		_frame = value;
		updateBuffer();
		return _frame;
	}

	/**
	 * Current index of the playing animation.
	 */
	public var index(get_index, set_index):Int;
	private function get_index():Int { return _anim != null ? _index : 0; }
	private function set_index(value:Int):Int
	{
		if (_anim == null) return 0;
		value %= _anim.frameCount;
		if (_index == value) return _index;
		_index = value;
		_frame = _anim.frames[_index];
		updateBuffer();
		return _index;
	}

	/**
	 * The amount of frames in the Spritemap.
	 */
	public var frameCount(get_frameCount, null):Int;
	private function get_frameCount():Int {
		return _frameCount;
	}
	//Moditfy
	public function getRegionOffset():Point {
		return new Point();
	}
	/**
	 * The currently playing animation.
	 */
	public var currentAnim(get_currentAnim, null):String;
	private function get_currentAnim():String { return (_anim != null) ? _anim.name : ""; }
	
	private var _rect:Rectangle;
	private var _frameCount:Int;
	private var _anims:StringMap<AnimationFix>;
	private var _anim:AnimationFix;
	private var _index:Int;
	private var _totalFrame:Int;
	private var _frame:Int;
	private var _timer:Float;
	private var _atlas:TextureAtlasFix;
	
	private var _imageWidth:Int;
	private var _imageHeight:Int;
	private var _offsetX:Float;
	private var _offsetY:Float;
}