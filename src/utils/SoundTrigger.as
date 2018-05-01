package utils 
{
	import entities.Liss;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	
	/**
	 * Triggers a sound when the player collides, and then vanishes
	 * @author Joao Borks
	 */
	public class SoundTrigger extends Quad
	{
		private var sound:String;
		
		public function SoundTrigger(posX:int, posY:int, soundToTrigger:String) 
		{
			super(20, 350, 0xFF00FF);
			// Position
			alignPivot("center", "bottom");
			x = posX;
			y = posY;
			if (DEV.block)
				alpha = 0.2;
			else
				visible = false;
			
			sound = soundToTrigger;
			addEventListener(EnterFrameEvent.ENTER_FRAME, onPlayerHit);
		}
		
		// Executes a sound when the player hits this trigger
		private function onPlayerHit(e:EnterFrameEvent):void 
		{
			var player:Liss = Level.player;
			if (bounds.intersects(player.myBounds))
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onPlayerHit);
				addEventListener(EnterFrameEvent.ENTER_FRAME, onPlaying);
				player.soundSet.playSound(sound);
			}
		}
		
		// Deletes itself when the sound has finished reproducing
		private function onPlaying(e:EnterFrameEvent):void 
		{
			if (Level.player.soundSet.channel.position >= Level.player.soundSet.currentSound.length - 30)
			{
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onPlaying);
				removeFromParent(true);
			}
		}
	}
}