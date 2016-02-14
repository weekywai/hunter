package com.metal.unit;
import com.metal.proto.impl.AppearInfo;
import com.metal.proto.impl.MonsterAppearInfo;
import com.metal.proto.manager.MonsterAppeatManager;
import openfl.geom.Point;
import openfl.Lib;

/**
 * ...
 * @author hyg
 */
class AppearUtils
{
	//static private var h:Float = Lib.current.stage.stageHeight;
	//static private var w:Float = Lib.current.stage.stageWidth;

	public static function monsterApear(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		
		var monsterAppear:MonsterAppearInfo = MonsterAppeatManager.instance.getData(_appearInfo.Enter);
		//trace("=======" + _appearInfo.Enter);
		switch(_appearInfo.Enter)
		{
			case 111:
				return rightFall(_appearInfo);
			case 112:
				return leftFall(_appearInfo);
			case 113:
				return addFall(_appearInfo);
			case 114:
				return randomFall(_appearInfo);
			case 211:
				return rightAppear(_appearInfo);
			case 212:
				return leftAppear(_appearInfo);
			case 213:
				return addAppear(_appearInfo);
			case 214:
				return randomAppear(_appearInfo);
			case 311:
				return rightRight(_appearInfo);
			case 312:
				return leftRight(_appearInfo);
			case 313:
				return leftadd(_appearInfo);
			case 314:
				return randomRight(_appearInfo);
				
		}
		return null;
	}
	/**落 斜右*/
	private static function rightFall(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point = new Point() ;
			var bornPos:Point = new Point()  ;
			createPos.x = 0.3 + i*(1 / _appearInfo.enemies.length);
			createPos.y = 0.25 + i * (0.5 / _appearInfo.enemies.length);
			createArr.push(createPos);
			bornPos.x=0.3 + i*(1 / _appearInfo.enemies.length);
			bornPos.y = -0.25 + i * (0.5 / _appearInfo.enemies.length);
			bornPos.x=0.3 + i*(1 / _appearInfo.enemies.length);
			bornPos.y = -0.25 + i * (0.5 / _appearInfo.enemies.length);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	/**落 平行*/
	private static function addFall(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point = new Point()  ;
			createPos.x = 0.3 + i*(0.5 / _appearInfo.enemies.length);
			createPos.y = 0.3;// - i * (0.5 / _appearInfo.enemies.length);
			createArr.push(createPos);
			bornPos.x = 0.3 + i * (0.5 / _appearInfo.enemies.length);
			bornPos.y = 0.3;// - i * (0.5 / _appearInfo.enemies.length);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	/**落 斜左*/
	private static function leftFall(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point = new Point()  ;
			createPos.x = 0.3 + i*(1 / _appearInfo.enemies.length);
			createPos.y = 0.5 - i * (0.5 / _appearInfo.enemies.length);
			createArr.push(createPos);
			bornPos.x=0.3 + i*(1 / _appearInfo.enemies.length);
			bornPos.y = 0 - i * (0.5 / _appearInfo.enemies.length);
			bornArr.push(bornPos);
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	/**落 随机*/
	private static function randomFall(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point  = new Point() ;
			var bornPos:Point = new Point()  ;
			createPos.x = 0.3+i*(Math.random()*0.7);
			createPos.y = 0.1 + i * (Math.random()*0.5);
			createArr.push(createPos);
			bornPos.x = 0.3 + i * (Math.random() * 0.7);
			bornPos.y = 0 - i * (Math.random() * 0.5);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	/**左 斜右*/
	private static function rightAppear(_appearInfo:AppearInfo):Dynamic
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		//trace(_appearInfo.enemies);
		for (i in 0..._appearInfo.enemies.length+1) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point = new Point()  ;
			createPos.x = 0.1 + i*(0.45 / _appearInfo.enemies.length);
			createPos.y = 0.3 + i * (0.5 / _appearInfo.enemies.length);
			createArr.push(createPos);
			bornPos.x= -0.45 + i*(0.45 / _appearInfo.enemies.length);
			bornPos.y = 0.3 + i * (0.5 / _appearInfo.enemies.length);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		//trace(poinArr);
		
		return poinArr;
	}
	/**左 平行*/
	private static function addAppear(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point = new Point()  ;
			createPos.x = 0.45 - i*(0.45 / _appearInfo.enemies.length);
			createPos.y = 0.3;// + i * (0.5 / _appearInfo.enemies.length);
			createArr.push(createPos);
			bornPos.x= 0 - i*(1 / _appearInfo.enemies.length);
			bornPos.y = 0.3;// + i * (0.5 / _appearInfo.enemies.length);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	/**左 斜左*/
	private static function leftAppear(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point = new Point()  ;
			createPos.x = 0.45 - i*(0.45 / _appearInfo.enemies.length);
			createPos.y = 0.1 + i * (0.5 / _appearInfo.enemies.length);
			createArr.push(createPos);
			bornPos.x= 0 - i*(0.45 / _appearInfo.enemies.length);
			bornPos.y = 0.1 + i * (0.5 / _appearInfo.enemies.length);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	/**左 随机*/
	private static function randomAppear(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point  = new Point() ;
			createPos.x = 0.45-i*(Math.random()*0.45);
			createPos.y = 0.1 + i * (Math.random()*0.5);
			createArr.push(createPos);
			bornPos.x = 0 - i * (Math.random() * 0.45);
			bornPos.y = 0 - i * (Math.random() * 0.5);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	/**右 斜右*/
	private static function rightRight(_appearInfo:AppearInfo):Dynamic
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		//trace(_appearInfo.enemies);
		for (i in 0..._appearInfo.enemies.length+1) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point = new Point()  ;
			createPos.x = 0.55 + i*(0.45 / _appearInfo.enemies.length);
			createPos.y = 0.3 + i * (0.5 / _appearInfo.enemies.length);
			createArr.push(createPos);
			bornPos.x=-1.1 + i*(0.45 / _appearInfo.enemies.length);
			bornPos.y = 0.3 + i * (0.5 / _appearInfo.enemies.length);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		//trace(poinArr);
		
		return poinArr;
	}
	/**右 斜左*/
	private static function leftRight(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point = new Point()  ;
			createPos.x = 0.85 - i*(0.45 / _appearInfo.enemies.length);
			createPos.y = 0.1 + i * (0.5 / _appearInfo.enemies.length);
			createArr.push(createPos);
			bornPos.x= 1.55 - i*(0.45 / _appearInfo.enemies.length);
			bornPos.y = 0.1 + i * (0.5 / _appearInfo.enemies.length);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	/**右 平行*/
	private static function leftadd(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point  = new Point() ;
			createPos.x = 0.55+ i*(0.45 / _appearInfo.enemies.length);
			createPos.y = 0.3; //+ i * (Math.random()*0.5);
			createArr.push(createPos);
			bornPos.x = 1 + i*(0.45 / _appearInfo.enemies.length);
			bornPos.y = 0.3; //+ i * (Math.random() * 0.5);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	/**右 随机*/
	private static function randomRight(_appearInfo:AppearInfo):Dynamic//Array<Array<Point>>
	{
		var poinArr:Array<Array<Point>> = [];
		var createArr:Array<Point> = [];
		var bornArr:Array<Point> = [];
		for (i in 0..._appearInfo.enemies.length) 
		{
			var createPos:Point = new Point()  ;
			var bornPos:Point  = new Point() ;
			createPos.x = 0.55+i*(Math.random()*0.45);
			createPos.y = 0.1 + i * (Math.random()*0.5);
			createArr.push(createPos);
			bornPos.x = 1 + i * (Math.random() * 0.45);
			bornPos.y = 0.1 + i * (Math.random() * 0.5);
			bornArr.push(bornPos);
			
		}
		poinArr.push(createArr);
		poinArr.push(bornArr);
		
		
		return poinArr;
	}
	
}