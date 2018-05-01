package objects 
{
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	
	import entities.Liss;
	
	/**
	 * Enables or disables access to certain locations
	 * @author Maycon
	 * Revised by @author Joao Borks
	 */
	public class Door extends Image
	{
		private static var id:int=1;
		private var movement:int;
		private var automove:Boolean;
		
		public function Door(spawnX:int, spawnY:int) 
		{
			super(Game.assets.getTexture("door0000"));
			x = spawnX;
			y = spawnY;
			name = "door_" + id++;
			
			Level.colObjects.push(this);
			addEventListener("open", openDoor);
		}
		
		// Opens the door on contact
		// Moves the player automaticaly 80px
		private function _autoOpen():void 
		{
			var player:Liss = Level.player;
			if (player.x > x - 70 && player.x < x && player.y == bounds.bottom)
			{
				dispatchEventWith("open");
				removeEventListener(EnterFrameEvent.ENTER_FRAME, autoOpen);
				player.disable();
				automove = true;
			}
		}
		
		// Opens the door and prepares it to close itself
		private function open(e:EnterFrameEvent):void 
		{
			var player:Liss = Level.player;
			if (movement < height - 10)
			{
				y -= 5;
				movement += 5;
			}
			else if (automove)
			{
				player.moveTo(x + 80, true, closeAfterPlayer);
				removeEventListener(EnterFrameEvent.ENTER_FRAME, open);
			}
			else if (player.x > bounds.right)
				dispatchEventWith("close");
		}
		
		// Closes the door and disables it completely
		private function close(e:EnterFrameEvent):void 
		{
			if (movement > 0)
			{
				if (!bounds.intersects(Level.player.myBounds))
				{
					y += 5;
					movement -= 5;
				}
			}
			else
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, close);
				addEventListener("open", openDoor);
			}
		}
		
		// Enables door control
		public function openDoor(e:Event = null):void 
		{
			removeEventListener("open", openDoor);
			addEventListener(EnterFrameEvent.ENTER_FRAME, open);
			addEventListener("close", closeDoor);
			parent.dispatchEventWith(name, false, true);
		}
		
		// Disables door control
		public function closeDoor(e:Event = null):void 
		{
			removeEventListener("close", closeDoor);
			removeEventListener(EnterFrameEvent.ENTER_FRAME, open);
			addEventListener(EnterFrameEvent.ENTER_FRAME, close);
			parent.dispatchEventWith(name, false, false);
		}
		
		// Closes after player successefully passed through the door
		private function closeAfterPlayer():void 
		{
			dispatchEventWith("close");
			Level.player.enable();
		}
		
		// Get functions
		public function get myBounds():Rectangle
		{
			return bounds;
		}
		
		public function get autoOpen():Function 
		{
			return _autoOpen;
		}
	}
}