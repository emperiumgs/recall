package gui
{
	import flash.ui.Keyboard;
	import starling.animation.DelayedCall;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.core.Starling;
	
	/**
	 * Shows the startup screen on the game
	 * @author Maycon
	 * Revised by @author Joao Borks
	 */
	public class Intro extends Sprite 
	{
		// Text
		private var language:TextField;
		private var portuguese:TextField;
		private var english:TextField;
		private var logo:Image;
		
		// Cursor
		private var cursor:Quad;
		
		private var up:Boolean = true;
		private var enter:Boolean;
		
		public function Intro() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Initializes the screen
		private function init():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Creates the first screen on the game, which is the main logo
			stage.color = 0;
			
			logo = new Image(Game.assets.getTexture("logo"));
			addChild(logo);
			
			Starling.juggler.delayCall(chooseLang, 2);
		}
		
		// Prompt to choose a language
		private function chooseLang():void
		{	
			removeChild(logo, true);
			
			// Create text
			language = new TextField( 500, 300, "Linguagem/Language", "Verdana", 35, 0xFFFFFF);
			language.pivotX = language.width / 2;
			language.pivotY = language.height / 2;
			language.x = stage.stageWidth / 2;
			language.y = 100;
			addChild(language);
			
			portuguese = new TextField ( 160, 65, "Português", "Verdana", 30, 0xFFFFFF);
			portuguese.pivotX = portuguese.width / 2;
			portuguese.pivotY = portuguese.height / 2;
			portuguese.x = stage.stageWidth / 2;
			portuguese.y = language.y + 110;
			addChild(portuguese);
			
			english = new TextField ( 155, 52, "English", "Verdana", 30, 0xFFFFFF);
			english.pivotX = english.width / 2;
			english.pivotY = english.height / 2;
			english.x = stage.stageWidth / 2;
			english.y = portuguese.y + 70;
			addChild(english);
			
			// Create cursor
			cursor = new Quad ( 20, 10, 0xFFFFFF)
			cursor.pivotX = cursor.width / 2;
			cursor.pivotY = cursor .height / 2;
			cursor.x = portuguese.x - 100;
			cursor.y = portuguese.y;
			addChild(cursor);
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, updateCursor);
			addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			addEventListener(KeyboardEvent.KEY_UP, keyReleased);
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		// Recieves touch/mouse events
		private function onTouch(e:TouchEvent):void
		{
			if(e.getTouch(portuguese, TouchPhase.HOVER))
			{
				up = true;
			}
			else
			{
				if (e.getTouch(portuguese, TouchPhase.BEGAN))
				{
					Game.language = "pt";
					nextScreen();
				}
			}
			if (e.getTouch(english, TouchPhase.HOVER))
			{
				up = false;
			}
			else
			{
				if (e.getTouch(english, TouchPhase.BEGAN))
				{
					Game.language = "en";
					nextScreen();
				}
			}
		}
		
		// Removes this screen completely and proceed to the next screen
		private function nextScreen():void 
		{
			// Remove all event listeners
			removeEventListener(EnterFrameEvent.ENTER_FRAME, updateCursor);
			removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
			removeEventListener(TouchEvent.TOUCH, onTouch);
			// Remove the current screen and add the next one
			parent.addChild(new Menu());
			removeFromParent(true);
		}
		
		// Updates the cursor indicating the option
		private function updateCursor ():void
		{
			if ( up == true)
			{
				cursor.x = portuguese.x - 100;
				cursor.y = portuguese.y;
					
				portuguese.fontSize = 35;
				portuguese.width = 180;
				portuguese.height = 70;
					
				english.fontSize = 30;
					
				if ( enter == true)
				{
					Game.language = "pt";
					nextScreen();
				}
			}
			else
			{
				cursor.x = english.x - 85;
				cursor.y = english.y;
				
				english.fontSize = 35;
				portuguese.fontSize = 30;
				
				if ( enter == true)
				{
					Game.language = "en";
					nextScreen();
				}
			}
		}
		
		// Recieves key inputs
		private function keyPressed(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.W)
			{
				up = true;
			}
				
			if (e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S)
			{
				up = false;
			}
			if (e.keyCode == Keyboard.ENTER)
			{
				enter =  true;
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