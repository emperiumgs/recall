package entities
{
	import flash.geom.Rectangle;
	import objects.Grenade;
	import objects.Shard;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.utils.deg2rad;
	import utils.SoundSet;
	
	import entities.Liss;
	import objects.Shot;
	import objects.Ooze;
	import utils.AnimationSet;
	import utils.DEV;
	
	/**
	 * Boss
	 * Starting as a mutation doctor, and turns into a mutant beast
	 * The doctor has two attack types: a shooting, and a granade
	 * The beast has four types: a claw punch, a claw slab, spit ooze, and fire spike shards
	 * @author Joao Borks
	 */
	public class Boss extends Sprite
	{
		// Movement Variables
		private var faceAhead:Boolean;
		// Movement Constants
		private static const SPEED:int = 7;
		// Action Variables
		private var mutant:Boolean;
		private var health:int = 90;
		private var damageable:Boolean;
		private var shot:Boolean;
		private var cooldown:int;
		private var attacking:Boolean;
		private var currentAtk:String;
		public static var clawDamage:int = 10;
		// Animation Variables
		public var animSet:AnimationSet;
		private var xAnimSet:AnimationSet;
		public var soundSet:SoundSet;
		private var aiming:Image;
		private var aimleg:Image;
		private var angle:Number;
		// Collision Variables
		private var _myBounds:Quad;
		private var _atkBounds:Quad;
		// Misc Variables
		private var countdown:int;
		
		public function Boss(spawnX:int, spawnY:int, faceBack:Boolean = true)
		{
			super();
			// Position
			alignPivot("center", "bottom");
			x = spawnX;
			y = spawnY;
			name = "Boss";
			faceAhead = !faceBack;
			// Load Sounds
			soundSet = new SoundSet("dr_");
			// Collision Bounds
			_myBounds = new Quad(60, 140, 0x00FF00);
			_myBounds.alignPivot("center", "bottom");
			_atkBounds = new Quad(250, 100, 0xFF0000);
			_atkBounds.y = _myBounds.bounds.y - 70;
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
			
			// Aim images load
			aimleg = new Image(Game.assets.getTexture("dra_aimleg0000"));
			aimleg.alignPivot("center", "bottom");
			aiming = new Image(Game.assets.getTexture("dra_aiming0000"));
			aiming.alignPivot("left", "center");
			aiming.y -= 3 * aimleg.height / 4;
			aiming.x = _myBounds.x / 2 - 10;
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		// Initialization
		private function init():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			animSet = new AnimationSet("dr_");
			xAnimSet = new AnimationSet("xdr_");
			addChild(animSet);
			
			// Turns the enemy according to its spawn direction
			if (!faceAhead)
				scaleX = -1;
			
			Level.colObjects.push(this);
			Level.enemies.push(this);
			addEventListener("damage", takeDamage);
			animSet.playAnim("dr_still", true);
		}
		
		// Attack function
		private function attack():void
		{
			if (cooldown > 0)
				cooldown--;
			else if (cooldown < 0)
				cooldown = 0;
			var chance:Number = Math.random();
			var player:Liss = Level.player;
			if (mutant)
			{
				xAnimSet.playAnim("xdr_still", true);
				// Mutant Boss Attack Handling
				if (cooldown == 0)
				{
					if (chance <= 0.25)
						toggleAttack("claw");
					else if (chance > 0.25 && chance <= 0.5)
						toggleAttack("slash");
					else if (chance > 0.5 && chance <= 0.75)
						toggleAttack("ooze");
					else
						toggleAttack("spike");
				}
			}
			else
			{
				animSet.playAnim("dr_still", true);
				// Turns to the player
				if (player.x > x && !faceAhead)
					turnAround();
				if (player.x < x && faceAhead)
					turnAround();
				if (cooldown == 0)
				{
					if (chance > 0.15) // In percentage
						toggleAttack("shoot");
					else
						toggleAttack("grenade");
				}
			}
		}
		
		// Aim to shoot function
		private function aim(e:EnterFrameEvent = null):void
		{
			// Aims for 1 seconds
			// Shoots and comes back to default update function
			if (cooldown > 0)
				cooldown--;
			
			if (cooldown == 0 && !shot)
			{
				shoot();
				shot = true;
				cooldown = 30; // 0.5s cooldown to return to default update
			}
			else if (cooldown == 0 && shot)
			{
				toggleAttack(currentAtk);
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
				aiming.rotation = angle;
			}
		}
		
		// Turns into a beast
		private function turnBeast(e:EnterFrameEvent):void
		{
			animSet.playAnim("dr_turn");
			if (animSet.currentAnim.currentFrame == 87)
			{
				if (y != 360)
				{
					y = 360;
					soundSet = new SoundSet("xdr_");
					if (!soundSet.channel) soundSet.playSound("xdr_taunt");
					Level.player.soundSet.playSound("l_17");
				}
			}
			if (animSet.currentAnim.isComplete)
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, turnBeast);
				cooldown = 30;
				Level.player.enable();
				mutant = true;
				health = 120;
				animSet.destroy();
				animSet.removeFromParent(true);
				addChild(xAnimSet);
				_myBounds.width = 200;
				_myBounds.height = 280;
				addEventListener(EnterFrameEvent.ENTER_FRAME, attack);
			}
		}
		
		// Throw grenade
		private function throwGrenade(e:EnterFrameEvent = null):void
		{
			animSet.playAnim("dr_spec");
			cooldown--;
			if (cooldown == 0)
			{
				var posX:int;
				faceAhead == true ? posX = x + _myBounds.width / 4 : posX = x - _myBounds.width / 4;
				var grenade:Grenade = new Grenade(posX, y - _myBounds.height / 4, faceAhead);
				parent.addChild(grenade);
			}
			if (animSet.currentAnim.isComplete)
			{
				toggleAttack(currentAtk);
			}
		}
		
		// Executes Mutant attacks
		private function mutantAttack(e:EnterFrameEvent):void
		{
			xAnimSet.playAnim("xdr_" + currentAtk);
			
			cooldown--;
			if (cooldown == 0)
				damageable = true;
			
			if (currentAtk == "claw" || currentAtk == "slash")
			{
				if (damageable)
				{
					var player:Liss = Level.player;
					var atkBounds:Rectangle = _atkBounds.getBounds(parent);
					if (currentAtk == "slash")
					{
						if (player.isDefending)
						{
							// If defenses are facing the hazard
							if (atkBounds.intersects(player.defBounds))
							{
								player.soundSet.playSound("l_defend");
								damageable = false;
									// Sparkle effects
							}
							else if (atkBounds.intersects(player.myBounds))
							{
								player.dispatchEventWith("damage", false, 10);
								damageable = false;
							}
						}
						else // If not defending
						{
							if (atkBounds.intersects(player.myBounds))
							{
								player.dispatchEventWith("damage", false, 10);
								damageable = false;
							}
						}
					}
					else // If claw attack
					{
						if (atkBounds.intersects(player.myBounds))
						{
							player.dispatchEventWith("damage", false, Boss.clawDamage);
							damageable = false;
						}
					}
				}
			}
			else
			{
				if (damageable)
				{
					if (currentAtk == "ooze")
					{
						damageable = false;
						var ooze:Ooze = new Ooze(x - width / 4, y - height / 4, faceAhead);
						if (faceAhead)
							ooze.x = x + width / 4;
						parent.addChild(ooze);
					}
					else if (currentAtk == "spike")
					{
						damageable = false;
						parent.addChild(new Shard(x, y - _myBounds.height, "<"));
						parent.addChild(new Shard(x, y - _myBounds.height / 2, "<"));
						parent.addChild(new Shard(x, y - _myBounds.height / 3, "<"));
					}
				}
			}
			
			if (xAnimSet.currentAnim.isComplete)
			{
				toggleAttack(currentAtk);
			}
		}
		
		// Toggles between current action and the desired attack
		private function toggleAttack(attackType:String):void
		{
			// Toggle
			if (attacking)
			{
				switch (attackType)
				{
					case "shoot": 
						removeChild(aimleg);
						removeChild(aiming);
						addChild(animSet);
						removeEventListener(EnterFrameEvent.ENTER_FRAME, aim);
						break;
					case "grenade": 
						removeEventListener(EnterFrameEvent.ENTER_FRAME, throwGrenade);
						break;
					case "claw": 
					case "slash": 
					case "ooze": 
					case "spike": 
						removeEventListener(EnterFrameEvent.ENTER_FRAME, mutantAttack);
						break;
					default: 
						throw new Error("There is no attack with this name: " + attackType);
				}
				cooldown = 90;
				attacking = false;
				damageable = false;
				//currentAtk = "";
				removeChild(_atkBounds);
				addEventListener(EnterFrameEvent.ENTER_FRAME, attack);
			}
			else
			{
				attacking = true;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, attack);
				currentAtk = attackType;
				switch (attackType)
				{
					case "shoot": 
						removeChild(animSet);
						addChild(aimleg);
						addChild(aiming);
						addEventListener(EnterFrameEvent.ENTER_FRAME, aim);
						cooldown = 60;
						break;
					case "grenade": 
						addEventListener(EnterFrameEvent.ENTER_FRAME, throwGrenade);
						cooldown = 6;
						break;
					case "claw": 
						addChild(_atkBounds);
					case "slash": 
						addChild(_atkBounds);
					case "ooze": 
					case "spike": 
						addEventListener(EnterFrameEvent.ENTER_FRAME, mutantAttack);
						cooldown = 15;
						break;
					default: 
						throw new Error("There is no attack with this name: " + attackType);
				}
			}
		}
		
		// Fire a bullet in the current angle and direction
		private function shoot():void
		{
			// X adjustment
			var shotX:Number;
			faceAhead ? shotX = x + aiming.bounds.right : shotX = x - aiming.width;
			// Y adjustment
			var shotY:Number = aiming.y - 20 - (-1 * (y + aiming.width / 2 * Math.SQRT2 * Math.sin(angle)));
			// Inclination adjustment
			var inclination:Number = angle;
			if (faceAhead)
				inclination *= -1;
			// Create the shot
			var shot:Shot = new Shot(shotX, shotY, angle, faceAhead);
			parent.addChild(shot);
			soundSet.playSound("dr_atk");
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
		
		// Plays the turning into a beast animation and start the boss fight after it
		private function becomeBeast():void
		{
			soundSet.playSound("dr_3");
			addEventListener(EnterFrameEvent.ENTER_FRAME, turnBeast);
		}
		
		// Takes damage
		private function takeDamage(e:Event, data:int):void
		{
			health -= data;
			if (health <= 0)
			{
				if (mutant)
				{
					var player:Liss = Level.player;
					if (attacking)
					{
						attacking = false;
						removeEventListener(EnterFrameEvent.ENTER_FRAME, mutantAttack);
					}
					else
						removeEventListener(EnterFrameEvent.ENTER_FRAME, attack);
					xAnimSet.playAnim("xdr_death");
					Level.colObjects.splice(Level.colObjects.indexOf(this), 1);
					Level.enemies.splice(Level.enemies.indexOf(this), 1);
					parent.dispatchEventWith("bossdeath");
				}
				else
				{
					if (attacking)
					{
						attacking = false;
						if (currentAtk == "shoot")
						{
							removeEventListener(EnterFrameEvent.ENTER_FRAME, aim);
							removeChild(aimleg, true);
							removeChild(aiming, true);
							addChild(animSet);
						}
						else if (currentAtk == "grenade")
						{
							removeEventListener(EnterFrameEvent.ENTER_FRAME, throwGrenade);
						}
					}
					else
					{
						removeEventListener(EnterFrameEvent.ENTER_FRAME, attack);
					}
					// Become a beast
					Level.player.moveTo(9900, true);
					moveTo(10300, false, true, becomeBeast);
				}
			}
		}
		
		// Enables the boss
		public function enable():void
		{
			addEventListener(EnterFrameEvent.ENTER_FRAME, attack);
		}
		
		// Moves the player to a certain x position
		public function moveTo(destinyX:int, faceForward:Boolean, hurtAnim:Boolean = false, onComplete:Function = null):void
		{
			addEventListener(EnterFrameEvent.ENTER_FRAME, function():void
				{
					hurtAnim == true ? animSet.playAnim("dr_hwalk", true) : animSet.playAnim("dr_walk", true);
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