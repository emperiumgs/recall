package objects 
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	
	import entities.Spike;
	import entities.Liss;
	
	/**
	 * Shard is the Spike Mutant special attack
	 * On the direction parameters, pass the following strings for direction:
	 * "<" left "<^" left/top "^" top "^>" right/top ">" right
	 * @author Joao Borks
	 */
	public class Shard extends Image
	{
		private var speedX:int;
		private var speedY:int;
		private var range:int = 300;
		
		public function Shard(posX:int, posY:int, direction:String)
		{
			super(Game.assets.getTexture("spa_shard0000"));
			alignPivot();
			x = posX;
			y = posY;
			
			var pi:Number = Math.PI;
			switch (direction) 
			{
				case "<":
					rotation = pi;
					speedX = -15;
					break;
				case "<^":
					rotation = - 3 * pi / 4;
					speedX = -15;
					speedY = -15;
					break;
				case "^":
					rotation = - pi / 2;
					speedY = -15;
					break;
				case "^>":
					rotation = - pi / 4
					speedX = 15;
					speedY = -15;
					break;
				case ">":
					rotation = 0;
					speedX = 15;
					break;
			}
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
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
			if (player.isDefending)
			{
				// If defenses are facing the hazard
				if (bounds.intersects(player.defBounds))
				{
					player.soundSet.playSound("l_defend");
					destroy();
					// Sparkle effects
				}
				else if (bounds.intersects(player.myBounds))
				{
					destroy();
					player.dispatchEventWith("damage", false, Spike.damage);
				}
			}
			// Or if not defending
			else
			{
				if (bounds.intersects(player.myBounds))
				{
					destroy();
					player.dispatchEventWith("damage", false, Spike.damage);
				}
			}
			if (range == 0)
			{
				destroy();
			}
			else
			{
				x += speedX;
				range-=speedX;
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