package objects  
{
	import flash.geom.Rectangle;
	import starling.display.Quad;
	
	import utils.DEV
	
	/**
	 * Block
	 * A collidable invisible object. Can be a platform.
	 * For testing purposes it will be visible in the green color
	 * @author Joao Borks
	 */
	public class Block extends Quad
	{
		public function Block(posX:int, posY:int, bWidth:int, bHeight:int, isPlatform:Boolean=false) 
		{
			super(bWidth, bHeight, 0x008800);
			x = posX;
			y = posY;
			if (isPlatform) name = "platform";
			else name = "block";
			if (DEV.block) alpha = 0.2;
			else visible = false;
			
			Level.colObjects.push(this);
		}
		
		public function get myBounds():Rectangle 
		{
			return bounds;
		}
	}
}