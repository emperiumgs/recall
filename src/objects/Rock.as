package objects 
{
	import entities.Liss;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	
	/**
	 * Rock is the Bruce Mutant's special attack
	 * It is throwed up, and falls down randomly near the player position
	 * @author Joao Borks
	 */
	public class Rock extends Image
	{
		private const IMPULSE:int = 40;
		private var fall:Boolean;
		private var airImpulse:int;
		private var cooldown:int;
		
		public function Rock(spawnX:int, spawnY:int) 
		{
			super(Game.assets.getTexture("bra_rock0000"));
			alignPivot();
			x = spawnX;
			y = spawnY;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Intialization
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			airImpulse = IMPULSE;
			Starling.juggler.delayCall(function():void
			{
				addEventListener(EnterFrameEvent.ENTER_FRAME, update);
				cooldown = 30;
			}, 0.2);
		}
		
		// Collides with the player and with the ground
		private function collisionControl():void 
		{
			var colObjects:Array = Level.colObjects;
			for (var i:int = 0; i < colObjects.length; i++)
			{
				if (colObjects[i].name == "block" || colObjects[i].name == "Liss")
				{
					if (bounds.intersects(colObjects[i].bounds))
					{
						if (colObjects[i].name == "Liss")
						{
							if (bounds.intersects(colObjects[i].myBounds))
							{
								colObjects[i].dispatchEventWith("damage", false, 30);
								destroy();
							}
						}
						else
						{
							destroy();
						}
					}
				}
			}
		}
		
		private function update():void 
		{
			if (cooldown > 0) cooldown--;
			y -= airImpulse;
			airImpulse -= Game.GRAVITY;
			if (airImpulse == 0)
			{
				x = Level.player.x - 100 + Math.random() * 200;
			}
			if (cooldown == 0) collisionControl();
		}
		
		// Completely destroys this object and all its references
		private function destroy():void
		{
			var broken:VFX = new VFX(x, y, "rock");
			parent.addChild(broken);
			removeFromParent(true);
		}
	}

}