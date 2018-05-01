package entities 
{
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import utils.SoundSet;
	
	import utils.AnimationSet;
	import objects.Ooze;
	import utils.DEV;
	
	/**
	 * Morbius Mutant Hostile
	 * Flies, attacks from melee and shoots ooze to trap the player
	 * @author Joao Borks
	 */
	public class Morbius extends Sprite
	{
		private static var id:int;
		// Movement Variables
		private var faceAhead:Boolean;
		// Movement Constants
		private static const SPEED:int = 6;
		// Action Variables
		private var health:int = 30;
		public static const damage:int = 10;
		private var attacking:Boolean;
		private var damageable:Boolean;
		private var cooldown:int;
		private var fallStr:int;
		private var fall:Boolean;
		// Animation Variables
		public var animSet:AnimationSet;
		// Collision Variables
		private var _myBounds:Quad;
		private var _atkBounds:Quad;
		// Misc Variables
		private var countdown:int;
		// variable sound
		public var soundSet:SoundSet;
		
		public function Morbius(spawnX:int, spawnY:int, faceBack:Boolean = true) 
		{
			// Position
			alignPivot();
			x = spawnX;
			y = spawnY;
			name = "morbius_" + id++;
			faceAhead = !faceBack;
			// Collision bounds
			_myBounds = new Quad(80, 120, 0x00FF00);
			_myBounds.alignPivot();
			_atkBounds = new Quad(60, 60, 0xFF0000);
			_atkBounds.y = _myBounds.bounds.y + _myBounds.bounds.height -40;
			_atkBounds.x = _myBounds.bounds.right - 30;
			
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
			soundSet = new SoundSet("mo_");
			animSet = new AnimationSet("mo_", "center", "center");
			
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
			animSet.playAnim("mo_fly", true);
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
				}
			}
		}
		
		// Attacks and checks collision with the player
		private function attack(e:EnterFrameEvent):void 
		{
			cooldown--;
			if (cooldown == 0)
				damageable = true;
			animSet.playAnim("mo_atk");
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
				shootOoze();
				damageable = false;
				toggleAttack(true);
				soundSet.playSound("mo_spec");
			}
		}
		
		// Shoots an ooze that can stun the player
		private function shootOoze():void 
		{
			var ooze:Ooze = new Ooze(x - width / 4, y - height / 4, faceAhead);
			if (faceAhead) ooze.x = x + width / 4;
			parent.addChild(ooze);
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
				cooldown = 120;
			}
			else
			{
				attacking = true;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				if (special)
				{
					addEventListener(EnterFrameEvent.ENTER_FRAME, specialAtk);
					cooldown = 30;
					damageable = true;
				}
				else
				{
					addEventListener(EnterFrameEvent.ENTER_FRAME, attack);
					addChild(_atkBounds);
					// Enables the damage according to the movement of the enemy's weapon
					cooldown = 18;
				}
			}
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
				}
				addEventListener(EnterFrameEvent.ENTER_FRAME, die);
				animSet.playAnim("mo_death");
				fall = true;
				countdown = 15;
				Level.colObjects.splice(Level.colObjects.indexOf(this), 1);
				Level.enemies.splice(Level.enemies.indexOf(this), 1);
				cooldown = 120;
			}
		}
		
		// Flashes the visibility and removes itself from the game
		private function die(e:EnterFrameEvent=null):void 
		{
			// Check collisions
			if (fall)
			{
				y -= fallStr;
				fallStr -= Game.GRAVITY;
				
				var blocks:Array = Level.colObjects;
				for (var i:int = 0; i < blocks.length; i++)
				{
					if (blocks[i].name == "block" && bounds.intersects(blocks[i].bounds))
					{
						y = blocks[i].y - height / 4;
						fall = false;
					}
				}
			}
			
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
			return  _myBounds.getBounds(parent);
		}
		
		// Returns it current health
		public function get life():int 
		{
			return health;
		}
	}

}