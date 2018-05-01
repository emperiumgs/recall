package gui 
{
	import flash.ui.Keyboard;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	
	/**
	 * ...
	 * @author Maycon
	 */
	public class Pause extends Sprite 
	{
		// screen paramets
		public var screenW:int = Game.SCREEN_WIDTH;
		public var screenH:int = Game.SCREEN_HEIGHT;
		
		public var pause:TextField;
		public var continues: TextField;
		public var desist: TextField;
		
		public function Pause() 
		{
			addEventListener(Event.ADDED_TO_STAGE, paused);
			addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
		}
		
		public function paused():void
		{	
			pause = new TextField (220, 150, "Pause", "verdana", 70, 0xFFFFFF)
			pause.pivotX = pause.width / 2;
			pause.x = screenW / 2;
			addChild(pause);
			
			continues = new TextField ( 200, 50, "Continuar", "Verdana", 40, 0xFFFFFF)
			continues.pivotX = continues.width / 2;
			continues.x = screenW / 2;
			continues.y = pause.y + 200;
			addChild(continues);
			
			desist = new TextField (160, 75, "Desistir", "Verdana", 40, 0xFFFFFF)
			desist.pivotX = desist.width / 2;
			desist.x = screenW / 2;
			desist.y = continues.y + 150;
			addChild(desist);
			
			removeEventListener(Event.ADDED_TO_STAGE, paused);
		}
		
		private function keyPressed(e:KeyboardEvent):void
		{
			if ( e.keyCode == Keyboard.ESCAPE)
			{
				stage.color = 0xFFFFFF;
				parent.addChild(new Level());
				removeEventListener(Event.ADDED_TO_STAGE, paused);
				removeFromParent(true);
			}
			
		}
		
	}

}