/*
Copyright (c) 2014 Michael Baczynski, http://www.polygonal.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
package de.polygonal.core.math;

/**
	A point representing a location in (`x`,`y`) coordinate space.
**/
class Coord2i
{
	public var x:Int;
	public var y:Int;
	
	public function new(x:Int = 0, y:Int = 0)
	{
		set(x, y);
	}
	
	inline public function of(other:Coord2i)
	{
		x = other.x;
		y = other.y;
	}
	
	inline public function set(x:Int, y:Int):Coord2i
	{
		this.x = x;
		this.y = y;
		return this;
	}
	
	inline public function isZero():Bool
	{
		return x == 0 && y == 0;
	}
	
	inline public function makeZero()
	{
		x = y = 0;
	}
	
	inline public function equals(other:Coord2i):Bool
	{
		return other.x == x && other.y == y;
	}
	
	public function clone():Coord2i
	{
		return new Coord2i(x, y);
	}
	
	public function toString():String
	{
		return '{ Coord2i $x $y }';
	}
}