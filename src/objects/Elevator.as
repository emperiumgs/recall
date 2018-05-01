package objects 
{
	import entities.Liss;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	
	/**
	 * Transports the player to the boss room
	 * @author Maycon
	 * Revised by @author Joao Borks
	 */
	public class Elevator extends Sprite
	{
		private var flash:Quad;
		
		private const rate:Number = 0.0083;
		private var coold:int;
		private var dec:Boolean;
		
		public function Elevator(spawnX:int, spawnY:int) 
		{
			x = spawnX;
			y = spawnY;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);	
		}
		
		private function init():void
		{
			var elevator:Image = new Image(Game.assets.getTexture("elevator0000"));
			
			//Elevator Chain
			var elevatorChain:Image = new Image(Game.assets.getTexture("chain0000"));
			elevatorChain.x = elevator.x + elevator.width / 2 - 15;
			elevatorChain.y = elevator.y - 420;
			addChild(elevatorChain);
			
			addChild(elevator);
			
			addEventListener("elevator", moveElevator);	
			removeEventListener(Event.ADDED_TO_STAGE, init);	
		}
		
		private function moveElevator():void
		{
			addEventListener(EnterFrameEvent.ENTER_FRAME, downElevator);
			removeEventListener("elevator", moveElevator);
		}
		
		private function downElevator(e:EnterFrameEvent):void
		{
			y += 2;
			
			if (y >= 30)
			{
				y = 30;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, downElevator);
				addEventListener(EnterFrameEvent.ENTER_FRAME, playerAction);
				parent.broadcastEventWith("elevatorstop");
				if (!Card.withCard)
					Level.player.soundSet.playSound("l_06");
			}
		}
		
		private function playerAction(e:EnterFrameEvent):void 
		{
			var player:Liss = Level.player;
			if (Card.withCard == true && player.myBounds.intersects(new Rectangle(x + width/2, y ,10, 420)))
			{
				parent.dispatchEventWith("bossroom");
				flash = new Quad(stage.stageWidth, stage.stageHeight, 0);
				flash.alpha = 0;
				parent.parent.addChild(flash);
				player.hpBar.removeCard();
				player.disable();
				Card.withCard = false;
				addEventListener(EnterFrameEvent.ENTER_FRAME, enterElevator);
				removeEventListener(EnterFrameEvent.ENTER_FRAME, playerAction);
			}	
		}
		
		private function enterElevator(e:EnterFrameEvent):void
		{
			var player:Liss = Level.player;
			if (!dec)
			{
				if (flash.alpha < 1)
					flash.alpha += rate;
					
				else if (flash.alpha == 1)
				{
					player.x = 9300;
					player.y = 270 - 70;
						
					x = 9250;
					y = 70;
						
					coold = 30;
					dec = true;
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
						player.enable();
						player.soundSet.playSound("l_14");
						removeEventListener(EnterFrameEvent.ENTER_FRAME, enterElevator);
						removeEventListener(EnterFrameEvent.ENTER_FRAME, moveElevator);
						flash.removeFromParent(true);
					}
				}
			}	
		}
		
	}

}