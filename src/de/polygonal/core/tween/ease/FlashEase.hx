/*
Copyright (c) 2012-2014 Michael Baczynski, http://www.polygonal.de

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
package de.polygonal.core.tween.ease;

import de.polygonal.core.math.Interpolation;
import de.polygonal.core.math.Mathematics.M;

/**
	The "classic" flash easing with an easing value in the range [-100,100]
**/
class FlashEase implements Interpolation<Float>
{
	public var acceleration:Float;
	
	/**
		@param acceleration defines the easing value in the range [-100,100].
	**/
	public function new(acceleration:Float)
	{
		this.acceleration = M.fclampSym(acceleration, 100) / 100;
	}
	
	/**
		Computes the easing value using the given parameter `t` in the interval [0,1].
	**/
	public function interpolate(t:Float):Float
	{
		return
		if (acceleration == 0) t;
		else
		if (acceleration < 0)
			t * (t * -acceleration + 1 + acceleration);
		else
			t * ((2 - t) * acceleration + (1 - acceleration));
	}
}