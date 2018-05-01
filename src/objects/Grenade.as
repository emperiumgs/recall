package objects 
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	
	/**
	 * Grenade that the boss throws on the player
	 * @author Joao Borks
	 */
	public class Grenade extends Image
	{
		private var speedX:int = 20;
		private var speedY:int;
		private var ground:Boolean;
		private var faceAhead:Boolean;
		private var cooldown:int = 30;
		
		public function Grenade(posX:int, posY:int, forward:Boolean = false) 
		{
			super(Game.assets.getTexture("dra_grenade0000"));
			alignPivot();
			x = posX;
			y = posY;
			
			faceAhead = forward;
			if (!faceAhead) speedX *= -1;
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		// Moves the grenade and explodes after a 0.5s cooldown
		private function update(e:EnterFrameEvent=null):void 
		{
			if (!ground)
			{
				speedY += Game.GRAVITY;
				y += speedY;
				var obstacles:Array = Level.colObjects;
				for (var i:int = 0; i < obstacles.length; i++)
				{
					if (obstacles[i].name == "block" && bounds.intersects(obstacles[i].bounds))
					{
						y = obstacles[i].y;
						ground = true;
					}
				}
			}
			if (speedX != 0)
			{
				faceAhead == true ? speedX -= Game.GRAVITY : speedX += Game.GRAVITY;
				x += speedX;
			}
			else if (speedX == 0)
			{
				cooldown--;
				if (cooldown == 0)
					explode();
			}
		}
		
		// Explodes the grenade dealing damage to the player
		private function explode():void 
		{
			removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
			var explosion:VFX = new VFX(x, y, "explosion2", false, true, 10);
			parent.addChild(explosion);
			removeFromParent(true);
		}
	}
}