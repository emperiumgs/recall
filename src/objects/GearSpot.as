package objects 
{
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	
	/**
	 * Indicates that a gear should be placed in this position
	 * When the matching event gear is placed, this is removed, and the gear works
	 * @author Joao Borks
	 */
	public class GearSpot extends Image
	{
		private var matchingGear:Gear;
		private var cooldown:int;
		
		public function GearSpot(posX:int, posY:int, originalGear:Gear) 
		{
			super(Game.assets.getTexture("gear_hold0000"));
			// Position
			alignPivot();
			x = posX;
			y = posY;
			matchingGear = originalGear;
			
			cooldown = 30;
			addEventListener(EnterFrameEvent.ENTER_FRAME, checkGear);
		}
		
		private function checkGear(e:EnterFrameEvent):void 
		{
			if (cooldown > 0)
				cooldown--;
			else
			{
				if (bounds.intersects(matchingGear.bounds)) 
				{
					matchingGear.attach(this);
				}
			}
		}
	}
}