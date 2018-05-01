package
{
	import entities.Tess;
	import flash.geom.Rectangle;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import gui.Credits;
	import objects.Button;
	import objects.VFX;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import starling.display.Quad;
	import starling.core.Starling;
	import utils.SoundTrigger;
	import utils.TextTrigger;
	
	import entities.Boss;
	import entities.Bruce;
	import entities.Morbius;
	import entities.VA3;
	import entities.ShockTroop;
	import entities.EliteSoldier;
	import entities.Spike;
	import entities.Liss;
	import objects.Box;
	import objects.Block;
	import objects.Door;
	import objects.Checkpoint;
	import objects.Card;
	import objects.Elevator;
	import objects.Gear;
	import objects.Helicopter;
	import objects.Wall;
	import objects.Water;
	import gui.Pause;
	import utils.DEV;
	
	import flash.ui.Keyboard;
	
	/**
	 * Game level that contains all the content
	 * @author Maycon
	 * @author Joao Borks
	 */
	public class Level extends Sprite
	{
		// Player
		public static var player:Liss;
		public static var boss:Boss;
		private var tess:Tess;
		// Level Arrays
		public static var colObjects:Array = new Array();
		public static var enemies:Array = new Array();
		// Game loop variable [CORE MECHANIC]
		public static var loop:int = 1;
		private var crashed:Boolean;
		private var heli:Helicopter;
		private var endBoss:Boolean;
		// Current Checkpoint Activated
		public static var currentCheck:Checkpoint;
		// Game camera
		private var container:Sprite;
		// Scren size references
		public var screenW:int;
		public var screenH:int;
		// Room positioning reference
		private var entraceIndustryX:int;
		private var sector1X:int;
		private var sector2X:int;
		private var sector3X:int;
		private var industryBackGroundX:int;
		private var beginRoomBeforeBossX:int;
		private var bossRoomX:int;
		private var finalBossRoomX:int;
		//Checkpoint positioning reference
		private var checkpoint1X:int = 200;
		private var checkpoint2X:int = 2890;
		private var checkpoint3X:int = 3755;
		private var checkpoint4X:int = 6060;
		private var checkpoint5X:int = 9245;
		// Condition to lock de Cam after Checkpoint2
		private var lock:Boolean = false;
		
		public function Level()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			screenW = stage.stageWidth;
			screenH = stage.stageHeight;
			// Game camera creation
			container = new Sprite;
			addChild(container);
			
			// Music
			Game.assets.playSound("soundtrack", 0, 999, new SoundTransform(0.25));
			
			// Events
			container.addEventListener("playerdeath", respawnEvent);
			if (DEV.enabled)
				addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			if (!DEV.camera)
				addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
			
			initMap();
			
			// Checkpoints
			var checkpoint1:Checkpoint = new Checkpoint(200, 400);
			container.addChild(checkpoint1);
			
			var checkpoint2:Checkpoint = new Checkpoint(2890, 200);
			container.addEventListener("mill", function():void
				{
					// Add the mill checkpoint
					currentCheck = checkpoint2;
				});
			
			var checkpoint3:Checkpoint = new Checkpoint(3755, 290);
			container.addChild(checkpoint3);
			
			var checkpoint4:Checkpoint = new Checkpoint(6060, checkpoint3.y)
			container.addChild(checkpoint4);
			
			var checkpoint5:Checkpoint = new Checkpoint(9245, checkpoint3.y);
			container.addChild(checkpoint5);
			
			container.addEventListener("reboot", function (e:Event):void 
			{
				checkpoint3.reset();
				checkpoint4.reset();
				checkpoint5.reset();
			});
			
			container.addEventListener("bossroom", function(e:Event):void
				{
					currentCheck = checkpoint5;
				});
			
			currentCheck = checkpoint1;
			
			// Waterfall
			var waterfall:MovieClip = new MovieClip(Game.assets.getTextures("waterfall"), 24);
			waterfall.x = 2288;
			waterfall.y = 75;
			Starling.juggler.add(waterfall);
			waterfall.play();
			container.addChild(waterfall);
			
			// Watermill
			var watermill:Image = new Image(Game.assets.getTexture("watermill0000"));
			watermill.alignPivot();
			watermill.x = 2890;
			watermill.y = 230;
			container.addChild(watermill);
			
			// Watermill mask
			var wmMask:Image = new Image(Game.assets.getTexture("wm_trim0000"));
			wmMask.alignPivot();
			wmMask.x = watermill.x - 1;
			wmMask.y = watermill.y + 16;
			container.addChild(wmMask);
			
			// Mill
			var mill:Image = new Image(Game.assets.getTexture("helice0000"));
			mill.alignPivot();
			mill.x = watermill.x - 70;
			mill.y = -80;
			container.addChild(mill);
			
			// Helicopter
			// Must be in front of mill objects, but behind masks and the gear
			heli = new Helicopter(420, 100);
			container.addChild(heli);
			
			container.addEventListener("helivanish", function():void
				{
					heli = null;
					spawnForestEnemies();
					if (Level.loop == 1)
						player.soundSet.playSound("l_02");
				});
			container.addEventListener("helicrash", function():void
				{
					crashed = true;
					spawnForestEnemies();
					var fire:VFX = new VFX(2800, 150, "fire", true, true, 10);
					container.addChildAt(fire, container.getChildIndex(heli) + 1);
					fire.addEventListener("mill", function (e:Event):void 
					{
						fire.removeFromParent(true);
						fire = null;
					});
					if (Level.loop != 1)
					{
						var trigger:SoundTrigger = new SoundTrigger(600, 400, "l_10");
						container.addChild(trigger);
					}
					var trigger1:SoundTrigger = new SoundTrigger(2190, 160, "l_11");
					container.addChild(trigger1);
					var trigger2:SoundTrigger = new SoundTrigger(2500, 270, "l_12");
					container.addChild(trigger2);
				});
			
			// Mill Gear
			var millGear:Gear = new Gear(mill.x, mill.y, "mill");
			container.addChild(millGear);
			
			function millEvent(e:Event):void
			{
				//Water
				var water:Water = new Water(3305, 500)
				container.addChild(water);
				water.moveWater();
				var waterMask:Image = new Image(Game.assets.getTexture("trim_water0000"));
				waterMask.alignPivot("left", "bottom");
				waterMask.x = water.x - 13;
				waterMask.y = water.y + 12;
				container.addChild(waterMask);
				
				function removeWater(e:Event):void 
				{
					Level.colObjects.splice(Level.colObjects.indexOf(water), 1);
					water.removeFromParent(true);
					water = null;
					waterMask.removeFromParent(true);
					waterMask = null;
					container.removeEventListener("reboot", removeWater);
				}
				
				container.addEventListener("reboot", removeWater);
				mill.addEventListener(EnterFrameEvent.ENTER_FRAME, function(e:EnterFrameEvent):void
					{
						mill.rotation -= 0.05;
					});
				watermill.addEventListener(EnterFrameEvent.ENTER_FRAME, function(e:EnterFrameEvent):void
					{
						watermill.rotation += 0.02;
					});
			};
			
			mill.addEventListener("mill", millEvent);
			
			// Initial puzzle help
			var text:String = "APERTE F PARA ALTERNAR O MODO CONCENTRAÇÃO";
			if (Game.language == "en")
				text = "PRESS F TO TOGGLE FOCUS MODE";
			var tutorial:TextTrigger = new TextTrigger(3500, 500, text);
			container.addChild(tutorial);
			
			function heliCrash(e:Event):void
			{
				mill.texture = Game.assets.getTexture("helice_broken0000");
				millGear.detach();
				millGear.x -= 200;
				if (tutorial)
				{
					tutorial.removeFromParent(true);
					tutorial = null;
				}
			};
			
			mill.addEventListener("helicrash", heliCrash);
			
			spawnMillBoxes();
			
			// Carrier Morbius
			var carrier:Morbius = new Morbius(4100, 160);
			container.addChild(carrier);
			carrier.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
			carrier.animSet.playAnim("mo_carry", true);
			carrier.addEventListener(EnterFrameEvent.ENTER_FRAME, function (e:EnterFrameEvent):void 
			{
				if (player.x >= carrier.x - 320)
				{
					player.disable();
					if (carrier.y > - 250)
						carrier.y -= 5;
					else 
					{
						if (loop == 1) player.soundSet.playSound("l_03");
						player.enable();
						carrier.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
						carrier.dispatchEventWith("damage", false, 30);
						carrier.removeFromParent(true);
						carrier = null;
					}
				}
			});
			
			// Card
			var card:Card = new Card(4100, -420);
			container.addChild(card);
			
			// Sector 3
			// Add Gears and GearChain
			var gearChain:Image = new Image(Game.assets.getTexture("chain0000"));
			gearChain.alignPivot("center", "top");
			gearChain.x = sector3X + 350;
			gearChain.y = -210;
			container.addChild(gearChain);
			gearChain.addEventListener("elevator", function():void
				{
					gearChain.addEventListener(EnterFrameEvent.ENTER_FRAME, function():void
						{
							gearChain.y -= 2;
							if (gearChain.y < -242)
							{
								gearChain.y = -210;
							}
						});
				});
			gearChain.addEventListener("elevatorstop", function():void
				{
					gearChain.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
				});
			
			var mask:Quad = new Quad(40, 43, 0x8E8F8F);
			mask.alignPivot("center", "bottom");
			mask.x = gearChain.x;
			mask.y = 290;
			container.addChild(mask);
			
			var sector3Gear:Gear = new Gear(gearChain.x - 30, 270 - 180, "elevator");
			container.addChild(sector3Gear);
			sector3Gear.addEventListener("elevatorstop", sector3Gear.stop);
			sector3Gear.addEventListener("va3death", sector3Gear.detach);
			
			var sector3Gear2:Gear = new Gear(gearChain.x + 30, 270 - 180);
			container.addChild(sector3Gear2);
			sector3Gear2.addEventListener("elevator", function(e:Event):void
				{
					sector3Gear2.addEventListener(EnterFrameEvent.ENTER_FRAME, sector3Gear2.counterAction);
				});
			sector3Gear2.addEventListener("elevatorstop", sector3Gear2.stop);
			
			// Elevator
			var elevator:Elevator = new Elevator(sector3X + 100, 270 - 600);
			container.addChild(elevator);
			
			// Buttons
			var button1:Button = new Button(7590, checkpoint4.y);
			container.addChild(button1);
			
			var button2:Button = new Button(button1.x + 205, checkpoint4.y);
			container.addChild(button2);
			
			var button3:Button = new Button(button2.x + 205, checkpoint4.y);
			container.addChild(button3);
			
			var button4:Button = new Button(button3.x + 205, checkpoint4.y);
			container.addChild(button4);
			
			// Button Mask
			var buttonTrim:Image = new Image(Game.assets.getTexture("button_trim0000"));
			buttonTrim.x = button1.x - 35;
			buttonTrim.y = button1.y;
			container.addChild(buttonTrim);
			
			spawnSec3Boxes();
			
			// Player
			player = new Liss(checkpoint1.x, checkpoint1.y);
			container.addChild(player);
			player.soundSet.playSound("l_01");
			player.stretchHand(true);
			
			// Helicopter Disable
			if (!DEV.byHeli)
				player.disable(false);
			
			// Spawn first Enemies
			spawnMillEnemies();
			
			// [CORE MECHANICS]
			// Loop event: Restart all of these objects
			container.addEventListener("reboot", function():void
				{
					currentCheck = checkpoint1;
					// Store x, y and index numbers
					// Deletes, disposes the object
					// Add a new one and add its events
					var objX:int;
					var objY:int;
					var index:int;
					function recycle(target:*):void
					{
						objX = target.x;
						objY = target.y;
						index = container.getChildIndex(target);
						target.removeFromParent(true);
						target = null;
					};
					function recreate(target:*, position:Boolean = true):void
					{
						if (position)
						{
							target.x = objX;
							target.y = objY;
						}
						container.addChildAt(target, index);
					};
					// Start recycling
					// Watermill
					recycle(watermill);
					watermill = new Image(Game.assets.getTexture("watermill0000"));
					watermill.alignPivot();
					recreate(watermill);
					
					// Mill
					recycle(mill);
					mill = new Image(Game.assets.getTexture("helice0000"));
					mill.alignPivot();
					recreate(mill);
					
					// Helicopter
					if (heli)
					{
						colObjects.splice(colObjects.indexOf(heli), 1);
						recycle(heli);
						heli = new Helicopter(420, 100);
						recreate(heli, false);
					}
					else
					{
						heli = new Helicopter(420, 100);
						container.addChildAt(heli, container.getChildIndex(mill) + 1);
					}
					heli.removeEventListener(EnterFrameEvent.ENTER_FRAME, heli.update);
					
					// Mill gear
					if (millGear.detached)
						millGear.reset();
					else
					{
						recycle(millGear);
						millGear = new Gear(objX, objY, "mill");
						recreate(millGear, false);
					}
					
					// Mill Events
					mill.addEventListener("mill", millEvent);
					mill.addEventListener("helicrash", heliCrash);
					
					// Respawn boxes
					respawnMillBoxes();
					
					// Card reset
					if (!card)
					{
						Card.withCard = false;
						var card:Card = new Card(4100, -420);
						container.addChild(card);
					}
					
					// Sector 3 elements reset
					// Interactive Gear
					if (sector3Gear.detached)
						sector3Gear.reset();
					else
					{
						recycle(sector3Gear);
						sector3Gear = new Gear(objX, objY, "elevator");
						recreate(sector3Gear, false);
						sector3Gear.addEventListener("elevatorstop", sector3Gear.stop);
						sector3Gear.addEventListener("va3death", sector3Gear.detach);
					}
					
					// Other Gear
					if (sector3Gear2.hasEventListener(EnterFrameEvent.ENTER_FRAME))
						sector3Gear2.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
					
					// Elevator
					recycle(elevator);
					elevator = new Elevator(sector3X + 100, 270 - 600);
					recreate(elevator, false);
					
					// Raise buttons
					button1.currentPusher = null;
					button2.currentPusher = null;
					button3.currentPusher = null;
					
					// Respawn boxes
					respawnSec3Boxes();
					
					// Player
					player.hpBar.removeFromParent(true);
					player.hpBar = null;
					recycle(player);
					player = new Liss(currentCheck.x, currentCheck.y);
					recreate(player, false);
					player.disable();
					player.stretchHand(true);
					player.soundSet.playSound("l_01", 200);
					function stopTalking(e:EnterFrameEvent):void
					{
						if (player.soundSet.channel.position >= player.soundSet.currentSound.length - 30)
						{
							heli.addEventListener(EnterFrameEvent.ENTER_FRAME, heli.update);
							player.removeEventListener(EnterFrameEvent.ENTER_FRAME, stopTalking);
							player.enable();
							player.disable(false);
						}
					}
					function heliLine(e:EnterFrameEvent):void
					{
						if (player.soundSet.channel.position >= player.soundSet.currentSound.length - 30)
						{
							player.soundSet.playSound("l_09");
							player.removeEventListener(EnterFrameEvent.ENTER_FRAME, heliLine);
							player.addEventListener(EnterFrameEvent.ENTER_FRAME, stopTalking);
							player.stretchHand(false);
						}
					};
					player.addEventListener(EnterFrameEvent.ENTER_FRAME, heliLine);
					
					// Boss deletion
					enemies.splice(enemies.indexOf(boss), 1);
					recycle(boss);
					
					spawnMillEnemies();
				});
			
			container.addEventListener("bossdeath", function ():void 
			{
				function endGame():void 
				{
					var flash:Quad = new Quad(640, 480, 0);
					addChild(flash);
					flash.alpha = 0;
					function flashToCredits(e:EnterFrameEvent):void 
					{
						if (flash.alpha < 1)
							flash.alpha += 0.0055;
						else
						{
							parent.addChild(new Credits());
							Button.id = 0;
							// Remove troublesome boxes
							for (var i:int = 0; i < colObjects.length; i++)
							{
								if (colObjects[i])
								{
									if (colObjects[i] is Box)
									{
										container.removeChild(colObjects[i], true);
										colObjects[i] = null;
										colObjects.splice(i, 1);
										i--;
									}
								}
							}
							container.removeFromParent(true);
							container = null;
							removeFromParent(true);
							dispose();
						}
					};
					addEventListener(EnterFrameEvent.ENTER_FRAME, flashToCredits);
				};
				player.moveTo(10000, false);
				player.soundSet.playSound("l_18");
				container.addChild(tess);
				tess.moveTo(9900, true, endGame);
			});
			
			if (DEV.camera)
			{
				player.disable();
				var ref:Quad = new Quad(50, 10, 0);
				ref.alignPivot();
				ref.x = screenW / 2;
				ref.y = screenH / 2;
				addChild(ref);
				var refy:Quad = new Quad(10, 50, 0);
				refy.alignPivot();
				refy.x = screenW / 2;
				refy.y = screenH / 2;
				addChild(refy);
			}
		}
		
		private function initMap():void
		{
			// Map Images Divided by 2048 width each, and redimensioned with 1150 height
			var map1:Image = new Image(Game.assets.getTexture("map_1"));
			map1.y = -570;
			container.addChild(map1);
			
			var map2:Image = new Image(Game.assets.getTexture("map_2"));
			map2.x = map1.bounds.right;
			map2.y = map1.y;
			container.addChild(map2);
			
			var map3:Image = new Image(Game.assets.getTexture("map_3"));
			map3.x = map2.bounds.right;
			map3.y = map1.y;
			container.addChild(map3);
			
			var map4:Image = new Image(Game.assets.getTexture("map_4"));
			map4.x = map3.bounds.right;
			map4.y = map1.y;
			container.addChild(map4);
			
			var map5:Image = new Image(Game.assets.getTexture("map_5"));
			map5.x = map4.bounds.right;
			map5.y = map1.y;
			container.addChild(map5);
			
			var map6:Image = new Image(Game.assets.getTexture("map_6"));
			map6.x = map5.bounds.right + 45;
			map6.y = map1.y + 30;
			container.addChild(map6);
			
			// Create Ground
			var restGround:Block = new Block(0, 400, 1080, 80); // Restaurant Part
			container.addChild(restGround);
			
			var millGround:Block = new Block(restGround.width, 260, 2235, 260); // Mill Part
			container.addChild(millGround);
			
			var waterGround:Block = new Block(millGround.bounds.right, screenH + 20, 420, 80); // Water part
			container.addChild(waterGround);
			
			var forestGround:Block = new Block(waterGround.bounds.right, millGround.y + 30, 2280, 260); // Forest Part
			container.addChild(forestGround);
			
			var labGround:Block = new Block(forestGround.bounds.right, forestGround.y, 3130, 80); // Lab Part
			container.addChild(labGround);
			
			var bossGround:Block = new Block(labGround.bounds.right + 45, labGround.y, 1275, 80); // Boss Part
			container.addChild(bossGround);
			
			//Create Wall
			var leftWall:Block = new Block(-10, 0, 10, screenH)
			container.addChild(leftWall);
			
			var rightWall:Block = new Block(labGround.bounds.right, screenH - 80 - 930, 45, 900);
			container.addChild(rightWall);
			
			var bossWall:Block = new Block(bossGround.bounds.right, screenH - 80 - 510, 65, 480);
			container.addChild(bossWall);
			
			// Board surface
			var boardSurf:Block = new Block(1550, millGround.y - 175, 90, 10, true);
			container.addChild(boardSurf);
			
			// Create Car
			var car:Block = new Block(2100, millGround.y - 100, 180, 100);
			container.addChild(car);
			
			// Create Tree
			var tree:Quad = new Quad(90, 840, 000000);
			tree.x = 3990;
			tree.y = screenH - 80 - 930;
			
			var tree2:Quad = new Quad(90, 840, 0000000);
			tree2.x = tree.x + 450;
			tree2.y = screenH - 80 - 930;
			
			var tree3:Quad = new Quad(90, 840, 000000);
			tree3.x = tree2.x + 450;
			tree3.y = screenH - 80 - 930;
			
			var tree4:Quad = new Quad(90, 840, 000000);
			tree4.x = tree3.x + 450;
			tree4.y = screenH - 80 - 930;
			
			// Crate Stick
			var stickTree:Block = new Block(tree.x + tree.width, forestGround.y - 335, 120, 30, true);
			container.addChild(stickTree);
			
			var stick2Tree:Block = new Block(tree.x + tree.width, forestGround.y - 660, 150, 30, true);
			container.addChild(stick2Tree);
			
			var stickTree2:Block = new Block(tree2.x - 150, forestGround.y - 145, 390, 30, true);
			container.addChild(stickTree2);
			
			var stick2Tree2:Block = new Block(tree2.x - 150, forestGround.y - 520, 390, 30, true);
			container.addChild(stick2Tree2);
			
			var stickTree3:Block = new Block(tree3.x - 150, forestGround.y - 335, 390, 30, true);
			container.addChild(stickTree3);
			
			var stickTree4:Block = new Block(tree4.x - 180, forestGround.y - 150, 180, 30, true);
			container.addChild(stickTree4);
			
			var stick2Tree4:Block = new Block(tree4.x - 180, forestGround.y - 520, 180, 30, true);
			container.addChild(stick2Tree4);
			
			// Room Reference Variables
			entraceIndustryX = 5970;
			sector1X = 5990;
			sector2X = 6620;
			sector3X = 7230;
			industryBackGroundX = 8485;
			beginRoomBeforeBossX = rightWall.x;
			bossRoomX = 9815;
			finalBossRoomX = bossGround.bounds.right + 20;
			
			// Create Doors
			var door1:Door = new Door(entraceIndustryX + 10, labGround.y - 150);
			container.addChild(door1);
			door1.addEventListener(EnterFrameEvent.ENTER_FRAME, door1.autoOpen);
			
			var door2:Door = new Door(sector2X - 10, labGround.y - 150);
			container.addChild(door2);
			
			// Sector 1 Event
			container.addEventListener("door_1", function(e:Event, data:Boolean):void
				{
					if (data) // Door open
						spawnSector1Enemies();
					else // Door close
					{
						if (loop == 1)
							player.soundSet.playSound("l_05");
						else if (crashed)
							player.soundSet.playSound("l_13");
						clearMillEnemies();
						clearForestEnemies();
						door1.addEventListener(EnterFrameEvent.ENTER_FRAME, door1.autoOpen);
						container.addEventListener(EnterFrameEvent.ENTER_FRAME, function(e:EnterFrameEvent):void
							{
								if (enemies == false && player.health > 0)
								{
									door2.dispatchEventWith("open");
									container.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
								}
							});
					}
				});
			
			var door3:Door = new Door(sector3X + 10, labGround.y - 150);
			container.addChild(door3);
			
			// Sector 2 Event
			container.addEventListener("door_2", function(e:Event, data:Boolean):void
				{
					if (data) // Door open
						spawnSector2Enemies();
					else // Door close
					{
						container.addEventListener(EnterFrameEvent.ENTER_FRAME, function(e:EnterFrameEvent):void
							{
								if (enemies == false && player.health > 0)
								{
									door3.dispatchEventWith("open");
									container.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
								}
							});
					}
				});
			
			// Prepares the boss and the balcony for the final event
			container.addEventListener("door_3", function(e:Event, data:Boolean):void
				{
					if (!data)
					{
						// Create boss with Tess
						boss = new Boss(room4.bounds.right + 50, labGround.y - 430, false);
						container.addChild(boss);
						boss.animSet.playAnim("dr_balcony");
						
						// Create Balcony
						var balcImg:Image = new Image(Game.assets.getTexture("balcony0000"));
						balcImg.x = room4.bounds.right;
						balcImg.y = labGround.y - 430;
						container.addChild(balcImg);
					}
				});
			
			var door4:Door = new Door(industryBackGroundX - 10, labGround.y - 150);
			container.addChild(door4);
			door4.addEventListener("sector3", function(e:Event):void
				{
					e.data == true ? door4.openDoor() : door4.closeDoor();
				});
			if (DEV.bySec3)
				door4.addEventListener(EnterFrameEvent.ENTER_FRAME, door4.autoOpen);
			
			// Moves the player automaticaly to balcony area to loop the game
			container.addEventListener("door_4", function(e:Event, data:Boolean):void
				{
					if (!data && player.x >= door4.x && player.x < door4.x + 150)
					{
						player.disable()
						player.moveTo(8885, false, finalEvent);
					}
				});
			
			var door5:Door = new Door(bossRoomX, bossGround.y - 150);
			container.addChild(door5);
			door5.addEventListener(EnterFrameEvent.ENTER_FRAME, door5.autoOpen);
			container.addEventListener("door_5", function(e:Event, data:Boolean):void
				{
					if (data) // Door open
					{
						if (player.x < door5.x) 
						{
							respawnFinalBoss();
							if (tess == null)
							{
								tess = new Tess(10250, 290);
								container.addChild(tess);
							}
						}
					}
					else
					{
						door5.addEventListener(EnterFrameEvent.ENTER_FRAME, door5.autoOpen);
						if (player.x > door5.x)
						{
							if (!endBoss)
							{
								player.soundSet.playSound("l_15");
								player.disable();
								player.stretchHand(true);
								finalBoss();
								endBoss = true;
							}
							else
							{
								boss.enable();
							}
						}
					}
				});
			container.addEventListener("tessleave", function (e:Event, data:Boolean):void 
			{
				data == true ? door5.dispatchEventWith("open") : door5.dispatchEventWith("close");
			});
			
			// Create Room
			var room:Wall = new Wall(entraceIndustryX, labGround.y - 600);
			container.addChild(room);
			
			var room2:Wall = new Wall(sector2X - 20, room.y);
			container.addChild(room2);
			
			var room3:Wall = new Wall(sector3X, room.y);
			container.addChild(room3);
			
			var room4:Wall = new Wall(industryBackGroundX - 20, room.y);
			container.addChild(room4);
			
			var room5:Wall = new Wall(bossRoomX - 10, room.y, true);
			container.addChild(room5);
			
			// Create Roof
			var roof:Block = new Block(room.x + 50, room.y + 100, 2445, 80);
			container.addChild(roof);
			
			var bossRoof:Block = new Block(rightWall.x + rightWall.width, screenH - 80 - 570, 1318, 60);
			container.addChild(bossRoof);
			
			var balcony:Block = new Block(room4.bounds.right, labGround.y - 430, 90, 180);
			container.addChild(balcony);
			
			// Create Plataform in Room1
			var plataform1:Block = new Block(door1.x + door1.width + 75, labGround.y - 175, 90, 10, true);
			container.addChild(plataform1);
			
			var plataform2:Block = new Block(plataform1.x + plataform1.width + 245, labGround.y - 175, 90, 10, true);
			container.addChild(plataform2);
		}
		
		// Spawn the enemies up to the mill area
		private function spawnMillEnemies():void
		{
			var firstSoldier:EliteSoldier = new EliteSoldier(screenW - 30, 400);
			container.addChild(firstSoldier);
			firstSoldier.animSet.playAnim("es_still");
			firstSoldier.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
			// Helicopter Crash Event Handler
			if (!crashed)
			{
				firstSoldier.addEventListener("helicrash", function(e:Event):void
					{
						firstSoldier.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
						firstSoldier.soundSet.playSound("es_1");
						firstSoldier.addEventListener(EnterFrameEvent.ENTER_FRAME, function(e:EnterFrameEvent):void
							{
								firstSoldier.animSet.playAnim("es_call", false);
								if (firstSoldier.animSet.currentAnim.isComplete)
								{
									firstSoldier.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
									firstSoldier.addEventListener(EnterFrameEvent.ENTER_FRAME, firstSoldier.playerRange);
								}
							});
						// Call Reinforcements
						container.addChild(new ShockTroop(880, 400));
						container.addChild(new Spike(2050, 270));
					});
			}
			else 
			{
				// Call Reinforcements
				container.addChild(new ShockTroop(880, 400));
				container.addChild(new Spike(2050, 270));
			}
			firstSoldier.addEventListener(EnterFrameEvent.ENTER_FRAME, function(e:EnterFrameEvent):void
				{
					if (player.x > firstSoldier.x - 200)
					{
						firstSoldier.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
						firstSoldier.addEventListener(EnterFrameEvent.ENTER_FRAME, firstSoldier.playerRange);
					}
				});
			container.addChild(new EliteSoldier(980, 400));
			container.addChild(new ShockTroop(1500, 270));
			container.addChild(new EliteSoldier(1595, 80));
			container.addChild(new ShockTroop(1950, 270));
			container.addChild(new EliteSoldier(2190, 160));
			container.addChild(new EliteSoldier(2330, 270));
		}
		
		// Spawn the enemies up to the forest area
		private function spawnForestEnemies():void
		{
			container.addChild(new Morbius(4260, -340));
			container.addChild(new Morbius(4650, -200));
			container.addChild(new Morbius(5200, -200));
			if (crashed)
			{
				container.addChild(new Bruce(4500, 290));
				container.addChild(new Bruce(5100, 290));
			}
			else
			{
				container.addChild(new Spike(4500, 290));
				container.addChild(new Spike(5310, 140));
			}
		}
		
		// Spawn the enemies in sector 1
		private function spawnSector1Enemies():void
		{
			container.addChild(new EliteSoldier(6130, 118));
			container.addChild(new ShockTroop(6370, 285));
			container.addChild(new EliteSoldier(6470, 118));
			if (crashed)
			{
				container.addChild(new Morbius(6280, 80));
				container.addChild(new Spike(6500, 285));
			}
			else
				container.addChild(new ShockTroop(6500, 285));
		}
		
		// Spawn the enemies in sector 2
		private function spawnSector2Enemies():void
		{
			if (crashed)
			{
				container.addChild(new VA3(7100, 285));
			}
			else
			{
				container.addChild(new ShockTroop(6950, 285));
				container.addChild(new Spike(7000, 285));
				container.addChild(new EliteSoldier(7100, 285));
			}
		}
		
		// Create boxes for the mill puzzle
		private function spawnMillBoxes(sameIndex1:int = 0, sameIndex2:int = 0):void
		{
			var box:Box = new Box(3230, 260);
			sameIndex1 == 0 ? container.addChild(box) : container.addChildAt(box, sameIndex1);
			
			var box1:Box = new Box(3755, 290);
			sameIndex2 == 0 ? container.addChild(box1) : container.addChildAt(box1, sameIndex2);
			box1.addEventListener("mill", function (e:Event):void 
			{
				box1.x -= 100;
				box1.y -= 140;
			});
		}
		
		// Create boxes for the Sector 3 puzzle
		private function spawnSec3Boxes():void
		{
			var sec3box1:Box = new Box(8205, 270);
			container.addChild(sec3box1);
			
			var sec3box2:Box = new Box(sec3box1.x, 200);
			container.addChild(sec3box2);
			
			var sec3box3:Box = new Box(sec3box1.x - 110, 290);
			container.addChild(sec3box3);
		}
		
		// Respawn boxes for the mill puzzle with water
		private function respawnMillBoxes():void
		{
			// There are 2 boxes that we want to appear behind the water,
			// So we are creating them at the same index as before
			var index1:int;
			var index2:int;
			for (var i:int = 0; i < colObjects.length; i++)
			{
				if (colObjects[i])
				{
					if (colObjects[i].name.slice(0, 3) == "box" && colObjects[i].x < checkpoint4X)
					{
						container.removeChild(colObjects[i], true);
						colObjects[i] = null;
						colObjects.splice(i, 1);
						if (!index1)
							index1 = i;
						else
							index2 = i;
						i--;
					}
				}
			}
			spawnMillBoxes(index1, index2);
		}
		
		// Respawns the boxes for the sector 3 puzzle
		private function respawnSec3Boxes():void
		{
			for (var i:int = 0; i < colObjects.length; i++)
			{
				if (colObjects[i])
				{
					if (colObjects[i] is Box && colObjects[i].x > checkpoint4X && colObjects[i].x < checkpoint5X)
					{
						container.removeChild(colObjects[i], true);
						colObjects[i] = null;
						colObjects.splice(i, 1);
						i--;
					}
				}
			}
			spawnSec3Boxes();
		}
		
		// Clear all enemies up to the mill area
		private function clearMillEnemies():void
		{
			for (var i:int = 0; i < enemies.length; i++)
			{
				if (enemies[i])
				{
					if (enemies[i].x < checkpoint2X)
					{
						container.removeChild(enemies[i], true);
						colObjects.splice(colObjects.indexOf(enemies[i]), 1);
						enemies[i] = null;
						enemies.splice(i, 1);
						i--;
					}
				}
			}
		}
		
		// Clears all enemies up to the forest area
		private function clearForestEnemies():void
		{
			for (var i:int = 0; i < enemies.length; i++)
			{
				if (enemies[i])
				{
					if (enemies[i].x < checkpoint4X && enemies[i].x > checkpoint3X)
					{
						container.removeChild(enemies[i], true);
						colObjects.splice(colObjects.indexOf(enemies[i]), 1);
						enemies[i] = null;
						enemies.splice(i, 1);
						i--;
					}
				}
			}
		}
		
		// Clears all enemies up to the sector area
		private function clearSectorEnemies():void
		{
			for (var i:int = 0; i < enemies.length; i++)
			{
				if (enemies[i])
				{
					if (enemies[i].x < checkpoint5X && enemies[i].x > checkpoint4X)
					{
						container.removeChild(enemies[i], true);
						colObjects.splice(colObjects.indexOf(enemies[i]), 1);
						enemies[i] = null;
						enemies.splice(i, 1);
						i--;
					}
				}
			}
		}
		
		// Respawn enemies up to the mill area
		private function respawnMillEnemies():void
		{
			clearMillEnemies();
			spawnMillEnemies();
		}
		
		//Respawn enemies up to the forest area
		private function respawnForestEnemies():void
		{
			clearForestEnemies();
			spawnForestEnemies();
		}
		
		//Respaen enemies up to the sector area
		private function respawnSectorEnemies():void
		{
			clearSectorEnemies();
			spawnSector1Enemies();
			spawnSector2Enemies();
		}
		
		// Spawns the final boss in his lab
		private function respawnFinalBoss():void
		{
			if (boss)
			{
				enemies.splice(enemies.indexOf(boss), 1);
				colObjects.splice(colObjects.indexOf(boss), 1);
				boss.removeFromParent(true);
				boss = null;
			}
			boss = new Boss(10300, 290);
			container.addChild(boss);
		}
		
		// Final event for normal loop
		private function finalEvent():void
		{
			player.hpBar.visible = false;
			removeEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
			addEventListener(EnterFrameEvent.ENTER_FRAME, onFinal);
		}
		
		// Triggers the latest event 
		private function finalBoss():void 
		{
			// Deletes Tess and closes door5
			function completeLeave():void 
			{
				container.removeChild(tess);
				container.dispatchEventWith("tessleave", false, false);
				boss.enable();
				player.enable();
			}
			// Tells Tess to move away
			function dispatchTess(e:EnterFrameEvent):void 
			{
				if (player.soundSet.channel.position >= player.soundSet.currentSound.length - 30)
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, dispatchTess);
					container.dispatchEventWith("tessleave", false, true);
					Game.assets.playSound("t_03");
					tess.moveTo(tess.x - 200, false, completeLeave);
				}
			}
			// Triggers boss speech line
			function bossSpeech(e:EnterFrameEvent):void 
			{
				if (boss.soundSet.channel.position >= boss.soundSet.currentSound.length - 30)
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, bossSpeech);
					player.soundSet.playSound("l_16");
					addEventListener(EnterFrameEvent.ENTER_FRAME, dispatchTess);
				}
			}
			// After Tess Pull
			function afterPull():void 
			{
				tess.animSet.currentAnim.currentFrame = 1;
				tess.animSet.currentAnim.stop();
				player.stretchHand(false);
				player.disable(true);
				boss.soundSet.playSound("dr_2");
				addEventListener(EnterFrameEvent.ENTER_FRAME, bossSpeech);
			}
			function pull(e:EnterFrameEvent):void 
			{
				if (player.soundSet.channel.position >= player.soundSet.currentSound.length / 2)
				{
					removeEventListener(EnterFrameEvent.ENTER_FRAME, pull);
					tess.draggedTo(player.x - 10, afterPull);
				}
			}
			addEventListener(EnterFrameEvent.ENTER_FRAME, pull);
		}
		
		// Respawns enemies, objects or events, depending on current checkpoint variable
		private function respawnEvent():void
		{
			switch (currentCheck.name)
			{
				case "checkpoint1": 
					respawnMillEnemies();
					break;
				case "checkpoint2": 
					respawnMillBoxes();
					break;
				case "checkpoint3": 
					respawnForestEnemies();
					break;
				case "checkpoint4": 
					clearSectorEnemies();
					container.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
					container.dispatchEventWith("door_1", false, true);
					container.dispatchEventWith("door_1", false, false);
					break;
				case "checkpoint5": 
					respawnFinalBoss();
					break;
				default: 
			}
		}
		
		// Mainly controls the "camera" that follows the player
		private function onFrame(e:EnterFrameEvent):void
		{
			// Gets player last position
			var finalPosX:Number = screenW / 2 - player.myBounds.right - 30;
			var finalPosY:Number = screenH - player.y - 80;
			
			if (player.faceAhead == false)
			{
				finalPosX = screenW / 2 - player.myBounds.left - 30 * -1;
			}
			
			// Camera movement
			container.x += (finalPosX - container.x) / 10;
			container.y += (finalPosY - container.y) / 10;
			
			// Camera Boundaries
			// Container positions on negative, player on positive
			// This variable is equals to the necessary limit on the right side
			var rightLimit:int = screenW - 30; // 30 is the same adjustment as the camera above
			var leftLimt:int = -20; // 20 is the best adjustment for left positions
			
			if (container.x >= 0)
				container.x = 0;
				
			if (container.y >= 570)
				container.y = 570;
			
			if (container.x <= rightLimit - entraceIndustryX && player.x <= entraceIndustryX + 30)
				container.x = rightLimit - entraceIndustryX;
			
			//Fix Camera.y in all the Rooms
			if (player.x >= entraceIndustryX + 30 && player.x <= 8511)
				container.y = 110; // 80 is the ground portion on the screen
			
			// Fix Camera Room 1
			if (player.x >= sector1X && player.x <= sector1X + rightLimit + 30)
			{
				container.x = -sector1X;
			}
			
			// Fix Camera Room 2
			if (player.x >= sector2X && player.x <= sector2X + rightLimit + 30)
			{
				container.x = -sector2X;
			}
			
			//Fix Camera Room3
			if ((player.x >= sector3X + 15 && player.x <= sector3X + 15 + screenW / 2) || (player.faceAhead == false && container.x >= -sector3X - 19 && player.x <= sector3X + 850 && player.x >= sector3X + 15))
				container.x = leftLimt - sector3X;
			
			if (container.x <= -industryBackGroundX + rightLimit + 30 && player.x <= industryBackGroundX)
			{
				container.x = -industryBackGroundX + rightLimit + 30;
				container.y = 110;
			}
			
			//Fix Camera industryBackGround
			if (player.x >= industryBackGroundX && player.x < industryBackGroundX + rightLimit + 10)
			{
				container.x = -industryBackGroundX;
			}
			
			//fix Player insdustryBackGround
			if (player.x >= industryBackGroundX + rightLimit && player.x <= industryBackGroundX + rightLimit + 10)
			{
				player.x = industryBackGroundX + rightLimit;
			}
			
			//Fix Camera beforeRoomBoss 
			if (player.x > beginRoomBeforeBossX + 10 && player.x < bossRoomX)
			{
				container.x = -beginRoomBeforeBossX - 45;
				container.y = 110;
			}
			
			//Fix Camera BossRoom
			if (player.x >= bossRoomX && player.x <= finalBossRoomX)
			{
				container.x = -bossRoomX - 10;
				container.y = 110;
			}
			
			// Fix Camera afeter Checkpoint3
			if (player.bounds.intersects(new Rectangle(4160, 270 - 170, 20, 170)))
			{
				lock = true;
			}
			if ((player.x >= checkpoint3X && player.x <= checkpoint3X + screenW / 2 && lock == true) || (player.faceAhead == false && container.x >= -checkpoint3X && player.x <= checkpoint3X + 850 && player.x >= checkpoint3X && lock == true))
			{
				container.x = -checkpoint3X;
			}
			if (player.x <= 4015 && player.x > checkpoint3X && player.faceAhead == true && lock == true)
			{
				container.x = -checkpoint3X;
			}
			
			//Fix player in CheckPoint2
			if (player.bounds.intersects(new Rectangle(checkpoint3X, 270 - 170, 20, 170)) && lock == true)
			{
				if (player.x - 35 <= checkpoint3X && player.faceAhead == false)
				{
					player.x = 3790;
				}
			}
		}
		
		// Developer debug function
		private function onKeyPress(e:KeyboardEvent):void
		{
			if (DEV.camera)
			{
				if (e.keyCode == Keyboard.UP)
				{
					container.y += 20;
				}
				if (e.keyCode == Keyboard.DOWN)
				{
					container.y -= 20;
				}
				if (e.keyCode == Keyboard.LEFT)
				{
					container.x += 20;
				}
				if (e.keyCode == Keyboard.RIGHT)
				{
					container.x -= 20;
				}
			}
			if (DEV.enabled)
			{
				if (e.keyCode == Keyboard.N)
				{
					player.dispatchEventWith("damage", false, 100);
				}
				if (e.keyCode == Keyboard.F1)
				{
					player.x = checkpoint1X;
					player.y = 400;
				}
				if (e.keyCode == Keyboard.F2)
				{
					player.x = checkpoint2X;
					player.y = 200;
				}
				if (e.keyCode == Keyboard.F3)
				{
					player.x = checkpoint3X;
					player.y = 200;
				}
				if (e.keyCode == Keyboard.F4)
				{
					player.x = checkpoint4X;
					player.y = 270;
				}
				if (e.keyCode == Keyboard.F5)
				{
					player.x = checkpoint5X;
					player.y = 270;
				}
			}
		}
		
		// Final game action, almost as a cinematic event, to trigger the game loop
		private function onFinal(e:EnterFrameEvent):void
		{
			if (container.y < 260)
			{
				container.y++;
				if (container.y == 140)
					player.soundSet.playSound("l_07");
			}
			else if (!boss.soundSet.channel)
			{
				boss.soundSet.playSound("dr_1");
			}
			else
			{
				if (boss.soundSet.channel.position == boss.soundSet.currentSound.length - 90)
				{
					player.stretchHand(true);
					player.soundSet.playSound("l_08");
				}
				else if (boss.soundSet.channel.position >= boss.soundSet.currentSound.length - 30)
				{
					// Reboots the game from the beggining, but with different events
					boss.soundSet.playSound("dr_final");
					container.dispatchEventWith("reboot");
					removeEventListener(EnterFrameEvent.ENTER_FRAME, onFinal);
					var flash:Quad = new Quad(screenW, screenH);
					parent.addChild(flash);
					player.hpBar.visible = true;
					loop++;
					if (crashed)
						crashed = false;
					lock = false;
					addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
					var cooldown:int = 60;
					parent.addEventListener(EnterFrameEvent.ENTER_FRAME, function(e:EnterFrameEvent):void
						{
							if (cooldown > 0)
								cooldown--;
							else
							{
								if (flash.alpha > 0)
									flash.alpha -= 0.0055;
								else
								{
									flash.removeFromParent(true);
									parent.removeEventListeners(EnterFrameEvent.ENTER_FRAME);
								}
							}
						});
				}
			}
		}
	}
}