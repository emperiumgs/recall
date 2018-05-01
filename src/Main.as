package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Mouse;
	import starling.core.Starling;
	
	/**
	 * Recall
	 * @author Joao Borks
	 */
	public class Main extends Sprite
	{
		private var mStarling:Starling;
		
		public function Main()
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Mouse.hide();
			
			// Starling Init
			Starling.handleLostContext = true;
			
			mStarling = new Starling(Game, stage, null, null, "auto", "auto");
			// mStarling.showStats = true;
			mStarling.start();
		}
	}
}