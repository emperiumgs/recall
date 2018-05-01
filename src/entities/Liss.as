package entities
{
	import flash.media.Sound;
	import objects.Button;
	import objects.Door;
	import objects.VFX;
	import starling.animation.IAnimatable;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.core.Starling;
	import starling.events.EnterFrameEvent;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import utils.SoundSet;
	
	import utils.AnimationSet;
	import gui.Hud;
	import objects.Pull;
	import utils.DEV;
	
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	/**
	 * Contains functions and properties related to the main playable character on the game
	 * @author Maycon
	 * @author Joao Borks
	 */
	public class Liss extends Sprite
	{
		// Movement Variables
		private var right:Boolean; // Enables movement to right
		private var left:Boolean; // Enables movement to left
		public var faceAhead:Boolean = true; // Faces the character Right direction
		private var fall:Boolean; // Enables falling
		private var jump:Boolean; // Enables jumping
		private var jumpStr:int; // Jump strength
		private var prevPosY:int; // Previous position height
		// Movement Constants
		private static const SPEED:int = 5;
		private static const IMPULSE:int = 20;
		// Action Variables
		private const MAX_HEALTH:int = 80;
		public var health:int;
		public var hpBar:Hud;
		private var damage:int = 10;
		private var damaging:Boolean;
		private var mouseArea:DisplayObject;
		private var knives:Image;
		private var focus:Boolean; // Enables focus mode
		private var defend:Boolean; // Shields the player from some attacks
		private var attack:Boolean; // True if the player is attacking
		private var attackNum:int;
		private var damageable:Boolean;
		private var trapped:Boolean;
		private var ooze:Image;
		private var puller:Pull;
		private var cooldown:int;
		private var water:Boolean;
		// Collision Variables
		private var _myBounds:Quad;
		private var _defBounds:Quad;
		private var atkBounds:Quad;
		// Animation Variables
		public var animSet:AnimationSet;
		// Sound Variables
		public var soundSet:SoundSet;
		// IAnimatable Variables
		private var iaTrap:IAnimatable;
		
		// Creates a new instance of the main character of the game
		public function Liss(spawnX:int, spawnY:int)
		{
			super();
			health = MAX_HEALTH;
			// Position
			alignPivot("center", "bottom");
			x = spawnX;
			y = spawnY;
			name = "Liss";
			prevPosY = y;
			// Load Sounds
			soundSet = new SoundSet("l_");
			// Collision Bounds
			_myBounds = new Quad(50, 140, 0x00FF00);
			_myBounds.alignPivot("center", "bottom");
			_defBounds = new Quad(55, 120, 0xFF0000);
			_defBounds.alignPivot("left", "bottom");
			_defBounds.x = _myBounds.width / 2 - 40;
			_defBounds.y = -20;
			atkBounds = new Quad(50, 80, 0xFF0000);
			atkBounds.alignPivot("left", "bottom");
			atkBounds.x = _myBounds.width / 2;
			atkBounds.y = -60;
			if (DEV.entity)
			{
				_myBounds.alpha = 0.2;
				_defBounds.alpha = 0.2;
				atkBounds.alpha = 0.2;
			}
			else
			{
				_myBounds.visible = false;
				_defBounds.visible = false;
				atkBounds.visible = false;
			}
			addChild(_myBounds);
			
			// Load Animations
			animSet = new AnimationSet("l_");
			// Knives Image
			knives = new Image(Game.assets.getTexture("la_knives0000"));
			knives.alignPivot("center", "top");
			knives.y = -_myBounds.height;
			// Trapped Image
			ooze = new Image(Game.assets.getTexture("moa_oozed0000"));
			ooze.alignPivot("center", "bottom");
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Handles Initialization
		private function init():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			mouseArea = parent.stage;
			// Add Graphics
			addChild(animSet);
			addChild(knives);
			// Enables player control
			enable();
			Level.colObjects.push(this);
			addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
			// Create the life bar on the Level instance
			// As the first parent is the camera, the camera's parent corresponds to the level
			hpBar = new Hud(30, 30);
			parent.parent.addChild(hpBar);
			addEventListener("damage", onHit);
		}
		
		// Enable the keyboard and mouse to control the character
		public function enable(focusIncluded:Boolean = true):void
		{
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			addEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
			if (focusIncluded)
				addEventListener(KeyboardEvent.KEY_DOWN, onFocusKey);
			mouseArea.addEventListener(TouchEvent.TOUCH, onClick);
			addEventListener("unfocus", disableFocus);
		}
		
		// Disable the keyboard and mouse to control the character
		public function disable(focusIncluded:Boolean = true):void
		{
			right = false;
			left = false;
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			removeEventListener(KeyboardEvent.KEY_UP, onKeyReleased);
			if (focusIncluded)
				removeEventListener(KeyboardEvent.KEY_DOWN, onFocusKey);
			mouseArea.removeEventListener(TouchEvent.TOUCH, onClick);
			removeEventListener("unfocus", disableFocus);
		}
		
		// COLLISION FUNCTIONS \\
		// If the checker object has collided the given axis, this function will reposition it
		private function collisionControl(axisToCheck:String = "y"):void
		{
			// Check Collisions
			var obstacles:Array = Level.colObjects;
			var obstacle:Rectangle;
			// Collidable area definition
			var count:int = 0;
			for (var i:int = 0; i < obstacles.length; i++)
			{
				obstacle = obstacles[i].myBounds;
				
				if (obstacles[i].name != name && obstacle.intersects(myBounds))
				{
					if (obstacles[i].name == "platform" && prevPosY > obstacle.y)
					{
						// Do nothing
						count++;
					}
					else if (obstacles[i].name == "water")
					{
						water = true;
						if (health > 0) 
							onHit(null, MAX_HEALTH);
					}
					else
					{
						if (axisToCheck == "y")
						{
							if (obstacles[i] is Button)
							{
								obstacles[i].activate(this);
							}
							// Bottom
							if (prevPosY - obstacle.y < obstacle.bottom - prevPosY + myBounds.height) // Gets true if the bottom is closer and reposition the checker
							{
								y = obstacle.y;
								// Register a fall to ground event
								fall = false;
							}
							// Top
							else // Or put the checker below the collided
							{
								if (obstacles[i] is Door)
									onHit(null, 40);
								else
								{
									y = obstacle.bottom + myBounds.height
									jump = false;
									fall = true;
								}
							}
							jumpStr = 0;
						}
						else if (axisToCheck == "x")
						{
							var myX:int = myBounds.x;
							var myW:int = myBounds.width;
							if (myX + myW / 2 - obstacle.x < obstacle.right - myX - myW / 2)
								x = obstacle.x - myW / 2; // Gets true if left is closer and reposition the checker
							else
								x = obstacle.right + myW / 2; // Or put the checker on the other side of the collided
						}
					}
				}
				else if (!obstacle.contains(x - _myBounds.width / 2, y) && !obstacle.contains(x, y) && !obstacle.contains(x + _myBounds.width / 2, y) && !jump)
				{
					count++;
					if (count == obstacles.length)
						fall = true;
				}
			}
		}
		
		// Respawns the player to the latest checkpoint and displays an flash effect
		private function respawn():void
		{
			// Creates an white quad on the screen that changes slightly its alpha until the player has reseted his position
			var flash:Quad = new Quad(stage.stageWidth, stage.stageHeight);
			flash.alpha = 0;
			parent.parent.addChild(flash);
			const rate:Number = 0.0083;
			var coold:int;
			var dec:Boolean;
			var die:Function = function():void
			{
				if (!dec)
				{
					if (flash.alpha < 1)
					{
						flash.alpha += rate;
						if (water)
							y += Game.GRAVITY;
					}
					
					else if (flash.alpha == 1)
					{
						if (water)
							water = false;
						x = Level.currentCheck.x;
						y = Level.currentCheck.y;
						health = MAX_HEALTH;
						addChild(knives);
						parent.dispatchEventWith("playerdeath");
						hpBar.lifeBar.width = hpBar.MAX_WIDTH;
						addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
						addEventListener("damage", onHit);
						coold = 30;
						dec = true;
						enable();
					}
				}
				else
				{
					if (coold > 0)
						coold--;
					else if (coold == 0)
					{
						if (flash.alpha > 0)
							flash.alpha -= rate;
						else
						{
							removeEventListener(EnterFrameEvent.ENTER_FRAME, die);
							flash.removeFromParent(true);
						}
					}
				}
			};
			addEventListener(EnterFrameEvent.ENTER_FRAME, die);
		}
		
		// Self-explanatory
		private function clearDirectionals():void
		{
			if (right)
				right = false;
			if (left)
				left = false;
		}
		
		// Stretches the hand to sister, used in animations
		public function stretchHand(toggle:Boolean):void 
		{
			if (toggle)
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
				animSet.playAnim("l_focus");
			}
			else
				addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
		}
		
		// Enables the action focus for solving puzzles
		private function enableFocus():void
		{
			focus = true;
			clearDirectionals();
			parent.broadcastEventWith("focus");
			mouseArea.removeEventListener(TouchEvent.TOUCH, onClick);
		}
		
		// When a movable objects collides with anything, the focus is disabled
		private function disableFocus(e:Event = null):void
		{
			focus = false;
			mouseArea.addEventListener(TouchEvent.TOUCH, onClick);
			if (!e)
				parent.broadcastEventWith("unfocus");
		}
		
		// -------------------------------------- //
		// - PLAYER DEBUFF PROGRAMMING ---------- //
		// -------------------------------------- //
		
		// ENEMY ACTIONS \\
		// Disables player control and traps for an amount of time
		public function trap():void
		{
			if (!trapped && health > 0)
			{
				stopCurrentAction();
				trapped = true;
				if (jump)
				{
					jump = false;
					fall = true;
					jumpStr = 0;
				}
				addChild(ooze);
				removeChild(animSet);
				
				iaTrap = Starling.juggler.delayCall(function():void
					{
						enable();
						trapped = false;
						removeChild(ooze);
						addChild(animSet);
					}, 2);
			}
		}
		
		// Player loses control and gets pulled by the robot
		public function pulled(objPulling:Pull):void
		{
			puller = objPulling;
			
			onHit(null, 0);
			
			removeEventListener(EnterFrameEvent.ENTER_FRAME, onDamaged);
			addEventListener(EnterFrameEvent.ENTER_FRAME, onPulled);
		}
		
		// Pull completes and player can escape
		public function unpulled():void
		{
			removeEventListener(EnterFrameEvent.ENTER_FRAME, onPulled);
			puller = null;
			damaging = false;
			if (health > 0)
			{
				addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
				enable();
				addEventListener("damage", onHit);
			}
			else
				onHit(null, 0);
		}
		
		// Stuns the player for a second
		public function stun():void
		{
			// Don't use this for a while
		}
		
		// -------------------------------------- //
		// - SPECIAL ACTIONS PROGRAMMING -------- //
		// -------------------------------------- //
		
		// Moves the player to a certain x position
		public function moveTo(destinyX:int, faceForward:Boolean, onComplete:Function = null):void
		{
			stopCurrentAction(true);
			removeEventListener("damage", onHit);
			right = false;
			left = false;
			addChild(knives);
			addEventListener(EnterFrameEvent.ENTER_FRAME, function():void
				{
					animSet.playAnim("l_walk", true);
					if (knives.x != 0)
						knives.x = 0;
					if (destinyX > x)
					{
						if (!faceAhead)
							faceAhead = true;
						x += SPEED;
						if (x > destinyX)
							x = destinyX;
					}
					else if (destinyX < x)
					{
						if (faceAhead)
							faceAhead = false;
						x -= SPEED;
						if (x < destinyX)
							x = destinyX;
					}
					else
					{
						faceAhead = faceForward;
						removeEventListeners(EnterFrameEvent.ENTER_FRAME);
						addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
						addEventListener("damage", onHit);
						if (onComplete != null)
							onComplete();
					}
					
					// Direction facing
					if (!faceAhead && scaleX != -1)
						scaleX = -1;
					else if (faceAhead && scaleX != 1)
						scaleX = 1;
				});
		}
		
		// Disables player controll and stop all actions
		private function stopCurrentAction(removeUpdate:Boolean = false):void
		{
			disable();
			if (focus)
			{
				focus = false;
				parent.broadcastEventWith("unfocus");
			}
			if (defend)
			{
				defend = false;
				addChild(knives);
				removeChild(_defBounds);
			}
			if (trapped)
			{
				Starling.juggler.remove(iaTrap);
				trapped = false;
				removeChild(ooze);
				addChild(animSet);
			}
			if (attack)
			{
				attack = false;
				attackNum = 0;
				addChild(knives);
				removeChild(atkBounds);
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onAttack);
				if (!removeUpdate)
					addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
			}
			if (removeUpdate)
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
		}
		
		// -------------------------------------- //
		// - EVENT HANDLING PROGRAMMING --------- //
		// -------------------------------------- //
		
		// UPDATE FUNCTIONS \\
		// Updates the character each frame
		private function onFrame(e:EnterFrameEvent):void
		{
			if (cooldown > 0)
				cooldown--;
			// Default Pose
			if (!right && !left && !jump && !fall && !defend && !focus)
			{
				animSet.playAnim("l_still", true);
			}
			
			// Focus Pose
			if (focus)
				animSet.playAnim("l_focus");
			
			// Movement Control
			if (right || left)
			{
				if (right)
				{
					if (!faceAhead)
						faceAhead = true;
					x += SPEED;
				}
				else if (left)
				{
					if (faceAhead)
						faceAhead = false;
					x -= SPEED;
				}
				if (!jump && !fall)
					animSet.playAnim("l_walk", true);
				collisionControl("x");
			}
			
			// Direction facing
			if (!faceAhead && scaleX != -1)
				scaleX = -1;
			else if (faceAhead && scaleX != 1)
				scaleX = 1;
			
			// Jump Handling
			if (jump || fall)
			{
				prevPosY = y; // Updates with the current y and then modifies it
				jumpStr -= Game.GRAVITY;
				y -= jumpStr;
				if (jump && jumpStr == 0)
				{
					jump = false;
					fall = true;
				}
				if (jump)
					animSet.playAnim("l_jump");
				else if (fall)
					animSet.playAnim("l_fall");
			}
			
			// Action Control
			if (defend)
			{
				animSet.playAnim("l_defend");
			}
			
			collisionControl();
		}
		
		// Function to handle the player's attacks
		private function onAttack(e:EnterFrameEvent):void
		{
			if (attackNum == 1)
			{
				animSet.playAnim("l_atkA");
			}
			else if (attackNum == 2)
			{
				animSet.playAnim("l_atkB");
			}
			else if (attackNum == 3)
			{
				animSet.playAnim("l_atkC");
			}
			// Damage the enemies in range
			var enemies:Array = Level.enemies;
			if (enemies && damageable)
			{
				for (var i:int = 0; i < enemies.length; i++)
				{
					if (enemies[i] && enemies[i].life > 0)
					{
						if (atkBounds.getBounds(parent).intersects(enemies[i].myBounds))
						{
							var slice:VFX = new VFX(myBounds.right + atkBounds.width / 2, myBounds.bottom - atkBounds.height, "slice" + attackNum);
							if (!faceAhead)
							{
								slice.scaleX *= -1;
								slice.x = myBounds.left - atkBounds.width / 2;
							}
							parent.addChild(slice);
							enemies[i].dispatchEventWith("damage", false, damage);
							damageable = false;
							soundSet.playSound("l_atk_hit");
						}
					}
				}
			}
			// End Attack Move
			if (animSet.currentAnim.isComplete)
			{
				attack = false;
				damageable = false;
				addChild(knives);
				removeChild(atkBounds);
				attackNum = 0;
				cooldown = 30;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onAttack);
				addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
			}
		}
		
		// Plays the taking damage animation and then re-enables the player control
		private function onDamaged(e:EnterFrameEvent):void
		{
			if (health > 0)
			{
				animSet.playAnim("l_damage");
			}
			else
			{
				animSet.playAnim("l_death");
				
				cooldown--;
				if (cooldown == 0)
					removeChild(knives);
				
				if (water)
					y += Game.GRAVITY;
			}
			if (animSet.currentAnim.isComplete)
			{
				if (health > 0)
				{
					damaging = false;
					addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
					enable();
					addEventListener("damage", onHit);
				}
				else
				{
					damaging = false;
					respawn();
				}
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onDamaged);
			}
			if ((jump || fall) && !water)
			{
				prevPosY = y; // Updates with the current y and then modifies it
				jumpStr -= Game.GRAVITY;
				y -= jumpStr;
				if (jump && jumpStr == 0)
				{
					jump = false;
					fall = true;
				}
				collisionControl();
			}
		}
		
		// Player position equals to the puller positon
		private function onPulled(e:EnterFrameEvent):void
		{
			animSet.playAnim("l_damage");
			if (puller.x > x)
				x = puller.x;
			else
				x = puller.x;
			y = puller.y + height / 2;
		}
		
		// EVENT HANDLERS \\
		// Handles the keyboard inputs
		private function onKeyPressed(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.W && !jump && !fall && !focus && !defend)
			{
				jump = true;
				jumpStr = IMPULSE;
			}
			if (e.keyCode == Keyboard.D && !defend && !focus)
				right = true;
			if (e.keyCode == Keyboard.A && !defend && !focus)
				left = true;
			if (e.keyCode == Keyboard.E && !focus)
			{
				if (attack)
				{
					attack = false;
					addChild(knives);
					removeChild(atkBounds);
					removeEventListener(EnterFrameEvent.ENTER_FRAME, onAttack);
					addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
					cooldown = 30;
				}
				defend = true;
				clearDirectionals();
				addChild(_defBounds);
				removeChild(knives);
			}
		}
		
		private function onFocusKey(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.F && !defend && !attack)
			{
				if (!focus)
					enableFocus();
				else
					disableFocus();
			}
		}
		
		private function onKeyReleased(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.D)
				right = false;
			if (e.keyCode == Keyboard.A)
				left = false;
			if (e.keyCode == Keyboard.E)
			{
				defend = false;
				removeChild(_defBounds);
				addChild(knives);
			}
		}
		
		// Attack functionality triggered by the mouse
		private function onClick(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(mouseArea, TouchPhase.BEGAN);
			if (touch && cooldown <= 0 && !focus && !defend && !damaging)
			{
				if (!attack)
				{
					removeChild(knives);
					addChild(atkBounds);
					attack = true;
					attackNum = 1;
					damageable = true;
					soundSet.playSound("l_atk_b");
					clearDirectionals();
					removeEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
					addEventListener(EnterFrameEvent.ENTER_FRAME, onAttack);
				}
				else
				{
					if (animSet.currentAnim.currentTime >= 0.3)
					{
						if (attackNum == 1)
						{
							attackNum = 2;
							damageable = true;
							soundSet.playSound("l_atk_b");
						}
						else if (attackNum == 2)
						{
							attackNum = 3;
							damageable = true;
							soundSet.playSound("l_atk_b");
						}
					}
				}
			}
		}
		
		// Executed when the player takes damage
		private function onHit(e:Event, data:int):void
		{
			stopCurrentAction(true);
			
			if (!DEV.immortal)
			{
				health -= data;
			}
			if (health <= 0)
			{
				health = 0;
				cooldown = 15; // To remove the knives
			}
			// soundSet.playSound("l_damage");
			// Update life bar
			hpBar.lifeBar.width = (health / MAX_HEALTH) * hpBar.MAX_WIDTH;
			
			damaging = true;
			removeEventListener("damage", onHit);
			addEventListener(EnterFrameEvent.ENTER_FRAME, onDamaged);
		}
		
		// GET FUNCTIONS \\
		// Returns if the player is defending
		public function get isDefending():Boolean
		{
			return defend;
		}
		
		// Returns the player collidable bounds
		public function get myBounds():Rectangle
		{
			return _myBounds.getBounds(parent);
		}
		
		// Returns the player defense bounds
		public function get defBounds():Rectangle
		{
			return _defBounds.getBounds(parent);
		}
		
		// Returns the player health
		public function get life():int
		{
			return health;
		}
	}
}