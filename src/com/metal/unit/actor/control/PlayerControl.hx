package com.metal.unit.actor.control;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.metal.config.PlayerPropType;
import com.metal.message.MsgActor;
import com.metal.message.MsgInput;
import com.metal.message.MsgPlayer;
import com.metal.player.utils.PlayerUtils;
import com.metal.unit.actor.api.ActorState;
import com.metal.unit.actor.impl.MTActor;
import com.metal.unit.weapon.impl.WeaponFactory.WeaponType;
import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Component;
import openfl.geom.Point;

using com.metal.enums.Direction;
/**
 * 玩家操作控制器
 * 生命周期:单元核
 * @author weeky
 */
class PlayerControl extends Component
{
	
	private var _actor:MTActor;
	
	private var _controlType:Int = 1;
	private var _reg:Bool;
	private var _inputEnable:Bool = false;
	private var _inputFlag:Dynamic = NONE;
	
	public function new() {
		super();
		_reg = false;
	}
	
	override function onInitComponent():Void 
	{
		super.onInitComponent();
		_actor = owner.getComponent(MTActor);
		//_stat = myBody.getComponent(IStat);
		reg();
	}
	private function reg():Void{
		Input.define("right", [Key.D]);
		Input.define("down", [Key.S]);
		Input.define("left", [Key.A]);
		
		Input.define("jump", [Key.SPACE]);
		Input.define("skill", [Key.S]);
		Input.define("attack", [Key.L]);
		_reg = true;
	}
	
	override function onDispose():Void 
	{
		_actor = null;
		_reg = false;
		super.onDispose();
	}
	
	override public function onTick(timeDelta:Float) 
	{
		if (!_reg) return;
		onKey();
		super.onTick(timeDelta);
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void 
	{
		switch(type) {
			case MsgInput.UIJoystickInput:
				_inputFlag = userData;
			case MsgInput.UIInput:
				cmd_UIInput(userData);
			case MsgInput.DirAttack:
				cmd_DirAttack(userData);
			//case MsgInput.Aim:
				//cmd_Aim(userData);
			case MsgActor.Destroying, MsgActor.Destroy, MsgActor.Victory:
				cmd_Destroy(userData);
			case MsgInput.SetInputEnable:
				cmd_SetInputEnable(userData);
			case MsgActor.Respawn:
				cmd_Respawn(userData);
		}
	}
	
	private function onKey():Void
	{
		if (!_inputEnable) return;
		
		if (Input.check("left") || _inputFlag==LEFT)
		{
			Input_Move(LEFT);
		}
		if (Input.check("right") || _inputFlag==RIGHT)
		{
			Input_Move(RIGHT);
		}
		return;
		if (!Input.check("right") && !Input.check("left")&& !Input.check("jump") && _inputFlag==NONE)
		{
			Stand();
		}
		// JUMP
		if (Input.check("jump"))
			Input_Jump(null);
		if(Input.check("skill"))
			Input_Skill(null);
		//if(Input.pressed("attack")){
			//notify(MsgInput.HoldFire, true);
		//}else {
			//notify(MsgInput.HoldFire, false);
		//}
	}
	
	private function cmd_SetInputEnable(userData:Dynamic):Void
	{
		_inputEnable = userData;
		if (!_inputEnable) Stand();
	}
	
	private function cmd_UIJoystickInput(userData:Dynamic):Void
	{
		if (!_actor.isInBoard() || !_inputEnable) return;
		//广播到角色核
		//notify(cast userData, SimEventPolicy.UploadOnly);
		//if (userData == NONE)
			//Stand();
		//else
			//Input_Move(userData);
		switch(userData) {
			case NONE:
				Stand();
			case LEFT,RIGHT:
				Input_Move(userData);
		}
	}
	private function cmd_UIInput(userData:Dynamic):Void
	{
		if (!_actor.isInBoard()  || !_inputEnable) return;
		//广播到角色核
		//notify(cast userData, SimEventPolicy.UploadOnly);
		switch(userData.type) {
			case ActorState.Jump:
				Input_Jump(null);
			case ActorState.Melee:
				Input_Melee(null);
			case ActorState.Skill:
				Input_Skill(userData.data);
			case ActorState.Attack:
				Input_Attack(true);
			case ActorState.None:
				Input_Attack(false);
		}
	}
	
	private function cmd_Destroy(userData:Dynamic):Void
	{
		_reg = false;
		_inputEnable = false;
	}
	
	private function cmd_Respawn(userData:Dynamic):Void
	{
		_reg = true;
		_inputEnable = true;
		Stand();
	}
	
	private function cmd_Aim(userData:Dynamic):Void
	{
		if (!_inputEnable) return;
		var target:Point = userData.target;
		if(target != null){
			if (_actor.x < target.x) {
				_actor.dir = Direction.RIGHT;
			}else if(_actor.x > target.x){
				_actor.dir = Direction.LEFT;
			}
		}else {
			
		}
	}
	private function cmd_DirAttack(userData:Dynamic):Void
	{
		trace(_inputEnable);
		if (!_inputEnable) return;
		var target:Point = userData.target;
		var melee:Bool = userData.melee;
		if(target != null){
			if (_actor.x < target.x) {
				if (_actor.dir != Direction.RIGHT) 
				{
					trace("wrong dir");
				}
				_actor.dir = Direction.RIGHT;
			}else if (_actor.x > target.x) {
				if (_actor.dir != Direction.LEFT) 
				{
					trace("wrong dir");
				}
				_actor.dir = Direction.LEFT;
			}
		}else {
			
		}
		trace("cmd_DirAttack");
		if(melee){
			notify(MsgPlayer.Attack, { type:WeaponType.Melee});
			//notify(MsgActor.Melee);
		}else {
			//通知武器攻击及动作
			notify(MsgPlayer.Attack, { type:WeaponType.Shoot} );
			notify(MsgActor.Attack, _actor.dir);
		}
	}
	
	private function Input_Move(userData:Dynamic):Void {
		//trace("press move");
		notify(MsgActor.Move, userData);
	}
	private function Input_Jump(userData:Dynamic):Void {
		//trace("press jump");
		notify(MsgActor.Jump, _actor.dir);
	}
	private function Input_Melee(userData:Dynamic):Void {
		//trace("press jump");
		notify(MsgActor.Melee, _actor.dir);
	}
	
	private function Input_Attack(userData:Dynamic):Void {
		trace(userData);
		//if (!_actor.canTransition(ActorState.Melee)) return;
		
		notify(MsgActor.Attack, _actor.dir);
	}
	private function Input_Skill(userData:Dynamic):Void {
		if(userData==null)
			notify(MsgPlayer.ChangeSkill, PlayerUtils.getInfo().getProperty(PlayerPropType.SKILL1));
		else
			notify(MsgPlayer.ChangeSkill, PlayerUtils.getInfo().getProperty(userData));
	}
	
	private function Stand():Bool {
		if (owner == null) return false;
		if (!_actor.canTransition(ActorState.Stand)) return false;
		if(_actor.stateID != ActorState.Stand)
			owner.notify(MsgActor.Stand, _actor.dir);
		return true;
	}
}