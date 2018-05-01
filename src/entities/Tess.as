package entities 
{
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import utils.AnimationSet;
	
	/**
	 * Tess is a character for animation purposes only
	 * @author Joao Borks
	 */
	public class Tess extends Sprite
	{
		private static const SPEED:int = 5;
		public var animSet:AnimationSet;
		private var myBounds:Quad;
		private var faceAhead:Boolean;
		
		public function Tess(posX:int, posY:int, faceBack:Boolean = true) 
		{
			// Position
			alignPivot("center", "bottom");
			x = posX;
			y = posY;
			name = "Tess";
			faceAhead = !faceBack;
			
			animSet = new AnimationSet("tess_");
			addChild(animSet);
			animSet.playAnim("tess_drag");
			animSet.currentAnim.stop();
			
			myBounds = new Quad(50, 105, 0x000088);
			myBounds.alignPivot("center", "bottom");
			addChild(myBounds);
			myBounds.visible = false;
		}
		
		// Dragged by her sis
		public function draggedTo(destinyX:int, onComplete:Function=null):void 
		{
			// play dragged animation
			animSet.currentAnim.play();
			addEventListener(EnterFrameEvent.ENTER_FRAME, function ():void 
			{
				if (destinyX > x)
				{
					x += SPEED;
					if (x > destinyX)
						x = destinyX;
				}
				else if (destinyX < x)
				{
					x -= SPEED;
					if (x < destinyX)
						x = destinyX;
				}
				else
				{
					removeEventListeners(EnterFrameEvent.ENTER_FRAME);
					if (onComplete != null)
						onComplete();
				}
			});
		}
		
		// Moves to another place
		public function moveTo(destinyX:int, faceForward:Boolean, onComplete:Function = null):void
		{
			animSet.currentAnim.currentFrame = 1;
			animSet.currentAnim.stop();
			addEventListener(EnterFrameEvent.ENTER_FRAME, function():void
				{
					if (destinyX > x)
					{
						if (!faceAhead)
							faceAhead = true;
						x += SPEED;
						if (x > destinyX)
							x = destinyX;
					}
					else if (destinyX < x)
					{
						if (faceAhead)
							faceAhead = false;
						x -= SPEED;
						if (x < destinyX)
							x = destinyX;
					}
					else
					{
						faceAhead = faceForward;
						removeEventListeners(EnterFrameEvent.ENTER_FRAME);
						if (onComplete != null)
							onComplete();
					}
					
					// Direction facing
					if (!faceAhead && scaleX != -1)
						scaleX = -1;
					else if (faceAhead && scaleX != 1)
						scaleX = 1;
				}
			);
		}
	}
}