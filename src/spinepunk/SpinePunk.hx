package spinepunk;

import com.haxepunk.Graphic;
import com.haxepunk.graphics.atlas.AtlasData;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.Mask;
import com.haxepunk.masks.Hitbox;
import com.haxepunk.masks.Imagemask;
import com.haxepunk.masks.Polygon;
import com.haxepunk.RenderMode;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import spinehaxe.animation.AnimationState;
import spinehaxe.animation.AnimationStateData;
import spinehaxe.atlas.TextureAtlas;
import spinehaxe.attachments.Attachment;
import spinehaxe.attachments.BoundingBoxAttachment;
import spinehaxe.attachments.RegionAttachment;
import spinehaxe.Bone;
import spinehaxe.platform.nme.BitmapDataTexture;
import spinehaxe.platform.nme.BitmapDataTextureLoader;
import spinehaxe.Skeleton;
import spinehaxe.SkeletonData;
import spinehaxe.SkeletonJson;
import spinehaxe.SkeletonJson;
import spinehaxe.Slot;

using Lambda;


class SpinePunk extends Graphic {
	static var atlasMap:StringMap<TextureAtlas> = new StringMap();
	static var skeletonMap:StringMap<SkeletonData> = new StringMap();
	
	public static function clear()
	{
		for (key in atlasMap.keys()) 
		{
			atlasMap.get(key).dispose();
		}
		atlasMap = new StringMap();
		for (key in skeletonMap.keys()) 
		{
			skeletonMap.get(key).dispose();
		}
		skeletonMap = new StringMap();
	}
    static var p:Point = new Point();
    static var c:Point = new Point();
	/**使用mask碰撞检测*/
    public var useMask:Bool = true;
	/**设置武器碰撞*/
	public var weaponHitslot:String = "";
	
    public var hitboxSlots:Array<String>;
    public var hitSlots:Array<String>;
    public var hitboxes:Map<String, Rectangle>;
	
	public var weaponBox:Rectangle;
	public var mask:Mask;
    
    public var skeleton:Skeleton;
    public var skeletonData:SkeletonData;
    public var state:AnimationState;
    public var stateData:AnimationStateData;
    public var angle:Float=0;
    public var speed:Float=1;
    public var color:Int=-1;
    public var dynamicHitbox:Bool=true;
    public var mainHitbox:Rectangle;
    public var scaleX:Float=1;
    public var scaleY:Float=1;
	
    public var smooth = false;
    
    public var name:String;
    var rect1:Rectangle;
    var rect2:Rectangle;
    var firstFrame = true;
	private var _scale:Float = 1;
    
    var wrapperAngles:ObjectMap<RegionAttachment, Float>;
    var cachedImages:ObjectMap<RegionAttachment, Image>;
    
    public function new(skeletonData:SkeletonData,  smooth=true) {
        super();
		this.smooth = smooth;
		name = skeletonData.name;
        init(skeletonData);
    }
	public function init(data:SkeletonData):Void 
	{
		skeletonData = data;
        
        stateData = new AnimationStateData(skeletonData);
        state = new AnimationState(stateData);
        
        skeleton = new Skeleton(skeletonData);
        skeleton.x = 0;
        skeleton.y = 0;
        skeleton.flipY = true;
        
        cachedImages = new ObjectMap();
        wrapperAngles = new ObjectMap();
        hitboxSlots = new Array();
        hitSlots = ["diying", "hair", "gun_1","yiling_R","R Foot","pp"];
        hitboxes = new Map();
        
        rect1 = new Rectangle();
        rect2 = new Rectangle();
        mainHitbox = rect1;
        
        
        blit = HXP.renderMode != RenderMode.HARDWARE;
		if(useMask){
			skeleton.updateWorldTransform();
			setMaskBox();
		}
	}
    
    public function resetHitbox() {
        mainHitbox.width = mainHitbox.height = 0;
        firstFrame = true;
    }
	
    public var skin(default, set):String;
    function set_skin(skin:String) {
        if (skin != this.skin) {
            skeleton.skinName = skin;
            skeleton.setToSetupPose();
        }
        return this.skin = skin;
    }
    
