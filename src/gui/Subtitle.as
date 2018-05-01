package gui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.net.NetStream;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import starling.core.Starling;
	
	/**
	 * Displays subtitle on the native flash stage, acoording to the
	 * given object's time
	 * @param name subtitle to proceed.
	 * @param reference object reference containing time.
	 * @author Joao Borks
	 */
	public class Subtitle extends Sprite
	{
		private var sub:Array;
		private var text:TextField;
		private var ref:*;
		// Reference variables
		private var currentTime:int;
		private var currentSub:int = -1; // For index
		private var nextSub:int; // For miliseconds
		
		public function Subtitle(reference:*, name:String)
		{
			super();
			x = 120;
			y = 400;
			
			ref = reference
			sub = Game.assets.getObject(name).sub;
			
			text = new TextField();
			this.addChild(text);
			text.width = 400;
			text.height = 50;
			text.defaultTextFormat = new TextFormat("Verdana", 18, 0xFFFF00, false, true, null, null, null, TextFormatAlign.CENTER);
			
			// Get first subtitle
			if (sub[0][0] != 0)
				nextSub = sub[0][0];
			else
			{
				currentSub++;
				text.text = sub[currentSub][1];
				if (currentSub + 2 <= sub.length)
					nextSub = sub[currentSub + 1][0];
			}
			
			this.addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function onFrame(e:Event):void 
		{	
			if (ref is NetStream)
			{
				currentTime = ref.time * 1000; // To count in miliseconds
			}
			else if (ref is SoundChannel)
			{
				currentTime = ref.position;
			}
			else
				throw new Error("Invalid Object Reference. Expecting a NetStream (for videos) or SoundChannel (for audio)");
			
			// Update subtitles in their respective time
			if (currentTime >= nextSub)
			{
				currentSub++;
				if (currentSub + 2 <= sub.length)
				{
					nextSub = sub[currentSub + 1][0];
					text.text = sub[currentSub][1];
				}
				else
					end();
			}
		}
		
		public function end():void 
		{
			this.removeEventListener(Event.ENTER_FRAME, onFrame);
			text.parent.removeChild(text);
			//text = null;
			parent.removeChild(this);
		}
	}
}