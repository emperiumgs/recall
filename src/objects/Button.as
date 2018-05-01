package objects
{
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	
	/**
	 * Button that must be activated to enable the door to the first loop end
	 * @author Joao Borks
	 */
	public class Button extends Image
	{
		private static var activeList:Vector.<Boolean> = new Vector.<Boolean>(4, true);
		public static var id:int;
		private var activated:Boolean;
		public var currentPusher:*;
		private var move:int;
		private var cooldown:int;
		
		public function Button(posX:int, posY:int)
		{
			super(Game.assets.getTexture("button0000"));
			alignPivot("center", "bottom");
			x = posX;
			y = posY;
			name = "button_" + id++;
			
			Level.colObjects.push(this);
		}
		
		// Activate the button
		public function activate(pusher:*):void
		{
			if (!activated)
			{
				// Stops raising if doing it
				if (hasEventListener(EnterFrameEvent.ENTER_FRAME))
					removeEventListener(EnterFrameEvent.ENTER_FRAME, raise);
				// Activate the button
				activated = true;
				addEventListener(EnterFrameEvent.ENTER_FRAME, lower);
				currentPusher = pusher;
			}
		}
		
		// Moves the button down
		private function lower(e:EnterFrameEvent):void
		{
			if (move < 15)
			{
				if (bounds.contains(currentPusher.x, currentPusher.y) || bounds.contains(currentPusher.myBounds.left, currentPusher.y) || bounds.contains(currentPusher.myBounds.right, currentPusher.y))
				{
					currentPusher.y += Game.GRAVITY;
				}
				else
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, lower);
					activated = false;
					addEventListener(EnterFrameEvent.ENTER_FRAME, raise);
				}
				move += Game.GRAVITY;
				y += Game.GRAVITY;
			}
			else
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, lower);
				addEventListener(EnterFrameEvent.ENTER_FRAME, checkToRaise);
				activeList[parseInt(name.slice(7))] = true;
				if (activeList.every(checkValidity))
				{
					parent.broadcastEventWith("sector3", true);
				}
			}
		}
		
		// Moves the button up
		private function raise(e:EnterFrameEvent):void
		{
			if (move > 0)
			{
				move -= Game.GRAVITY;
				y -= Game.GRAVITY;
			}
			else
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, raise);
			}
		}
		
		// Checks if the pusher object stops pushing
		public function checkToRaise(e:EnterFrameEvent):void
		{
			// If the pusher object isn't in contact anymore
			if (currentPusher != null)
			{
				if (!(bounds.contains(currentPusher.x, currentPusher.y) || bounds.contains(currentPusher.myBounds.left, currentPusher.y) || bounds.contains(currentPusher.myBounds.right, currentPusher.y)))
				{
					cooldown++;
				}
				else
					cooldown = 0;
			}
			if (cooldown == 60 || currentPusher == null)
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, checkToRaise);
				addEventListener(EnterFrameEvent.ENTER_FRAME, raise);
				activeList[parseInt(name.slice(7))] = false;
				parent.broadcastEventWith("sector3", false);
				activated = false;
				currentPusher = null;
			}
		}
		
		// Checks the validity of the entire vector
		private function checkValidity(item:Boolean, index:int, vector:Vector.<Boolean>):Boolean
		{
			if (item)
				return true;
			else
				return false;
		}
		
		public function get myBounds():Rectangle
		{
			return bounds;
		}
	}
}