    public var flipX(get, set):Bool;
    private function get_flipX():Bool {  return skeleton.flipX; }
    private function set_flipX(value:Bool):Bool {
        if (value != skeleton.flipX) {
            skeleton.flipX = value;
            skeleton.updateWorldTransform();
			if(useMask) setMaskBox();
        }
        return value;
    }
    
    public var flipY(get, set):Bool;
    private function get_flipY():Bool { return skeleton.flipY; }
    private function set_flipY(value:Bool):Bool {
        if (value != skeleton.flipY) {
            skeleton.flipY = value;
            skeleton.updateWorldTransform();
			if(useMask) setMaskBox();
        }
        return value;
    }
	
	
	public var scale(get, set):Float;
	private function get_scale():Float { return _scale; }
	private function set_scale(value:Float):Float 
	{
		_scale = value;
		skeleton.updateWorldTransform();
		if(useMask) setMaskBox();
		return value;
	}
    
    /**
     * Get Spine animation data.
     * @param    DataName    The name of the animation data files exported from Spine (.atlas .json .png).
     * @param    DataPath    The directory these files are located at
     * @param    Scale        Animation scale
     */
    public static function readSkeletonData(dataName:String, dataPath:String, scale:Float = 1, skinId:Int = 0, flip:Bool = false):SkeletonData {
        if (dataPath.lastIndexOf("/") < 0) dataPath += "/"; // append / at the end of the folder path
		//trace(dataPath);
		if (!atlasMap.exists(dataPath))
			atlasMap.set(dataPath, TextureAtlas.create(Assets.getText(dataPath + dataName + ".atlas"), dataPath, new BitmapDataTextureLoader(), flip));
        var spineAtlas:TextureAtlas = atlasMap.get(dataPath);
        //var spineAtlas:TextureAtlas = TextureAtlas.create(Assets.getText(dataPath + dataName + ".atlas"), dataPath, new BitmapDataTextureLoader(), flip);
		
        var json:SkeletonJson = SkeletonJson.create(spineAtlas);
        json.scale = scale;
		if (!skeletonMap.exists(dataPath)) {
			var s = json.readSkeletonData(Assets.getText(dataPath + dataName + ".json"), dataPath);
			skeletonMap.set(dataPath, s);
		}
        var skeletonData:SkeletonData = skeletonMap.get(dataPath).clone();
        //var skeletonData:SkeletonData = json.readSkeletonData(Assets.getText(dataPath + dataName + ".json"), dataPath);
		//需要设置初始皮肤
		var skin;
		if(skeletonData.skins.length>1){
			skin = skeletonData.findSkin("clips" + skinId);
		} else {
			skin = skeletonData.skins[skinId];
		}
		//第一次加载没有设置皮肤不能直接使用 skin.name
		skeletonData.defaultSkin = skin;
        return skeletonData;
    }
    
    public override function update():Void {
        state.update(HXP.elapsed*speed);
        state.apply(skeleton);
        skeleton.updateWorldTransform();
        super.update();
    }
    
    public override function renderAtlas(layer:Int, point:Point, camera:Point):Void {
        draw(point, camera, layer);
    }

    public override function render(target:BitmapData, point:Point, camera:Point):Void {
        draw(point, camera, 0, target);
    }
    
