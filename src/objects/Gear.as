package objects
{
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.geom.Point;
	import starling.display.Image;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Interactable object that triggers determined events
	 * @author Joao Borks
	 */
	public class Gear extends Image
	{
		private var sound:Sound;
		private var trigger:String;
		// Detached Variables
		public var detached:Boolean;
		private var fallStr:int;
		private var grounded:Boolean;
		private var drag:Point;
		private var dragging:Boolean;
		private var spot:GearSpot;
		
		public function Gear(spawnX:int, spawnY:int, eventToTrigger:String = "")
		{
			super(Game.assets.getTexture("gear0000"));
			// Position
			alignPivot();
			x = spawnX;
			y = spawnY;
			trigger = eventToTrigger;
			name = "gear_" + trigger;
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Initialization
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			if (trigger)
			{
				addEventListener("focus", interactToggle);
				addEventListener("unfocus", interactToggle);
			}
		}
		
		// Enables interaction
		private function enable():void
		{
			addEventListener(TouchEvent.TOUCH, onTouch)
		}
		
		// Disables interaction
		private function disable():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			if (!hasEventListener(EnterFrameEvent.ENTER_FRAME) && detached)
				addEventListener(EnterFrameEvent.ENTER_FRAME, update);
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
					if (axisToCheck == "y")
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
							y = obstacle.bottom + bounds.height;
						}
						//sound.play();
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
					if (dragging)
					{
						dragging = false;
						parent.broadcastEventWith("unfocus");
					}
				}
				else if (!obstacle.contains(x - width / 2, y) && !obstacle.contains(x, y) && !obstacle.contains(x + width / 2, y))
				{
					count++;
					if (count == obstacles.length)
						grounded = false;
				}
			}
		}
		
		// Default update function
		private function update(e:EnterFrameEvent):void
		{
			if (!grounded)
			{
				fallStr += Game.GRAVITY;
				y += fallStr;
			}
			collisionControl();
		}
		
		// Event Handler
		private function onTouch(e:TouchEvent):void
		{
			if (detached)
			{
				if (e.getTouch(this, TouchPhase.BEGAN))
				{
					dragging = true;
					removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
					y -= 10;
				}
				else if (e.getTouch(this, TouchPhase.MOVED))
				{
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
					dragging = false;
					addEventListener(EnterFrameEvent.ENTER_FRAME, update);
				}
			}
			else
			{
				if (e.getTouch(this, TouchPhase.BEGAN))
				{
					parent.broadcastEventWith(trigger);
					removeEventListener("focus", interactToggle);
					removeEventListener("unfocus", interactToggle);
					removeEventListener(TouchEvent.TOUCH, onTouch);
					addEventListener(EnterFrameEvent.ENTER_FRAME, action);
				}
			}
		}
		
		// Spins the gear
		private function action(e:EnterFrameEvent):void
		{
			rotation -= 0.05;
		}
		
		private function _counterAction(e:EnterFrameEvent):void
		{
			rotation += 0.05;
		}
		
		// Toggles the interactivity in the box
		private function interactToggle(e:Event):void
		{
			e.type == "focus" ? enable() : disable();
		}
		
		// Stops the enterframe event
		public function stop():void
		{
			removeEventListeners(EnterFrameEvent.ENTER_FRAME);
		}
		
		// Detaches the gear from its current place, and enables the player to reposition it
		public function detach():void
		{
			detached = true;
			alignPivot("center", "bottom");
			spot = new GearSpot(x, y, this);
			parent.addChild(spot);
			parent.setChildIndex(spot, parent.getChildIndex(this));
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			Level.colObjects.push(this);
		}
		
		public function attach(spot:GearSpot, activate:Boolean=true):void
		{
			alignPivot();
			x = spot.x;
			y = spot.y;
			detached = false;
			removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
			spot.removeFromParent(true);
			Level.colObjects.splice(Level.colObjects.indexOf(this), 1);
			if (activate)
			{
				parent.broadcastEventWith(trigger);
				removeEventListener("focus", interactToggle);
				removeEventListener("unfocus", interactToggle);
				removeEventListener(TouchEvent.TOUCH, onTouch);
				addEventListener(EnterFrameEvent.ENTER_FRAME, action);
			}
		}
		
		public function reset():void 
		{
			attach(spot, false);
		}
		
		// GET FUNCTIONS \\
		// Returns the counter action function
		public function get counterAction():Function
		{
			return _counterAction;
		}
		
		public function get myBounds():Rectangle 
		{
			return bounds;
		}
	}
}