package gui 
{
	import flash.ui.Keyboard;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	
	/**
	 * Display the credits
	 * @author Maycon
	 */
	public class Credits extends Sprite 
	{
		private var cooldown:Number = 870;
		
		public function Credits() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Initializes the credits
		private function init():void
		{	
			var fundo:Image = new Image (Game.assets.getTexture("credits"));
			addChild(fundo);
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			addEventListener(EnterFrameEvent.ENTER_FRAME, moveCredits);
		}
		
		private function moveCredits():void
		{
			cooldown --;
			if(cooldown >= 0)
					y -= 2;
			if (cooldown <= -120)
			{
				addEventListener(EnterFrameEvent.ENTER_FRAME, exitCredit);
			}
		}
		
		private function exitCredit():void
		{
			removeEventListener(EnterFrameEvent.ENTER_FRAME, moveCredits);
			removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			parent.addChild(new Menu());
			removeFromParent(true);
		}
		
		// Recieves key inputs
		private function keyPressed(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE)
			{
				removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
				parent.addChild(new Menu());
				removeFromParent(true);
			}
		}
	}
}