    function draw(point:Point, camera:Point, layer:Int=0, target:BitmapData=null):Void {
        p.x = point.x; p.y = point.y;
        var point = p;
        c.x = camera.x; c.y = camera.y;
        var camera = c;
        var drawOrder:Array<Slot> = skeleton.drawOrder;
        var flipX:Int = (skeleton.flipX) ? -1 : 1;
        var flipY:Int = (skeleton.flipY) ? 1 : -1;
        var flip:Int = flipX * flipY;
        
        var _aabb:Rectangle = null;
        
        var radians:Float = angle * HXP.RAD;
        var cos:Float = Math.cos(radians);
        var sin:Float = Math.sin(radians);
        
        var sx = scaleX * scale;
        var sy = scaleY * scale;
        
        var attachment:Attachment;
        var regionAttachment:RegionAttachment;
        var wrapper:Image;
        var wrapperAngle:Float;
        var region:AtlasRegion;
        var bone:Bone;
        var dx:Float, dy:Float;
        var relX:Float, relY:Float;
        var rx:Float, ry:Float;
		var box = new Rectangle();
		var slot:Slot;
        for (slot in drawOrder)  {
            attachment = slot.attachment;
			
            if (Std.is(attachment, RegionAttachment)) {
                regionAttachment = cast attachment;
                //regionAttachment.updateVertices(slot);
                wrapper = getImage(regionAttachment);
                wrapper.color = (color!=-1)?color:colorInt(slot);
                wrapperAngle = wrapperAngles.get(regionAttachment);
                wrapper.alpha = slot.a;
                region = cast regionAttachment.region;
                bone = slot.bone;
                rx = regionAttachment.x;
                ry = regionAttachment.y;
                dx = bone.worldX + rx * bone.m00 + ry * bone.m01;
                dy = bone.worldY + rx * bone.m10 + ry * bone.m11;
                
                relX = (dx * cos * sx - dy * sin * sy);
                relY = (dx * sin * sx + dy * cos * sy);
                wrapper.x = (x + relX);
                wrapper.y = (y + relY);
                wrapper.angle = (((bone.worldRotation + regionAttachment.rotation) + wrapperAngle) * flip + angle);
                wrapper.scaleX = (bone.worldScaleX + regionAttachment.scaleX - 1) * flipX * sx;
                wrapper.scaleY = (bone.worldScaleY + regionAttachment.scaleY - 1) * flipY * sy;
				//trace(layer + " " + point + " " + camera);
                if (blit) wrapper.render(target, point, camera);
                else wrapper.renderAtlas(layer, point, camera);
				//判断近身武器矩阵
				if (weaponHitslot != "") {
					if (slot.data.name == weaponHitslot) {
						if (weaponBox == null)	
							weaponBox = new Rectangle();
						weaponBox.x = wrapper.x - (region.rotate ? wrapper.originY : wrapper.originX) * sx;
						weaponBox.y = wrapper.y - (region.rotate ? wrapper.originX : wrapper.originY) * sy;
						weaponBox.width = (region.rotate ? wrapper.height : wrapper.width) * sx;
						weaponBox.height = (region.rotate ? wrapper.width : wrapper.height) * sy;
						//trace(weaponBox);
					}
				}
				
				if (mask!=null)
					continue;
				//判断非碰撞骨骼
				if (hitSlots.indexOf(slot.data.name)!=-1) {
					continue;
				}
				if (!hitboxes.exists(slot.data.name))
					hitboxes[slot.data.name] = new Rectangle();
                var wRect:Rectangle =  hitboxes.get(slot.data.name);
                wRect.x = wrapper.x-(region.rotate ? wrapper.originY : wrapper.originX)*sx;
                wRect.y = wrapper.y-(region.rotate ? wrapper.originX : wrapper.originY)*sy;
                wRect.width = (region.rotate ? wrapper.height : wrapper.width)*sx;
                wRect.height = (region.rotate ? wrapper.width : wrapper.height) * sy;
				box = box.union(wRect);
                if (hitboxSlots.has(slot.data.name)) {
                    if (_aabb == null) {
                        _aabb = (mainHitbox == rect2 ? rect1 : rect2);
                        _aabb.x = wRect.x;
                        _aabb.y = wRect.y;
                        _aabb.width = wRect.width;
                        _aabb.height = wRect.height;
                    } else {
                        var x0 = _aabb.x > wRect.x ? wRect.x : _aabb.x;
                        var x1 = _aabb.right < wRect.right ? wRect.right : _aabb.right;
                        var y0 = _aabb.y > wRect.y ? wRect.y : _aabb.y;
                        var y1 = _aabb.bottom < wRect.bottom ? wRect.bottom : _aabb.bottom;
                        _aabb.left = x0;
                        _aabb.top = y0;
                        _aabb.width = x1 - x0;
                        _aabb.height = y1 - y0;
                    }
                }
				
            }
        }
		if (mask!=null)
			return;
		_aabb = box;
        if (_aabb != null && ( firstFrame)) {
            _aabb.x -= x;
            _aabb.y -= y;
            mainHitbox = _aabb;
            firstFrame = false;
        }
		
		
    }
    
