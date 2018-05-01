package objects 
{
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.geom.Rectangle;
	
	import entities.Liss;
	import utils.DEV;
	
	/**
	 * Creates an invisible form that can be turned to a checkpoint when collided
	 * @author Maycon
	 * Revised by @author Joao Borks
	 */
	public class Checkpoint extends Quad
	{
		private static var id:int = 1;
		// Scren size references
		private var checkPoint:Quad

		public function Checkpoint(spawnX:int, spawnY:int) 
		{   
			super(20, 400, 0xFFFF00);
			x = spawnX; 
			y = spawnY;
			alignPivot("center", "bottom");
			name = "checkpoint" + id++;
			if (DEV.block) alpha = 0.2;
			else visible = false;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event=null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, respawnCheckPoint);
		}
		
		private function respawnCheckPoint(e:EnterFrameEvent):void
		{
			var player:Liss = Level.player;
			if (bounds.intersects(player.myBounds))
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, respawnCheckPoint);
				Level.currentCheck = this;
				parent.dispatchEventWith(name);
			}
		}
		
		public function reset():void 
		{
			addEventListener(EnterFrameEvent.ENTER_FRAME, respawnCheckPoint);
		}
	}

}