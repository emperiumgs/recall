package utils
{
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.events.Event;
	
	/**
	 * Class to automatize movie clip atribuitions
	 * @author Joao Borks
	 */
	public class AnimationSet extends Sprite
	{
		public var animations:Vector.<MovieClip> = new Vector.<MovieClip>; // Contains the animations to create
		public var currentAnim:MovieClip; // The current Movie Clip playing
		private var _hAlign:String;
		private var _vAlign:String;
		
		// Leave null if will be adding animations manually
		public function AnimationSet(animPrefix:String = "", hAlign:String = "center", vAlign:String = "bottom")
		{
			alignPivot(hAlign, vAlign);
			_hAlign = hAlign;
			_vAlign = vAlign;
			
			if (animPrefix)
			{
				// Get animation list
				var allList:Vector.<String> = Game.assets.getTextureNames(animPrefix);
				// Create a temporary list
				var animList:Vector.<String> = new Vector.<String>;
				// Take the numbers out of the strings and do the logic
				var i:int;
				var subStr:String;
				for each (var string:String in allList)
				{
					i = string.search("0");
					subStr = string.substr(0, i);
					if (animList.indexOf(subStr) == -1)
					{
						animList.push(subStr);
						addAnim(subStr);
					}
				}
			}
		}
		
		// The name MUST be equal to the animation name on the atlas texture
		public function addAnim(name:String, frameRate:int = 24):void
		{
			var animation:MovieClip = new MovieClip(Game.assets.getTextures(name), frameRate);
			animation.name = name;
			animation.alignPivot(_hAlign, _vAlign);
			animation.smoothing = "none";
			Starling.juggler.add(animation);
			animations.push(animation);
			addChild(animation);
		}
		
		// Play a determined animation
		public function playAnim(animToPlay:String, loop:Boolean = false):void
		{
			animations.forEach(function(item:MovieClip, index:int, vector:Vector.<MovieClip>):void
			{
				if (item.name == animToPlay)
				{
					item.visible = true;
					if (!loop) item.loop = false;
					if (currentAnim != item)
					{
						item.currentFrame = 0;
						currentAnim = item;
					}
					if (item.isComplete) item.pause();
					else item.play();
				}
				else item.visible = false;
			});
		}
		
		// Clear the starling juggler and destroy this element and its child
		public function destroy():void
		{
			var animation:MovieClip;
			for (var i:int = animations.length - 1; i >= 0; i--)
			{
				animation = animations[i];
				Starling.juggler.remove(animation);
				animations.pop();
			}
			removeFromParent(true);
		}
	}
}