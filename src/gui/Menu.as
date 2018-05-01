package gui
{
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	
	/**
	 * Displays the menu screen of the game
	 * @author Maycon
	 * Revised by @author Joao Borks
	 */
	public class Menu extends Sprite 
	{
		// Screen Parameters
		public var screenW:int;
		public var screenH:int;
		
		// Text
		private var play:Image;
		private var credits:Image;
		private var scale:Boolean;
		private var up: Boolean = true;
		private var esc:Boolean = false;
		private var enter: Boolean;
		
		public function Menu() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Create menu
		public function init():void
		{	
			removeEventListener(Event.ADDED_TO_STAGE, init);
			screenW = stage.stageWidth;
			screenH = stage.stageHeight;
			
			// Add events
			addEventListener(TouchEvent.TOUCH, selectWithMouse);
			addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			addEventListener(KeyboardEvent.KEY_UP, keyReleased);
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			
			var background:Image = new Image(Game.assets.getTexture("menu"));
			addChild(background);
			
			// Create text
			var recall:Image = new Image(Game.assets.getTexture("recall"));
			recall.alignPivot();
			recall.x = screenW / 2;
			recall.y = recall.height;
			addChild(recall);
			
			play = new Image(Game.assets.getTexture(Game.language + "_play"));
			play.alignPivot();
			play.x = screenW / 2;
			play.y = recall.y + 150;
			addChild(play);
			
			credits = new Image(Game.assets.getTexture(Game.language + "_cred"));
			credits.alignPivot();
			credits.x = screenW / 2;
			credits.y = play.y + 100;
			addChild(credits);
		}
		
		private function selectWithMouse(e:TouchEvent):void
		{
			// Increases and descreases the size of jogar and go to the game
			if (e.getTouch(play, TouchPhase.HOVER))
			{ 
				up = true;
			}
			else
			{
				if (e.getTouch(play, TouchPhase.BEGAN))
				{
					var intro:IntroVideo = new IntroVideo();
					parent.addChild(intro);
					intro.start();
					removeSelf();
				}
			}
			
			// Increases and decreases the size of credtis
			if (e.getTouch(credits, TouchPhase.HOVER))
			{
				up = false;
			}
			else
			{
				if (e.getTouch(credits, TouchPhase.BEGAN))
				{
					parent.addChild(new Credits());
					removeSelf();
				}
			}
		}
		
		private function update():void
		{
			if ( up == true)
			{
				play.texture = Game.assets.getTexture(Game.language + "_play_l");
				
				credits.texture = Game.assets.getTexture(Game.language + "_cred");
				
				if ( enter == true)
				{
					var intro:IntroVideo = new IntroVideo();
					parent.addChild(intro);
					intro.start();
					removeSelf();
				}
			}
			else if ( up == false)
			{
				play.texture = Game.assets.getTexture(Game.language + "_play");
				
				credits.texture = Game.assets.getTexture(Game.language + "_cred_l");
				
				if ( enter == true)
				{
					parent.addChild(new Credits());
					removeSelf();
				}
			}
		
		}
		
		// Removes itself from its parent and display another screen
		private function removeSelf():void 
		{
			// Clear events
			removeEventListener(TouchEvent.TOUCH, selectWithMouse);
			removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
			removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
			removeFromParent(true);
		}
		
		private function keyPressed(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S)
			{
				up = false;
			}
			else if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.W)
			{
				up = true;
			}
			if (e.keyCode == Keyboard.ENTER)
			{
				enter = true;
			}
		}
		
		private function keyReleased(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ENTER)
			{
				enter = false;
			}
		}
	}

}