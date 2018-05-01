package utils 
{
	import entities.Liss;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.text.TextField;
	
	/**
	 * Useful for displaying tutorial messages on the screen
	 * @author Joao Borks
	 */
	public class TextTrigger extends Quad
	{
		private var message:TextField;
		private var cooldown:int;
		
		public function TextTrigger(posX:int, posY:int, text:String) 
		{
			super(20, 350, 0xFFFF00);
			// Position
			alignPivot("center", "bottom");
			x = posX;
			y = posY;
			if (DEV.block)
				alpha = 0.2;
			else
				visible = false;
			
			message = new TextField(500, 120, text, "Verdana", 24, 0xffffff, true);
			message.alignPivot();
			message.x = 320;
			message.y = 80;
			addEventListener(EnterFrameEvent.ENTER_FRAME, onPlayerBump)
		}
		
		private function onPlayerBump():void 
		{
			var player:Liss = Level.player;
			if (bounds.intersects(player.myBounds))
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onPlayerBump);
				parent.parent.addChild(message);
				cooldown = 180;
				addEventListener(EnterFrameEvent.ENTER_FRAME, onCooldown);
			}
		}
		
		private function onCooldown():void
		{
			if (cooldown > 0)
				cooldown --;
			else
			{
				message.removeFromParent(true);
				removeFromParent(true);
			}
		}
	}
}