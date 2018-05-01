package utils 
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Dictionary;
	import gui.Subtitle;
	import starling.core.Starling;
	
	/**
	 * Class to automatize sound management
	 * @author Joao Borks
	 */
	public class SoundSet
	{
		public var sounds:Dictionary = new Dictionary();
		private var _currentSound:Sound;
		public var channel:SoundChannel;
		private var time:Number;
		private var subtitle:Subtitle;
		
		public function SoundSet(soundPref:String = "") 
		{
			if (soundPref) 
			{
				var list:Vector.<String> = Game.assets.getSoundNames(soundPref);
				list.forEach(function(item:String, index:int, vector:Vector.<String>):void
				{
					sounds[item] = Game.assets.getSound(item);
				})
			}
		}
		
		// Adds the specified sound to the sound set
		public function addSound(soundName:String):void
		{
			sounds[soundName] = Game.assets.getSound(soundName);
		}
		
		// Plays the specified sound
		public function playSound(soundName:String, startTime:Number = 0, loops:int = 0):void 
		{
			_currentSound = sounds[soundName];
			channel = sounds[soundName].play(startTime, loops);
			
			if (Game.assets.getObject(Game.language + "_" + soundName))
			{
				subtitle = new Subtitle(channel, Game.language + "_" + soundName);
				Starling.current.nativeStage.addChild(subtitle);
			}
		}
		
		// Destroys all references
		public function destroy():void 
		{
			sounds = null;
		}
		
		// Returns the current sound playing
		public function get currentSound():Sound 
		{
			return _currentSound;
		}
	}
}