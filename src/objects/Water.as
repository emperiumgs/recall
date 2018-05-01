package objects 
{
	import entities.Liss;
	import flash.geom.Rectangle;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author Maycon
	 * Revised by @author Joao Borks
	 */
	public class Water extends Quad
	{
		public function Water(spawnX:int, spawnY:int) 
		{
			super(440, 1, 0x000088);
			x = spawnX;
			y = spawnY;
			name = "water";
			
			pivotY = height;
			alpha = 0.3;
			Level.colObjects.push(this);
			moveWater();
		}
		
		private function move():void
		{
			var player:Liss = Level.player;
			height += 2;
			
			if (height >= 200)
			{
				height = 200;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, move);
			}
		}
		
		public function moveWater():void
		{
			addEventListener(EnterFrameEvent.ENTER_FRAME, move);
		}
		
		public function get myBounds():Rectangle 
		{
			return bounds;
		}
	}
}