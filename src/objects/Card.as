package objects 
{
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	/**
	 * Spawns a card that access the elevator
	 * @author Maycon
	 * Revised by @author Joao Borks
	 */
	public class Card extends Image
	{
		public static var withCard:Boolean = false;
		
		public function Card(spawnX:int, spawnY:int) 
		{
			super(Game.assets.getTexture("card0000"));
			x = spawnX;
			y = spawnY;
			name = "card";
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, takeCard);
		}
		
		
		private function takeCard():void
		{
			if (bounds.intersects(Level.player.myBounds))
			{
				withCard = true;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, takeCard);
				Level.player.hpBar.addCard();
				removeFromParent(true);
			}
		}
	}	
}

