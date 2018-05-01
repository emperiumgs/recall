package objects 
{
	import entities.Liss;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	
	import utils.AnimationSet;
	
	/**
	 * Plays a VFX with certain options
	 * @author Joao Borks
	 */
	public class VFX extends Sprite
	{
		private var animSet:AnimationSet;
		private var _damage:int;
		private var _hazard:Boolean;
		private var _loop:Boolean;
		private var _fxName:String;
		private var cooldown:int;
		
		public function VFX(posX:int, posY:int, fxName:String, loop:Boolean = false, hazard:Boolean = false, damage:int = 0) 
		{
			alignPivot();
			x = posX;
			y = posY;
			_fxName = "vfx_" + fxName;
			_loop = loop;
			_hazard = hazard;
			_damage = damage;
			
			animSet = new AnimationSet(_fxName, "center", "center");
			addChild(animSet);
			
			if (stage) addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			else addEventListener(Event.ADDED_TO_STAGE, function ():void
			{
				removeEventListeners(Event.ADDED_TO_STAGE);
				addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			});
		}
		
		private function update(e:EnterFrameEvent):void 
		{
			animSet.playAnim(_fxName, _loop);
			if (!_loop)
			{
				if (animSet.currentAnim.isComplete)
					destroy();
			}
			if (_hazard)
			{
				if (cooldown > 0) cooldown--;
				else
				{
					var player:Liss = Level.player;
					if (bounds.intersects(player.myBounds))
					{
						player.dispatchEventWith("damage", false, _damage);
						cooldown = 30;
					}
				}
			}
		}
		
		public function destroy():void 
		{
			removeChild(animSet, true);
			animSet.destroy();
			removeFromParent(true);
		}
	}
}