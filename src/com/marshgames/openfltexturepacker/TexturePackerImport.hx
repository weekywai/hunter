// Copyright (c) 2014 Wayne Marsh

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

package com.marshgames.openfltexturepacker;

import haxe.xml.Fast;
import openfl.display.Tilesheet;

// User types
typedef TexturePackerFrame =
{
	name:String,
	frame:TexturePackerRectangle,
	rotated:Bool,
	trimmed:Bool,
	spriteSourceSize:TexturePackerRectangle,
	sourceSize:TexturePackerSize
}

typedef TexturePackerRectangle = 
{
	x:Int,
	y:Int,
	w:Int,
	h:Int
}

typedef TexturePackerSize = 
{
	w:Int,
	h:Int
}

// Importer
class TexturePackerImport
{
	public static function parseJson(jsonString:String):Array<TexturePackerFrame>
	{
		return parseJsonObject(haxe.Json.parse(jsonString));
	}

	public static function parseJsonObject(json:Dynamic):Array<TexturePackerFrame>
	{
		var structuredJson:SheetJson = json;

		var frames:Array<TexturePackerFrame> = [];

		// Read in frames
		for (key in Reflect.fields(structuredJson.frames)) 
		{
			var frameJson:TexturePackerFrame = Reflect.field(structuredJson.frames, key);
			frameJson.name = key;

			frames.push(frameJson);
		}

		return frames;
	}
	public static function parseXml(xml:String):Array<TexturePackerFrame>
	{
		return parseJsonObject(Xml.parse(xml));
	}

	public static function parseXmlObject(xml:Dynamic):Array<TexturePackerFrame>
	{
		var frames:Array<TexturePackerFrame> = [];
		var root:Xml = xml.firstElement();
		var size:TexturePackerSize = { w:Std.parseInt(root.get("width")), h:Std.parseInt(root.get("height")) };
		for (sprite in root.elements())
		{
			var spriteSourceSize:TexturePackerRectangle = { x:Std.parseInt(sprite.get("x")),
												y:Std.parseInt(sprite.get("y")), 
												w:Std.parseInt(sprite.get("w")),
												h:Std.parseInt(sprite.get("h")) };
			var frame:TexturePackerRectangle = { x:Std.parseInt(sprite.get("oX")),
												y:Std.parseInt(sprite.get("oY")), 
												w:Std.parseInt(sprite.get("oW")),
												h:Std.parseInt(sprite.get("oH")) };
			
			var frameJson:TexturePackerFrame = {name:sprite.get("n"),
												frame:frame,
												rotated:(sprite.exists("r") && sprite.get("r") == "y")?true:false,
												trimmed:false,
												spriteSourceSize:spriteSourceSize,
												sourceSize:size };
			frames.push(frameJson);
		}
		return frames;
	}

	public static function addToTilesheet(tilesheet:Tilesheet, frames:Array<TexturePackerFrame>):Map<String, Int>
	{
		var idMap:Map<String, Int> = new Map<String, Int>();

		for (i in 0...frames.length)
		{
			var frame = frames[i];
			
			var center = new flash.geom.Point(0, 0);

			if (frame.trimmed)
			{
				// Calculate adjusted center for trimmed sprite
				center.x -= frame.spriteSourceSize.x;
				center.y -= frame.spriteSourceSize.y;
			}

			var id = tilesheet.addTileRect(
				new flash.geom.Rectangle(
					frame.frame.x, frame.frame.y,
					frame.frame.w, frame.frame.h
				),
				center
			);

			idMap[frame.name] = id;
		}

		return idMap;
	}
}

// JSON parsing type
private typedef SheetJson =
{
	frames:Dynamic,
	meta:Dynamic
}