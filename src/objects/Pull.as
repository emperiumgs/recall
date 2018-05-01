package objects 
{
	import entities.VA3;
	import flash.media.Sound;
	import starling.display.Image;
	import starling.events.Event
	import starling.events.EnterFrameEvent;
	
	import entities.Liss;
	
	/**
	 * Pull is the VA-3 Mechanical Robot Hostile special attack
	 * It floates until a certain range and comes back to the robot
	 * If it collides with the player, the player is taken
	 * @author Joao Borks
	 */
	public class Pull extends Image
	{
		private var speedX:int;
		private var initX:int;
		private var _forward:Boolean;
		private var range:int;
		private const MAX_RANGE:int = 300;
		private var nullify:Boolean;
		private var origin:VA3;
		private var sound:Sound;
		
		public function Pull(posX:int, posY:int, forward:Boolean, owner:VA3) 
		{
			super(Game.assets.getTexture("vaa_pull0000"));
			alignPivot();
			x = posX;
			y = posY;
			initX = posX;
			_forward = forward;
			origin = owner;
			sound = Game.assets.getSound("va_spec");
			sound.play();
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Initialization
		private function init():void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (!_forward) 
				scaleX *= -1;
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		// Updates its position
		private function update(e:EnterFrameEvent = null):void
		{
			x += speedX;
			if (range < MAX_RANGE) 
			{
				// Collision check
				var player:Liss = Level.player;
				if (bounds.intersects(player.myBounds))
				{
					player.pulled(this);
					range = MAX_RANGE;
					speedX = 0;
				}
				
				var colObjects:Array = Level.colObjects;
				for (var i:int = 0; i < colObjects.length; i++)
				{
					if (colObjects[i].name == "block") 
					{
						if (bounds.intersects(colObjects[i].bounds))
						{
							range = MAX_RANGE;
							speedX = 0;
						}
					}
				}
				// End Collision Check
				
				if (_forward)
				{
					range += speedX;
					speedX += Game.GRAVITY
				}
				else
				{
					range += - speedX;
					speedX -= Game.GRAVITY;
				}
			}
			if (range >= MAX_RANGE)
			{
				if (!nullify)
				{
					speedX = 0;
					nullify = true;
				}
				_forward == true ? speedX -= Game.GRAVITY : speedX += Game.GRAVITY;
				if (_forward)
				{
					if (x <= initX)
						destroy();
				}
				else
				{
					if (x >= initX)
						destroy();
				}
			}
		}
		
		// Completely destroys this object and all its references
		private function destroy():void
		{
			origin.pulling = false;
			Level.player.unpulled();
			removeFromParent(true);
		}
	}
}