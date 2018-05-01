package objects 
{
	import flash.media.Sound;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.EnterFrameEvent;
	import utils.SoundSet;
	
	import entities.Liss;
	
	/**
	 * Ooze is the Morbius Mutant special attack
	 * It kicks on the environment changing it's direction and stuns the player
	 * @author Joao Borks
	 */
	public class Ooze extends Image
	{
		private var speedX:int;
		private var speedY:int;
		private var range:int = 600;
		private var sound:Sound;
		//Variable Sound
		
		public function Ooze(posX:int, posY:int, forward:Boolean) 
		{
			super(Game.assets.getTexture("moa_ooze0000"));
			alignPivot();
			x = posX;
			y = posY;
			//7 30 offset
			if (forward) speedX = 10;
			else 
			{
				speedX = -10;
				scaleX *= -1;
			}
			speedY = 10;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			sound = Game.assets.getSound("mo_spec_hit");
		}
		
		// Initialization
		private function init():void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		// Updates the shard movement
		private function update(e:EnterFrameEvent = null):void
		{
			var player:Liss = Level.player;
			// Check player defenses
			if (bounds.intersects(player.myBounds))
			{
				destroy();
				player.trap();
				sound.play();
			}
			
			var colObjects:Array = Level.colObjects;
			for (var i:int = 0; i < colObjects.length; i++)
			{
				if (colObjects[i].name == "block") 
				{
					if (bounds.intersects(colObjects[i].bounds))
					{
						speedY *= -1;
						scaleY *= -1;
					}
				}
			}
			
			if (range == 0)
			{
				destroy();
			}
			else
			{
				x += speedX;
				range -= 10;
				y += speedY;
			}
		}
		
		// Completely destroys this object and all its references
		private function destroy():void
		{
			removeFromParent(true);
		}
	}
}