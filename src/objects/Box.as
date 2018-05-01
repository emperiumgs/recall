package objects
{
	import entities.Liss;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.EnterFrameEvent;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import utils.SoundSet;
	
	/**
	 * Box used to solve puzzles
	 * Can be moved by the main character's mind power and suffer gravity
	 * Also collides with the environment
	 * @author Maycon
	 * @author Joao Borks
	 */
	public class Box extends Image
	{
		private static var id:int;
		private var fallStr:int;
		private var grounded:Boolean;
		private var drag:Point;
		private var dragging:Boolean;
		private var water:Boolean;
		private var drown:Boolean;
		private var cooldown:int;
		private var soundSet:SoundSet;
		
		public function Box(spawnX:int, spawnY:int)
		{
			super(Game.assets.getTexture("box0000"));
			// Position
			alignPivot("center", "bottom");
			x = spawnX;
			y = spawnY;
			name = "box" + id++;
			soundSet = new SoundSet("obj_box");
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Initialization
		private function init():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Level.colObjects.push(this);
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			addEventListener("focus", interactToggle);
			addEventListener("unfocus", interactToggle);
		}
		
		// Collision Functions
		// If the checker object has collided the given axis, this function will reposition it
		private function collisionControl(axisToCheck:String = "y"):void
		{
			// Check Collisions
			var obstacles:Array = Level.colObjects;
			var obstacle:Rectangle;
			var count:int = 0;
			for (var i:int = 0; i < obstacles.length; i++)
			{
				obstacle = obstacles[i].myBounds;
				if (obstacles[i].name != name && obstacle.intersects(bounds))
				{
					if (obstacles[i].name == "water")
					{
						water = true;
						fallStr = 0;
						if (cooldown < 180)
						{
							if (y - height / 2 < obstacle.y)
								y += Game.GRAVITY;
							else if (y - height / 2 > obstacle.y)
								y = obstacle.y + height / 2;
						}
						else
						{
							var player:Liss = Level.player;
							if (bounds.contains(player.x, player.y) || bounds.contains(player.myBounds.left, player.y) || bounds.contains(player.myBounds.right, player.y))
							{
								player.y += Game.GRAVITY;
							}
							if (y < obstacle.bottom)
							{
								y += Game.GRAVITY;
							}
							else if (y <= obstacle.bottom)
							{
								y = obstacle.bottom;
								removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
							}
						}
					}
					else if (axisToCheck == "y")
					{
						if (bounds.bottom - obstacle.y < obstacle.bottom - bounds.y) // Gets true if the bottom is closer and reposition the checker
						{
							y = obstacle.y;
							// Register a fall to ground event
							grounded = true;
							fallStr = 0;
						}
						else // Or put the checker below the collided
						{
							if (obstacles[i] is Door)
							{
								x = obstacle.x - 35;
							}
							y = obstacle.bottom + bounds.height;
						}
						if (obstacles[i] is Button)
						{
							obstacles[i].activate(this);
						}
						var quoficient:Number = Math.min(x - Level.player.x, Level.player.x - x);
						if (quoficient < -640)
							quoficient = -640;
						if (quoficient >= - 640 && quoficient <= 0)
						{
							soundSet.playSound("obj_box");
							quoficient /= 640;
							quoficient++;
							soundSet.channel.soundTransform.volume = quoficient;
						}
					}
					else if (axisToCheck == "x")
					{
						var myX:int = bounds.x;
						var myW:int = bounds.width;
						if (myX + myW / 2 - obstacle.x < obstacle.right - myX - myW / 2)
							x = obstacle.x - myW / 2; // Gets true if left is closer and reposition the checker
						else
							x = obstacle.right + myW / 2; // Or put the checker on the other side of the collided
						grounded = false;
						//sound.play();
					}
					if (!water && hasEventListener(TouchEvent.TOUCH))
					{
						parent.broadcastEventWith("unfocus");
					}
				}
				else if (!obstacle.contains(x - width / 2, y) && !obstacle.contains(x, y) && !obstacle.contains(x + width / 2, y))
				{
					count++;
					if (count == obstacles.length)
					{
						grounded = false;
						water = false;
						drown = false;
						cooldown = 0;
					}
				}
			}
		}
		
		// Enables interaction
		private function enable():void
		{
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		// Disables interaction
		private function disable():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			if (!hasEventListener(EnterFrameEvent.ENTER_FRAME))
				addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		// Default update function
		private function update(e:EnterFrameEvent):void
		{
			if (!grounded && !water)
			{
				fallStr += Game.GRAVITY;
				y += fallStr;
			}
			if (water)
			{
				var player:Liss = Level.player;
				if (bounds.contains(player.x, player.y) || bounds.contains(player.myBounds.left, player.y) || bounds.contains(player.myBounds.right, player.y))
				{
					drown = true;
				}
			}
			if (drown && cooldown < 180)
				cooldown++;
			collisionControl();
		}
		
		// Event Handler
		private function onTouch(e:TouchEvent):void
		{
			if (e.getTouch(this, TouchPhase.BEGAN))
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
				y -= 10;
			}
			else if (e.getTouch(this, TouchPhase.MOVED))
			{
				//drag = e.getTouch(this, TouchPhase.MOVED).getLocation(this);
				drag = e.getTouch(this, TouchPhase.MOVED).getMovement(this);
				if (drag)
					x += drag.x;
				collisionControl("x");
				if (drag)
					y += drag.y;
				collisionControl();
			}
			else if (e.getTouch(this, TouchPhase.ENDED))
			{
				addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			}
		}
		
		// Toggles the interactivity in the box
		private function interactToggle(e:Event):void
		{
			e.type == "focus" ? enable() : disable();
		}
		
		public function get myBounds():Rectangle
		{
			return bounds;
		}
	}
}