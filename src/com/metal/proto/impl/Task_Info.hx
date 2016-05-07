package com.metal.proto.impl;

/**
 * ...
 * @author zxk
 */
class Task_Info
{

	/**id*/
	public var Id:Int;
	/**任务名称*/
	public var Name:String;
	/**任务类型*/
	public var taskType:String;

	public function new() 
	{
		
	}
	
	public function readXml(data:Dynamic):Void
	{
		Id = data.Id;
		Name = data.Name;
		taskType = data.taskType;
	}
}