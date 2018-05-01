package entities 
{
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	
	import objects.Rock;
	import utils.AnimationSet;
	import utils.DEV;
	
	/**
	 * Bruce Mutant Hostile
	 * Attacks from melee and throw rocks in range
	 * @author Joao Borks
	 */
	public class Bruce extends Sprite
	{
		private static var id:int;
		// Movement Variables
		private var faceAhead:Boolean;
		private var fall:Boolean;
		private var fallStr:int;
		// Movement Constants
		private static const SPEED:int = 2;
		// Action Variables
		private var health:int = 90;
		public static const damage:int = 10;
		private var attacking:Boolean;
		private var damageable:Boolean;
		private var cooldown:int;
		// Animation Variables
		private var animSet:AnimationSet;
		// Collision Variables
		private var _myBounds:Quad;
		private var _atkBounds:Quad;
		// Misc Variableds
		private var countdown:int;
		
		public function Bruce(spawnX:int, spawnY:int, faceBack:Boolean = true) 
		{
			// Position
			alignPivot("center", "bottom");
			x = spawnX;
			y = spawnY;
			name = "bruce_" + id++;
			faceAhead = !faceBack;
			// Collision bounds
			_myBounds = new Quad(90, 120, 0x00FF00);
			_myBounds.alignPivot("center", "bottom");
			_atkBounds = new Quad(60, 80, 0xFF0000);
			_atkBounds.y = _myBounds.bounds.y + 10;
			_atkBounds.x = _myBounds.bounds.right;
			if (DEV.entity) 
			{
				_myBounds.alpha = 0.2;
				_atkBounds.alpha = 0.2;
			}
			else 
			{
				_myBounds.visible = false;
				_atkBounds.visible = false;
			}
			addChild(_myBounds);
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Handles initialization
		private function init(e:Event=null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			animSet = new AnimationSet("br_");
			addChild(animSet);
			
			// Turns the enemy according to its spawn direction
			if (!faceAhead)
				scaleX = -1;
				
			Level.colObjects.push(this);
			Level.enemies.push(this);
			addEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
			addEventListener("damage", takeDamage);
		}
		
		// UPDATE FUNCTIONS \\
		// Checks the distance between the player and this enemy
		private function playerRange(e:EnterFrameEvent = null):void
		{
			if (cooldown > 0) cooldown--;
			animSet.playAnim("br_still", true);
			var player:Liss = Level.player;
			var distance:int = Math.max(x - player.x, player.x - x);
			// Player is seen
			if (distance < stage.stageWidth - 200 && player.life > 0)
			{
				var chance:Number = Math.random();
				// Turns to the player
				if (player.x > x && !faceAhead) 
					turnAround();
				if (player.x < x && faceAhead)
					turnAround();
				// If in range, attack	
				if (distance < 150 && cooldown == 0)
				{
					//Attack
					chance > 0.004 ? toggleAttack() : toggleAttack(true);
				}
				else // Else, move closer to the player
				{
					// Movement or ranged attack
					if (chance <= 0.004 && cooldown == 0) 
						toggleAttack(true);
					else
						move();
				}
			}
		}
		
		// Attacks and checks collision with the player
		private function attack(e:EnterFrameEvent):void 
		{
			cooldown--;
			if (cooldown == 0)
				damageable = true;
			animSet.playAnim("br_atk");
			// Check if the attack hits the player
			var player:Liss = Level.player;
			if (damageable)
			{
				var atkBounds:Rectangle = _atkBounds.getBounds(parent);
				// Checks player defenses
				if (player.isDefending)
				{
					// If defenses are facing the hazard
					if (atkBounds.intersects(player.defBounds))
					{
						player.soundSet.playSound("l_defend");
						// Sparkle effects
						damageable = false;
					}
					else if (atkBounds.intersects(player.myBounds))
					{
						player.dispatchEventWith("damage", false, damage);
						damageable = false;
					}
				}
				// If not defending
				else
				{
					if (atkBounds.intersects(player.myBounds))
					{
						player.dispatchEventWith("damage", false, damage);
						damageable = false;
					}
				}
			}
			// Ends the current attack
			if (animSet.currentAnim.isComplete)
			{
				if (damageable) 
					damageable = false;
				toggleAttack();
			}
		}
		
		// Fires its special attack
		private function specialAtk(e:EnterFrameEvent=null):void 
		{
			if (cooldown > 0) 
				cooldown--;
			else if (damageable)
			{
				throwRock();
				damageable = false;
			}
			animSet.playAnim("br_spec");
			if (animSet.currentAnim.isComplete)
			{
				toggleAttack(true);
			}
		}
		
		// Controls movement
		private function onMove(e:EnterFrameEvent):void 
		{
			if (cooldown > 0)
				cooldown--;
			else if (!fall) // Chance to attack from range while moving
			{
				var chance:Number = Math.random();
				if (chance <= 0.004)
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, onMove);
					toggleAttack(true);
				}
			}
			// Stops if collides with an obstacle
			// Stops when reached attack range
			var player:Liss = Level.player;
			var distance:int = Math.max(x - player.x, player.x - x);
			if (distance <= 125)
			{
				if (cooldown == 0 && !fall)
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, onMove);
					toggleAttack();
				}
				else if (!fall)
				{
					animSet.playAnim("br_still", true);
				}
			}
			else
			{
				// Moves torward the player
				if (player.x > x)
				{
					if (!faceAhead)
						turnAround();
					animSet.playAnim("br_walk", true);
					x += SPEED;
				}
				else
				{
					if (faceAhead)
						turnAround();
					animSet.playAnim("br_walk", true);
					x -= SPEED;
				}
			}
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
					// Bottom
					if (y - obstacle.y < obstacle.bottom - y + myBounds.height) // Gets true if the bottom is closer and reposition the checker
					{
						y = obstacle.y;
						// Register a fall to ground event
						fall = false;
						fallStr = 0;
					}
				}
				else if (!obstacle.contains(x - _myBounds.width / 2, y) && !obstacle.contains(x, y) && !obstacle.contains(x + _myBounds.width / 2, y))
				{
					count++;
					if (count == obstacles.length)
						fall = true;
				}
			}
			// Fall if not in ground
			if (fall)
			{
				fallStr += Game.GRAVITY;
				y += fallStr;
			}
		}
		
		// Throws a rock up, and it falls randomly near the player
		private function throwRock():void
		{
			// Rock behavior
			var rock:Rock = new Rock(x - width / 4, y);
			if (faceAhead) rock.x = x + width / 4;
			parent.addChild(rock);
		}
		
		// Turns the enemy around
		private function turnAround():void
		{
			if (faceAhead)
			{
				faceAhead = false;
				scaleX = -1;
			}
			else
			{
				faceAhead = true;
				scaleX = 1;
			}
		}
		
		// Toggles between the range state and the attack state
		private function toggleAttack(special:Boolean = false):void
		{
			if (attacking)
			{
				attacking = false;
				removeChild(_atkBounds);
				special == true ? removeEventListener(EnterFrameEvent.ENTER_FRAME, specialAtk) : removeEventListener(EnterFrameEvent.ENTER_FRAME, attack);
				addEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				cooldown = 90;
			}
			else
			{
				attacking = true;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				if (special)
				{
					addEventListener(EnterFrameEvent.ENTER_FRAME, specialAtk);
					cooldown = 6;
					damageable = true;
				}
				else
				{
					addEventListener(EnterFrameEvent.ENTER_FRAME, attack);
					addChild(_atkBounds);
					// Enables the damage according to the movement of the enemy's weapon
					cooldown = 12;
				}
			}
		}
		
		// Trigger Movement
		private function move():void 
		{
			removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
			addEventListener(EnterFrameEvent.ENTER_FRAME, onMove);
		}
		
		// Takes damage
		private function takeDamage(e:Event, data:int):void 
		{
			health -= data;
			if (health <= 0)
			{
				if (attacking)
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, attack);
					removeEventListener(EnterFrameEvent.ENTER_FRAME, specialAtk);
					attacking = false;
					removeChild(_atkBounds);
				}
				else
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
					removeEventListener(EnterFrameEvent.ENTER_FRAME, onMove);
				}
				addEventListener(EnterFrameEvent.ENTER_FRAME, die);
				animSet.playAnim("br_death");
				countdown = 15; // This time, cooldown is to fade the enemy
				Level.colObjects.splice(Level.colObjects.indexOf(this), 1);
				Level.enemies.splice(Level.enemies.indexOf(this), 1);
				cooldown = 120;
			}
		}
		
		// Flashes the visibility and removes itself from the game
		private function die(e:EnterFrameEvent=null):void 
		{
			cooldown--;
			countdown--;
			if (countdown == 0)
			{
				countdown = 15;
				if (visible)
					visible = false;
				else
					visible = true;
			}
			if (cooldown == 0)
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, die);
				removeChild(animSet, true);
				animSet.destroy();
				removeFromParent(true);
			}
		}
		
		// GET FUNCTIONS \\
		// Returns the current animation for bound detecting
		public function get myBounds():Rectangle
		{
			return _myBounds.getBounds(parent);
		}
		
		// Returns it current health
		public function get life():int 
		{
			return health;
		}
	}
}