package objects
{
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	
	import entities.EliteSoldier;
	import entities.Liss;
	import utils.AnimationSet;
	
	/**
	 * Bullets fired from the soldiers that can damage the player
	 * @author Joao Borks
	 */
	public class Shot extends Image
	{
		private var animSet:AnimationSet;
		// Movement Variables
		private var xSpeed:int = 10;
		private var ySpeed:Number;
		private var shotRange:int = 300;
		
		// Use angle in radians and use forward if the shot is moving to the right
		public function Shot(posX:int, posY:int, angle:Number, forward:Boolean)
		{
			super(Game.assets.getTexture("esa_shoot0000"));		
			alignPivot();
			x = posX;
			y = posY + 20;
			forward == true ? rotation += angle : rotation -= angle;
			ySpeed = Math.tan(angle) * xSpeed;
			if (!forward)
			{
				xSpeed *= -1;
				scaleX *= -1;
			}
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		// Calculates the trajetory and updates the shot movement
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
					player.dispatchEventWith("damage", false, EliteSoldier.damage);
				}
			}
			// Or if not defending
			else
			{
				if (bounds.intersects(player.myBounds))
				{
					destroy();
					player.dispatchEventWith("damage", false, EliteSoldier.damage);
				}
			}
			if (shotRange == 0)
			{
				destroy();
			}
			else
			{
				x += xSpeed;
				shotRange -= xSpeed;
				y += ySpeed;
			}
		}
		
		// Completely destroys this object and all its references
		private function destroy():void
		{
			removeFromParent(true);
		}
	}

}