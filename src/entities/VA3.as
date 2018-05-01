package entities 
{
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import objects.VFX;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event
	import starling.events.EnterFrameEvent;
	import utils.SoundSet;
	
	import utils.AnimationSet;
	import objects.Pull;
	import utils.DEV;
	
	/**
	 * VA-3 Mechanical Robot Hostile
	 * Grabs the player from range and shoots fire
	 * @author Joao Borks
	 */
	public class VA3 extends Sprite
	{
		private static var id:int;
		// Movement Variables
		private var faceAhead:Boolean;
		// Movement Constants
		private static const SPEED:int = 4;
		// Action Variables
		private var health:int = 120;
		public static const damage:int = 5;
		private var damageable:Boolean;
		private var cooldown:int;
		private var attacking:Boolean;
		public var pulling:Boolean;
		private var cycle:int;
		// Collision Variables
		private var _myBounds:Quad;
		private var fireBounds:Quad;
		// Animation Variables
		private var animSet:AnimationSet;
		private var fireSet:AnimationSet;
		// Misc Variables
		private var countdown:int;
		//
		private var sound:Sound;
		public var soundSet:SoundSet;
		
		public function VA3(spawnX:int, spawnY:int, faceBack:Boolean = true) 
		{
			// Position
			alignPivot("center", "bottom");
			x = spawnX;
			y = spawnY;
			name = "va3_" + id++;
			faceAhead = !faceBack;
			_myBounds = new Quad(80, 150, 0x00FF00);
			_myBounds.alignPivot("center", "bottom");
			fireBounds = new Quad(70, 90, 0xFF0000);
			fireBounds.alignPivot("left", "center");
			fireBounds.y -= _myBounds.height / 2;
			fireBounds.x += _myBounds.width / 2 + 20;
			sound = Game.assets.getSound("va_atk");
			soundSet = new SoundSet ("va_");
			if (DEV.entity) 
			{
				_myBounds.alpha = 0.2;
				fireBounds.alpha = 0.2;
			}
			else 
			{
				_myBounds.visible = false;
				fireBounds.visible = false;
			}
			addChild(_myBounds);
			addChild(fireBounds);
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Initialization
		private function init():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			animSet = new AnimationSet("va_");
			addChild(animSet);
			fireSet = new AnimationSet("vaa_f", "left", "center");
			fireSet.x = _myBounds.width;
			fireSet.y = - _myBounds.height / 2;
			fireSet.alignPivot("left", "center");
			
			cooldown = 30;
			
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
			faceAhead == true ? animSet.playAnim("va_still_r", true) : animSet.playAnim("va_still_l", true);
			var player:Liss = Level.player;
			var distance:int = Math.max(x - player.x, player.x - x);
			// Turns to the player
			if (player.x > x && !faceAhead)
				turnAround();
			if (player.x < x && faceAhead)
				turnAround();
			// Player is seen
			if (distance < stage.stageWidth - 200 && player.life > 0)
			{
				var chance:Number = Math.random();
				// If in range, attack	
				if (distance < 150 && cooldown == 0)
				{
					//Attack
					turnFire();
				}
				else // Else, move closer to the player
				{
					// Pull the player
					if (chance <= 1 && cooldown == 0) 
						pull();
				}
			}
		}
		
		// Fire in 3 waves
		private function fire(e:EnterFrameEvent):void 
		{
			if (cooldown > 0)
				cooldown --;
			else 
				damageable = true;
			
			if (pulling)
			{
				faceAhead == true ? animSet.playAnim("va_pfire_r", true) : animSet.playAnim("va_pfire_l", true);
			}
			else
			{
				faceAhead == true ? animSet.playAnim("va_fire_r", true) : animSet.playAnim("va_fire_l", true);
			}
			
			fireSet.playAnim("vaa_fire");
			// Fire position
			if (faceAhead)
			{
				fireBounds.x = _myBounds.width / 2 + 20;
				fireBounds.scaleX = 1;
				fireSet.x = _myBounds.width;
				fireSet.scaleX = 1;
			}
			else
			{
				fireBounds.x = - _myBounds.width / 2 - 20;
				fireBounds.scaleX = -1;
				fireSet.x = - _myBounds.width;
				fireSet.scaleX = -1;
			}
			if (fireSet.currentAnim.isComplete) 
			{
				if (cycle < 3)
				{
					// Play fire sound
					fireSet.currentAnim.currentFrame = 1;
					cycle++;
					damageable = false;
					cooldown = 6;
				}
				else
					turnFire();
			}
			if (damageable && cooldown == 0)
			{
				var player:Liss = Level.player;
				// Damage player if in range
				if (fireBounds.getBounds(parent).intersects(player.myBounds))
				{
					player.dispatchEventWith("damage", false, damage);
					damageable = false;
					cooldown = 49;
				}
			}
		}
		
		// Attack functions
		private function pull():void 
		{
			removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
			pulling = true;
			turnFire();
			var posX:int;
			faceAhead == true ? posX = x + _myBounds.width  : posX = x - _myBounds.width;
			var puller:Pull = new Pull(posX, y - _myBounds.height / 2, faceAhead, this);
			parent.addChild(puller);
		}
		
		// Toggles between shooting fire or not
		private function turnFire():void 
		{
			if (attacking)
			{
				attacking = false;
				damageable = false;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, fire);
				addEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				removeChild(fireSet);
				cooldown = 180;
			}
			else
			{
				attacking = true;
				cycle = 0;
				cooldown = 6;
				// play fire sound
				removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				addEventListener(EnterFrameEvent.ENTER_FRAME, fire);
				addChild(fireSet);
			}
		}
		
		// Turns the enemy around
		private function turnAround():void
		{
			if (faceAhead)
				faceAhead = false;
			else
				faceAhead = true;
		}
		
		// Takes damage
		private function takeDamage(e:Event, data:int):void 
		{
			health -= data;
			if (health <= 0)
			{
				if (attacking)
				{
					attacking = false;
					removeEventListener(EnterFrameEvent.ENTER_FRAME, fire);
				}
				else
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				}
				addEventListener(EnterFrameEvent.ENTER_FRAME, die);
				faceAhead == true ? animSet.playAnim("va_death_r") : animSet.playAnim("va_death_l");
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
				var explosion:VFX = new VFX( - _myBounds.width / 2 + Math.random() * _myBounds.width, - Math.random() * _myBounds.height, "explosion1");
				addChild(explosion);
			}
			if (cooldown == 0)
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, die);
				removeChild(animSet, true);
				animSet.destroy();
				parent.broadcastEventWith("va3death");
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