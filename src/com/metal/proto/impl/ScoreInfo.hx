package com.metal.proto.impl;
import com.metal.utils.XmlUtils;
import haxe.xml.Fast;

/**
 * 怪物类型分数
 * @author li
 */
class ScoreInfo
{
	//怪物分数类型
	public var ScoreType:Int;
	
	//分数
	public var Score:Int;

	public function new() 
	{
		
	}
	
	public function readXml(data:Fast):Void
	{
		ScoreType = XmlUtils.GetInt(data, "ScoreType");
		Score = XmlUtils.GetInt(data, "Score");
	}
	
}