package entities
{
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.utils.deg2rad;
	
	import utils.SoundSet;
	import objects.Shot;
	import utils.AnimationSet;
	import utils.DEV;
	
	/**
	 * Elite Soldier Hostile
	 * Shoots from range, and aims for player position
	 * @author Joao Borks
	 */
	public class EliteSoldier extends Sprite
	{
		private static var id:int;
		// Movement Variables
		private var faceAhead:Boolean;
		// Movement Constants
		private static const SPEED:int = 5;
		// Action Variables
		private var health:int = 30;
		public static var damage:int = 10;
		private var attacking:Boolean;
		private var cooldown:int;
		private var shot:Boolean;
		// Animation Variables
		public var animSet:AnimationSet;
		private var aimLeg:Image;
		private var aim:Image;
		private var angle:Number;
		// Collision Variables
		private var _myBounds:Quad;
		// Sound Variables
		public var soundSet:SoundSet;
		// Misc Variables
		private var countdown:int;
		
		public function EliteSoldier(spawnX:int, spawnY:int, faceBack:Boolean = true)
		{
			// Position
			alignPivot("center", "bottom");
			x = spawnX;
			y = spawnY;
			name = "eliteSoldier_" + id++;
			faceAhead = !faceBack;
			// Load Sound
			soundSet = new SoundSet("es_");
			// Collision bounds
			_myBounds = new Quad(50, 140, 0x00FF00);
			_myBounds.alignPivot("center", "bottom");
			addChild(_myBounds);
			if (DEV.entity) _myBounds.alpha = 0.2;
			else _myBounds.visible = false;
			
			// Aim images load
			aimLeg = new Image(Game.assets.getTexture("esa_aimleg0000"));
			aimLeg.alignPivot("center", "bottom");
			aim = new Image(Game.assets.getTexture("esa_aim0000"));
			aim.alignPivot();
			aim.pivotX = 35;
			aim.y -= aimLeg.height + aim.height / 4;
			aim.x += aim.height / 4;
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			animSet = new AnimationSet("es_");
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
		public function playerRange(e:EnterFrameEvent = null):void
		{
			if (cooldown > 0) cooldown--;
			animSet.playAnim("es_still", true);
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
					//Attack
					if (cooldown == 0) toggleAttack();
				}
		}
		
		// Aims and attacks the player
		private function attack(e:EnterFrameEvent = null):void
		{
			// Aims for 1 seconds
			// Shoots and comes back to default update function
			if (cooldown > 0) cooldown--;
			else if (cooldown == 0 && !shot)
			{
				shoot();
				shot = true;
				cooldown = 30; // 0.5s cooldown to return to default update
			}
			else if (cooldown == 0 && shot) 
			{
				toggleAttack();
				shot = false;
			}
			
			if (!shot)
			{
				var pi:Number = Math.PI;
				var coord1:Number = Level.player.y - y;
				var coord2:Number = Level.player.x - x;
				angle = Math.atan2(coord1, coord2);
				var angleD:Number = angle * 180 / pi;
				
				if (!faceAhead)
				{
					angleD *= -1;
					angleD -= 180;
					// Angle restrictions
					if (angleD < -30 && angleD >= -90)
						angleD = -30;
					else if (angleD > -330 && angleD <= -240)
						angleD = -330;
					else if (angleD < -90 && angleD > -240)
						turnAround();
				}
				else
				{
					// Angle restrictions
					if (angleD < -30 && angleD >= -90)
						angleD = -30;
					else if (angleD > 30 && angleD <= 90)
						angleD = 30;
					else if ((angleD > 90 && angleD < 180) || (angleD < -90 && angleD > -180))
						turnAround();
				}
				
				angle = deg2rad(angleD);
				aim.rotation = angle;
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
				removeChild(aimLeg);
				removeChild(aim);
				addChild(animSet);
				cooldown = 90;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, attack);
				addEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
			}
			else
			{
				attacking = true;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				removeChild(animSet);
				addChild(aimLeg);
				addChild(aim);
				addEventListener(EnterFrameEvent.ENTER_FRAME, attack);
				cooldown = Math.floor(Math.random() * 120);
			}
		}
		
		// Fire a bullet in the current angle and direction
		private function shoot():void
		{
			soundSet.playSound("es_atk");
			// X adjustment
			var shotX:Number;
			faceAhead ? shotX = x + aim.x + aim.width / 2 : shotX = x + aim.x - aim.width / 2;
			// Y adjustment
			var shotY:Number = aim.y - 10 - (-1 * (y + aim.width / 2 * Math.SQRT2 * Math.sin(angle)));
			// Inclination adjustment
			var inclination:Number = angle;
			if (faceAhead)
				inclination *= -1;
			// Create the shot
			var shot:Shot = new Shot(shotX, shotY, angle, faceAhead);
			parent.addChild(shot);
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
					attacking = false;
					removeChild(aimLeg, true);
					removeChild(aim, true);
					addChild(animSet);
				}
				else
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, playerRange);
				}
				// Adds the dead sprite to the enemy
				addEventListener(EnterFrameEvent.ENTER_FRAME, die);
				animSet.playAnim("es_death");
				countdown = 15;
				Level.colObjects.splice(Level.colObjects.indexOf(this), 1);
				Level.enemies.splice(Level.enemies.indexOf(this), 1);
				cooldown = 120; // 3 Seconds before removing from game
			}
		}
		
		// Flashes the visibility and removes itself from the game
		private function die(e:EnterFrameEvent = null):void
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