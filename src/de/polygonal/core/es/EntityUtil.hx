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
package de.polygonal.core.es;
import com.metal.GameProcess;
import com.metal.scene.board.impl.GameBoard;
import de.polygonal.core.sys.Component;
import de.polygonal.core.sys.SimEntity;
import openfl.errors.Error;

using de.polygonal.core.es.EntitySystem;

class EntityUtil
{
	public static function getDescendants(e:Entity):Iterator<Entity>
	{
		var i = 0;
		var s = e.getSize();
		var walker = e.preorder;
		return
		{
			hasNext: function()
			{
				return i < s;
			},
			next: function()
			{
				i++;
				var t = walker;
				walker = walker.preorder;
				return t;
			}
		}
	}
	
	public static function getChildren(e:Entity):Iterator<Entity>
	{
		var walker = e.firstChild;
		return
		{
			hasNext: function()
			{
				return walker != null;
			},
			next: function()
			{
				var t = walker;
				walker = walker.sibling;
				return t;
			}
		}
	}
	
	public static function getAncestors(e:Entity):Iterator<Entity>
	{
		var walker = e.parent;
		return
		{
			hasNext: function()
			{
				return walker != null;
			},
			next: function()
			{
				var t = walker;
				walker = walker.parent;
				return t;
			}
		}
	}
	
	public static function getSiblings(e:Entity):Iterator<Entity>
	{
		if (e.parent == null)
		{
			return
			{
				hasNext: function() return false,
				next: function() return null
			}
		}
		
		var walker = e.parent.firstChild;
		return
		{
			hasNext: function()
			{
				if (walker == e && walker.sibling == null) return false;
				return walker != null;
			},
			next: function()
			{
				var t = walker;
				if (t == e)
				{
					walker = walker.sibling;
					t = walker;
				}
				if (walker != null)
					walker = walker.sibling;
				return t;
			}
		}
	}
	
	public static function isDescendantOf(e:Entity, other:Entity):Bool
	{
		while (e != null)
		{
			if (e.parent == other) return true;
			e = e.parent;
		}
		
		return false;
	}
	public static function findComponent<T:Component>(name:String, c:Class<T>):T
	{
		var e = EntitySystem.findByName(name);
		if (e == null ) throw new Error("name entity is null");
		return untyped cast(e, SimEntity).getComponent(c);
	}
	/**
	 * 临时
	 * */
	public static function findBoardComponent<T:Component>(c:Class<T>):T
	{
		var e = GameProcess.root.findChild("GameBoard");
		if (e == null ) throw new Error("GameBoard entity is null");
		return untyped cast(e, SimEntity).getComponent(c);
	}
	
	public static function sendDirectMsg()
	{
		
	}
}