	private function colorInt(slot:Slot):Int 
	{
		return ((Std.int(255 * slot.b) << 16) | (Std.int(255 * slot.g) << 8) | (Std.int(255 * slot.r)));
	}
	
	public function setMaskBox():Void 
	{
		var index = skeletonData.findSlotIndex("bound");
		var bound:BoundingBoxAttachment = cast skeletonData.findSkin("default").getAttachment(index, "bounds");
		if (bound == null)
			bound = cast skeletonData.findSkin("default").getAttachment(index, "bound");
		if (bound == null) return;
		var list:Array<Float> = [];
		var radians:Float = angle * HXP.RAD;
		var cos:Float = Math.cos(radians);
        var sin:Float = Math.sin(radians);
        
        var sx = scaleX * scale;
        var sy = scaleY * scale;
		var bone = skeleton.rootBone;
		var i:Int = 0;
		var n:Int = bound.vertices.length;
		var minX:Float, minY:Float, maxX:Float, maxY:Float;
		while(i < n) {
			var ii:Int = i + 1;
			var px:Float = bound.vertices[i];
			var py:Float = bound.vertices[ii];
			var dx = px * bone.m00 * sx * cos + py * bone.m01 * sy * sin;
			var dy = px * bone.m10 * sx * sin + py * bone.m11 * sy * cos;
			list[i] = dx + x;
			list[ii] = dy + y;
			
			i += 2;
		}
		
		if (mask != null)
			cast(mask, Polygon).points = bound.getVertices(list);
		else
			mask = new Polygon(bound.getVertices(list));
			
		//使用mask碰撞检测可删除下面
		var poly = cast(mask, Polygon);
		//mask = new Hitbox(Std.int(poly.width * 0.5), Std.int(poly.height * 0.95), Std.int( -poly.width * 0.5 * 0.5), Std.int( -poly.height * 0.95));
		mask.update();
		var hw = poly.width * 0.7;
		var hh = poly.height * 0.95;
		mainHitbox = new Rectangle(Std.int( -hw * 0.5), -hh, Std.int(hw), Std.int(hh));
		//mask = null;
	}

    public function getImage(regionAttachment:RegionAttachment):Image {
		
        if (cachedImages.exists(regionAttachment))
            return cachedImages.get(regionAttachment);
        
        var region:AtlasRegion = cast regionAttachment.region;
        var texture:BitmapDataTexture = cast region.texture;
		var atlasData = AtlasData.getAtlasDataByName(name);
        if (atlasData == null) {
            var cachedGraphic:BitmapData = texture.bd;
            atlasData = new AtlasData(cachedGraphic, name);
        }
        
        var rect = HXP.rect;
        rect.x = region.regionX;
        rect.y = region.regionY;
        rect.width = region.regionWidth;
        rect.height = region.regionHeight;
        var wrapper:Image;
        
        if (blit) {
            var bd = new BitmapData(cast rect.width, cast rect.height, true, 0);
            HXP.point.x = HXP.point.y = 0;
            bd.copyPixels(texture.bd, rect, HXP.point);
            wrapper = new Image(bd);
        } else {
            wrapper = new Image(atlasData.createRegion(rect));
        }
        
        wrapper.smooth = smooth;
        
        wrapper.originX = (region.regionWidth / 2);
        wrapper.originY = (region.regionHeight / 2);
        if (region.rotate) {
            wrapper.angle = -90;
        }
        
        cachedImages.set(regionAttachment, wrapper);
        wrapperAngles.set(regionAttachment, wrapper.angle);
        
        return wrapper;
    }
}
