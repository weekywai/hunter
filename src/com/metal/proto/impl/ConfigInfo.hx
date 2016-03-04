package com.metal.proto.impl;
import com.utils.XmlUtils;
import de.polygonal.ds.XmlConvert;
import haxe.ds.StringMap;
import haxe.xml.Fast;

/**
 * ...
 * @author weeky
 */
class ConfigInfo
{
	public static function readXml(data:String):StringMap<Dynamic>
	{
		var info:StringMap<Dynamic> = new StringMap();
		var xml = XmlConvert.toTreeNode(data);
		var node = xml.children;
		while (node != null) {
			//switch(node.val.name) {
				//case "host":
					//info.set(node.val.name, XmlUtils.GetString(node.val.value));
				//case "port":
					//info.set(node.val.name, XmlUtils.GetString(node.val.value));
				//case "console":
					//info.set(node.val.name, XmlUtils.GetBool(node.val.value));
				//case "crashLog":
					//info.set(node.val.name, XmlUtils.GetBool(node.val.value));
			//}
			info.set(node.val.name, node.val.value);
			node = node.next;
		}
		xml.free();
		return info;
	}
}