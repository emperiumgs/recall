package objects 
{
	import entities.Liss;
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.display.Quad;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.core.Starling;
	
	import utils.DEV;
	
	/**
	 * Carries Tess, and can be forced to crash
	 * @author Joao Borks
	 */
	public class Helicopter extends Sprite
	{
		private var _myBounds:Quad;
		private var cooldown:int;
		private var maxMove:int = 500;
		private var destroyed:Boolean;
		private var heliAnim:MovieClip;
		
		public function Helicopter(spawnX:int, spawnY:int) 
		{
			super();
			// Position
			alignPivot();
			x = spawnX;
			y = spawnY;
			name = "helicopter";
			
			_myBounds = new Quad(300, 180, 0x000088);
			_myBounds.alignPivot();
			_myBounds.x = 50;
			if (DEV.entity)
				_myBounds.alpha = 0.2;
			else
				_myBounds.visible = false;
			
			addChild(_myBounds);
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init():void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Helicopter Animation
			heliAnim = new MovieClip(Game.assets.getTextures("chopper"));
			heliAnim.alignPivot();
			Starling.juggler.add(heliAnim);
			heliAnim.play();
			addChild(heliAnim);
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
			addEventListener("focus", interactToggle);
			addEventListener("unfocus", interactToggle);
			
			cooldown = 180;
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		// Enables interaction
		private function enable():void 
		{
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		// Disables interaction
		private function disable():void
		{
			removeEventListener(TouchEvent.TOUCH, onTouch);
			if (!hasEventListener(EnterFrameEvent.ENTER_FRAME)) addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		// Waits for a time and moves the helicopter
		public function update(e:EnterFrameEvent):void 
		{
			if (cooldown > 0)
				cooldown--;
			if (cooldown == 0)
			{
				x += 5;
				y -= 1;
				maxMove -= 5;
			}
			if (maxMove <= 0)
			{
				var player:Liss = Level.player;
				player.enable(false);
				
				if (destroyed)
				{
					removeChild(getChildAt(2), true);
					rotation -= 0.05
					_myBounds.color = 0xCC00CC;
					_myBounds.x = 0;
					_myBounds.width -= 50;
					_myBounds.height -= 20;
					x = 2800;
					y = 200;
					var crashed:Image = new Image(Game.assets.getTexture("broken_heli0000"));
					crashed.alignPivot();
					addChild(crashed);
					Level.colObjects.push(this);
					parent.broadcastEventWith("helicrash");
					if (Level.loop > 1)
						player.soundSet.playSound("l_10");
				}
				else
				{
					parent.dispatchEventWith("helivanish");
					removeFromParent(true);
				}
				if (!player.hasEventListener(EnterFrameEvent.ENTER_FRAME))
					player.stretchHand(false);
				// Disposes the heli animation
				Starling.juggler.remove(heliAnim);
				removeChild(heliAnim, true);
				heliAnim = null;
				removeEventListener(EnterFrameEvent.ENTER_FRAME, update);
			}
		}
		
		// Event Handler
		private function onTouch(e:TouchEvent):void
		{
			if (e.getTouch(this, TouchPhase.BEGAN))
			{
				destroyed = true;
				removeEventListener(TouchEvent.TOUCH, onTouch);
				removeEventListener("focus", interactToggle);
				removeEventListener("unfocus", interactToggle);
				_myBounds.color = 0xFF0000;
				y += 5;
				rotation += 0.05;
				cooldown = 0;
				var smoke:VFX = new VFX(-30, -180, "smoke", true);
				addChild(smoke);
			}
		}
		
		// Toggles the interactivity in the box
		private function interactToggle(e:Event):void 
		{
			e.type == "focus" ? enable() : disable();
		}
		
		public function get myBounds():Rectangle
		{
			return _myBounds.getBounds(parent);
		}
	}
}