package entities 
{
	import flash.geom.Rectangle;
	import starling.animation.IAnimatable;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.display.Quad;
	
	import utils.SoundSet;
	import utils.AnimationSet;
	import utils.DEV;
	
	/**
	 * Shock Troop Hostile
	 * Has a shield, and executes a melee attack
	 * @author Joao Borks
	 */
	public class ShockTroop extends Sprite
	{
		private static var id:int;
		// Movement Variables
		private var faceAhead:Boolean;
		private var fall:Boolean;
		private var fallStr:int;
		// Movement Constants
		private static const SPEED:int = 3;
		// Action Variables
		private var health:int = 50; // When loses half, the shield breakes
		private static const damage:int = 10;
		private var shield:Image;
		private var attacking:Boolean;
		private var damageable:Boolean;
		private var cooldown:int;
		// Animation Variables
		private var animSet:AnimationSet;
		// Collision Variables
		private var _myBounds:Quad;
		private var _atkBounds:Quad;
		// Sound Variables
		private var soundSet:SoundSet;
		// Misc Variables
		private var countdown:int;
		
		public function ShockTroop(spawnX:int, spawnY:int, faceBack:Boolean = true) 
		{
			// Position
			alignPivot("center", "bottom");
			x = spawnX;
			y = spawnY;
			name = "shockTroop_" + id++;
			faceAhead = !faceBack;
			animSet = new AnimationSet("st_");
			addChild(animSet);
			// Load Sounds
			soundSet = new SoundSet("st_");
			// Collision Bounds
			_myBounds = new Quad(50, 140, 0x00FF00);
			_myBounds.alignPivot("center", "bottom");
			_atkBounds = new Quad(35, 80, 0xFF0000);
			_atkBounds.y = _myBounds.bounds.y - 20;
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
			
			// Add shield
			shield = new Image(Game.assets.getTexture("sta_def0000"));
			shield.y = _myBounds.bounds.y;
			shield.x = _myBounds.bounds.right - 7;
			addChild(shield);
			
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
			animSet.playAnim("st_still", true);
			var player:Liss = Level.player;
			var distance:int = Math.max(x - player.x, player.x - x);
			// Player is seen
			if (distance < stage.stageWidth - 200 && player.life > 0)
			{
				// Turns to the player
				if (player.x > x && !faceAhead) 
					turnAround();
				if (player.x < x && faceAhead)
					turnAround();
				// If in range, attack	
				if (distance <= 85 && cooldown == 0)
				{
					//Attack
					toggleAttack();
				}
				else // Else, move closer to the player
				{
					// Movement here
					move();
				}
			}
		}
		
		// Attacks and checks collision with the player
		private function attack(e:EnterFrameEvent):void 
		{
			cooldown--;
			if (cooldown == 0)
			{
				damageable = true;
				soundSet.playSound("st_atk");
			}
			animSet.playAnim("st_atk");
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
						soundSet.playSound("st_atk_hit");
					}
				}
				// If not defending
				else
				{
					if (atkBounds.intersects(player.myBounds))
					{
						player.dispatchEventWith("damage", false, damage);
						damageable = false;
						soundSet.playSound("st_atk_hit");
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
		
		// Controls movement
		private function onMove(e:EnterFrameEvent):void 
		{
			if (cooldown > 0)
				cooldown--;
			// Stops if collides with an obstacle
			// Stops when reached attack range
			var player:Liss = Level.player;
			var distance:int = Math.max(x - player.x, player.x - x);
			if (distance <= 85)
			{
				if (cooldown == 0 && !fall)
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, onMove);
					toggleAttack();
				}
				else if (!fall)
				{
					animSet.playAnim("st_still", true);
				}
			}
			else
			{
				// Moves torward the player
				if (player.x > x)
				{
					if (!faceAhead)
						turnAround();
					animSet.playAnim("st_walk", true);
					x += SPEED;
				}
				else
				{
					if (faceAhead)
						turnAround();
					animSet.playAnim("st_walk", true);
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
				/*if (obstacles[i].name != name && obstacle.intersects(myBounds))*/
				var target:String = obstacles[i].name;
				if ((target == "block" || target == "wall" || target == "platform") && obstacle.intersects(myBounds))
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
		private function toggleAttack():void
		{
			if (attacking)
			{
				attacking = false;
				removeChild(_atkBounds);
				removeEventListener(EnterFrameEvent.ENTER_FRAME, attack);
				addEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				cooldown = 90;
			}
			else
			{
				attacking = true;
				addChild(_atkBounds);
				removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				addEventListener(EnterFrameEvent.ENTER_FRAME, attack);
				// Enables the damage according to the movement of the enemy's weapon
				cooldown = 24;
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
			if (health <= 30)
			{
				shield.texture = Game.assets.getTexture("sta_defbrok0000");
			}
			if (health <= 0)
			{
				if (attacking)
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, attack);
					attacking = false;
					removeChild(_atkBounds);
				}
				else
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
					removeEventListener(EnterFrameEvent.ENTER_FRAME, onMove);
				}
				removeChild(shield, true);
				addEventListener(EnterFrameEvent.ENTER_FRAME, die);
				animSet.playAnim("st_death");
				countdown = 15;
				Level.colObjects.splice(Level.colObjects.indexOf(this), 1);
				Level.enemies.splice(Level.enemies.indexOf(this), 1);
				cooldown = 120; // 3 Seconds before removing from game
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