package gui 
{
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * Displays the character face, and a life bar
	 * @author Joao Borks
	 */
	public class Hud extends Sprite
	{
		public var lifeBar:Quad;
		public const MAX_WIDTH:int = 110;
		
		public function Hud(xPos:int, yPos:int) 
		{
			x = xPos;
			y = yPos;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Initializes the hud
		private function init():void 
		{	
			// Creates the life bar container
			var bar:Quad = new Quad(120, 30, 0x999999);
			addChild(bar);
			
			// Creates the life bar
			lifeBar = new Quad(MAX_WIDTH, 20, 0xCC0000);
			lifeBar.x += 5;
			lifeBar.y += 5;
			addChild(lifeBar);
		}
		
		// Adds the card to the hud
		public function addCard():void 
		{
			var card:Image = new Image(Game.assets.getTexture("card_gui0000"));
			card.x += 130;
			card.name = "card"
			addChild(card);
		}
		
		// Removes the card from the hud
		public function removeCard():void 
		{
			removeChild(getChildByName("card"), true);
		}
	}
}