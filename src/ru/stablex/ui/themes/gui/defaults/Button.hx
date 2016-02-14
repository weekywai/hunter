package ru.stablex.ui.themes.gui.defaults ;

import com.metal.config.SfxManager;
import openfl.filters.DropShadowFilter;
import openfl.filters.GlowFilter;
import ru.stablex.ui.skins.Img;
import ru.stablex.ui.skins.Paint;
import ru.stablex.ui.themes.gui.Main;
import ru.stablex.ui.widgets.Button in WButton;
import ru.stablex.ui.widgets.Widget;


/**
* Defaults for Button widget
*
*/
class Button {
    /**
    * Function for applying default section to widget including custom user
    * settings from xml file passed to UIBuilder.init(defaults.xml)
    */
    static private var _defaultFn : Widget->Void = null;


    /**
    * Apply default section to widget
    *
    */
    static private inline function _applyDefault (btn:WButton) : Void {
        if( _defaultFn == null ){
            _defaultFn = UIBuilder.defaults.get('Button').get('Default');
        }
        _defaultFn(btn);
    }//function _applyDefault()


    /**
    * Default section
    *
    */
    static public function Default (w:Widget) : Void {
        var btn = cast(w, WButton);
        btn.w = 185;
        btn.h = 40;
        btn.label.embedFonts = true;
        btn.format.size = 14;
        btn.format.color = 0xFFFFFF;
        btn.format.font = Main.FONT;
        btn.skinName = 'button';
        btn.skinHoveredName = 'buttonHovered';
        btn.skinPressedName = 'buttonPressed';
    }//function Default()

	static public function None (w:Widget) : Void {
        var btn = cast(w, WButton);
		var p = new Paint();
		p.color = 0;
		p.alpha = 0;
        btn.skin = p;
        btn.w = 100;
        btn.h = 40;
        btn.format.size = 28;
		btn.format.color = 0x81faf5;
		btn.format.bold = false;
		btn.format.font = Main.FONT;
		btn.label.filters = [new openfl.filters.DropShadowFilter(0, 45, 0x000000, 0.7, 5, 5, 6)];
		
    }//function Default()

    /**
    * Settings button
    *
    */
    static public function Settings (w:Widget) : Void {
        var btn = cast(w, WButton);
        _applyDefault(btn);
        btn.ico.bitmapData = Main.getBitmapData('img/ico/dark/settings.png');
        btn.autoWidth      = true;
        btn.childPadding   = 0;
        btn.icoBeforeLabel = false;
        btn.apart          = true;
    }//function Settings()


    /**
    * Items in menu list
    */
    static public function MenuItem (w:Widget) : Void {
        var btn = cast(w, WButton);
        btn.align            = 'middle';
        btn.h                = 44;
        btn.widthPt          = 100;
        btn.padding          = 5;
        btn.label.embedFonts = true;
        btn.format.font      = Main.FONT;
        btn.format.size      = 16;
        btn.format.color     = 0xFFFFFF;
        btn.apart            = true;
        btn.ico.bitmapData   = Main.getBitmapData('img/ico/light/next.png');
        btn.icoBeforeLabel   = false;
        btn.skinName         = 'Black1';
        btn.skinPressedName  = 'pressed';
    }//function MenuItem()
	
