package 
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import gui.IntroVideo;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.AssetManager;
	
	import gui.Intro;
	import utils.DEV;
	import utils.EmbeddedAssets;
	
	import flash.ui.Keyboard;
	
	/**
	 * Recall Game
	 * Contains vital functionality for the game
	 * @author Joao Borks
	 */
	public class Game extends Sprite
	{
		// Game Constants
		public static const GRAVITY:int = 1;
		// Game Variables
		public static var language:String = "en";
		// Game contents
		public static var assets:AssetManager;
		
		// Loading Screen Variables
		[Embed(source = "../assets/graphics/pre.png")]
		private static const Pre:Class;
		
		private var back:Image;
		private var progressBar:Quad;
		
		public function Game() 
		{
			displayLoading();
			loadAssets(start);
		}
		
		// Loads all the assets of the game
		private function loadAssets(onComplete:Function):void
		{
			assets = new AssetManager();
			assets.verbose = false;
			
			assets.enqueue(EmbeddedAssets);
			assets.loadQueue(function(ratio:Number):void {
				progressBar.width = ratio * 400;
				if (ratio == 1) onComplete();
			});
		}
		
		// Displays a Loading Screen
		private function displayLoading():void
		{
			var tex:Texture = Texture.fromEmbeddedAsset(Pre);
			back = new Image(tex);
			addChild(back);
			progressBar = new Quad(1, 20, 0xa6a600);
			progressBar.x = 120;
			progressBar.y = 440;
			addChild(progressBar);
		}
		
		// Draws the Menu screen and begin the Game
		private function start():void
		{
			removeChild(back, true);
			removeChild(progressBar, true);
			if (DEV.enabled)
				addChild(new Level());
			else 
				addChild(new Intro());
		}
	}
}