	static public function HightLight (w:Widget) : Void {
        var btn = cast(w, WButton);
		btn.onHover = function(e) {
			btn.filters = [new GlowFilter(0xFFFFFF, 0.6, 40, 40, 1, 1, true)];
		}
		btn.onPress = function(e) {
			btn.filters = [new GlowFilter(0xFFFFFF, 0.6, 40, 40, 1, 1, true)];
		}
		btn.onRelease = btn.onHout = function(e) {
			btn.filters = [];
		}
    }//function MenuItem()
	
	
	static public function TurnPage(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'storeBtn1';
	}
	static public function Plus(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn1';
	}
	static public function Treasure(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName =btn.skinHoveredName = btn.skinPressedName = 'mainBtn2';
	}
	static public function Recharge(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn3';
	}
	static public function Givebtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'storeBtn2';
		//MenuItem(btn);
		btn.format.size = 28;
		btn.format.color = 0xb8ffff;
		btn.format.bold = false;
		btn.format.font = Main.FONT;
	}
	/*Login */
	static public function login(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'loginBtn1';
	}
	/*closeBtn */
	static public function closeBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'loginBtn3';
	}
	/*suerBtn */
	static public function submitBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'loginBtn4';
		btn.format.size = 32;
		btn.format.color = 0x81faf5;
		btn.format.bold = true;
		btn.format.font = Main.FONT;
		//label-selectable="false"
		btn.format.bold = true;
		btn.label.filters = [new DropShadowFilter(0, 45, 0x000000, 0.7, 5, 5, 6)];
		//btn.label.filters = [new GlowFilter(0x000000, 1, 6, 6, 2)];
	}
	/*createName*/
	static public function createNameBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'loginBtn5';
	}
	/*mainBackBtn*/
	static public function mainBackBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn4';
		btn.format.size = 16;
		btn.format.color = 0xffffff;
		btn.format.bold = true;
		btn.format.font = Main.FONT;
	}
	static public function icoPosition(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.ico.scaleX = -1;
		
		//trace(btn.width+'====================' + btn.ico.width + ":");
		btn.icoHovered = btn.icoPressed = btn.ico;
		btn.ico.leftPt = 40;
		btn.icoHovered.leftPt = 40;
		btn.icoPressed.leftPt = 40;
		//btn.icoHovered.x = btn.icoPressed.x = btn.ico.x;
	}
	/**/
	static public function mainLeftUpBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = 'mainBtn6';
		btn.skinPressedName = btn.skinDisabledName = 'mainBtn8';
		btn.onPress = function(e) {
			btn.skinName = btn.skinPressedName = btn.skinDisabledName = 'mainBtn8';
		}
	}
	/**/
	static public function mainLeftDrowBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn7';
	}
	/**/
	static public function mainFunBtn_1(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn9';
	}
	/**/
	static public function mainFunBtn_2(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn10';
	}
	/**/
	static public function mainFunBtn_3(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn11';
	}/**/
	static public function mainRDBtn_1(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn12';
	}/**/
	static public function mainRDBtn_2(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn13';
	}/**/
	static public function mainRDBtn_3(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainBtn14';
	}
	/**/
	static public function hunBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.label.embedFonts = true;
        btn.format.size = 22;
		btn.format.color = 0xF0B505;
		//btn.format.font = "黑体" ;
		btn.format.bold = false;
        btn.format.font = Main.FONT;
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'hunBtn1';
	}
	/**/
	static public function choiceEquipBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'storeImg2';
	}
	/**/
	static public function forgeBlueBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'forgeBtn2';
	}
	/**/
	static public function forgeGreenBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'forgeBtn1';
	}
	/*throughBtn1*/
	static public function throughBtn1(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'throughImg1';
		btn.format.size = 28;
		btn.format.color = 0xb8ffff;
		btn.format.bold = true;
		btn.format.font = Main.FONT;
	}
	/*throughBtn2*/
	static public function throughBtn2(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'throughImg2';
		btn.format.size = 28;
		btn.format.color = 0xb8ffff;
		btn.format.bold = true;
		btn.format.font = Main.FONT;
	}
	/*strengthenBtn*/
	static public function strengtheBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'forgeBtn3';
	}
	/**技能购买*/
	static public function skillBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillImg10';
	}
	/*selectBoxBtn*/
	static public function selectBoxBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'forgeImg15';
		btn.format.size = 28;
		btn.format.color = 0xb8ffff;
		btn.format.bold = true;
		btn.format.font = Main.FONT;
	}
	/*MainView equip two btn*/
	static public function mainEquipBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'forgeImg12';
	}
	/*settlementSuerBtn*/
	static public function settlementSubmitBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'alertBtn1';
	}
	/*greenSuerBtn*/
	static public function greenSubmitBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'alertBtn2';
		btn.format.size = 46;
		btn.format.color = 0xffffff;
		btn.format.bold = true;
		btn.format.font = Main.FONT;
	}
	/*controller left and right Btn*/
	static public function controllerLFBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'controllerBtn1';
	}
	static public function middleBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'controllerBtn2';
	}
	static public function jumpBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'controllerBtn3';
	}
	
	/*jinengBtn1 author:caiqingming*/
	static public function jinengBtn1(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillBtn5';
		btn.skinDisabledName = 'skillGBtn5';
		skillFormat(btn);
	}
	/*jinengBtn2*/
	static public function jinengBtn2(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillBtn4';
		btn.skinDisabledName = 'skillGBtn4';
		skillFormat(btn);
	}
	/*jinengBtn3*/
	static public function jinengBtn3(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillBtn3';
		btn.skinDisabledName = 'skillGBtn3';
		skillFormat(btn);
	}
	/*jinengBtn4*/
	static public function jinengBtn4(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillBtn2';
		btn.skinDisabledName = 'skillGBtn2';
		skillFormat(btn);
	}
	/*jinengBtn5*/
	static public function jinengBtn5(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillBtn1';
		btn.skinDisabledName = 'skillGBtn1';
		skillFormat(btn);
	}
	
	/*jinengBtn6左侧技能1*/
	static public function jinengBtn6(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'fightImg19';
		btn.skinDisabledName = 'fightImg19';
		skillFormat(btn);
	}
	
	/*jinengBtn7砍刀*/
	static public function jinengBtn7(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'fightImg18';
		btn.skinDisabledName = 'fightImg18';
		skillFormat(btn);
	}
	
	static function skillFormat(btn:WButton)
	{
		btn.format.size = 32;
		btn.format.color = 0x81faf5;
		btn.format.bold = false;
		btn.format.font = Main.FONT;
		btn.label.filters = [new openfl.filters.DropShadowFilter(0, 45, 0x000000, 0.7, 5, 5, 6)];
	}
	/**炸弹*/
	static public function skill1(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillImg4';
	}
	/**闪电*/
	static public function skill2(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillImg5';
	}
	/**超级火力*/
	static public function skill3(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillImg6';
	}
	/**无敌*/
	static public function skill4(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillImg7';
	}
	/**治愈*/
	static public function skill5(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'skillImg8';
	}
	/*方向按钮*/
	static public function directionBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'fightImg7';
	}
	/*tiaoyueBtn*/
	static public function tiaoyueBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'fightImg11';
	}
	/*attackBtn*/
	static public function attackBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'fightImg13';
	}
	/*ectypeBtn*/
	static public function ectypeBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'ectypeImg1';
		
	}
	/*rewardBtn*/
	static public function rewardBtn1(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'rewardImg3';
		
	}
	static public function rewardBtn2(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'rewardImg2';
		
	}
	/**Left latestFashion*/
	static public function leftLatestFashionBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainImg29';
		btn.format.size = 46;
		btn.format.color = 0x7AECEF;
		btn.format.bold = true;
		btn.format.font = Main.FONT;
		
	}
	/**Right latestFashion*/
	static public function rightLatestFashionBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'mainImg29';
		btn.format.size = 46;
		btn.format.color = 0xFFB300;
		btn.format.bold = true;
		btn.format.font = Main.FONT;
		
	}
	/**stop game*/
	static public function stopGame(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'fightImg15';
		
	}
	static public function tiaoguoBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'noviceImg4';
		
	}
	static public function shouziBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'noviceImg3';
		
	}
	static public function zhuangbeiBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'noviceImg8';
		
	}
	static public function payBtn(w:Widget):Void
	{
		var btn = cast(w, WButton);
		btn.skinName = btn.skinHoveredName = btn.skinPressedName = 'noviceImg9';
		
	}
}//class Button