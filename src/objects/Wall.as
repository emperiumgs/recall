package objects 
{
	import flash.geom.Rectangle;
	import starling.display.Image;
	import starling.textures.Texture;
	
	import utils.DEV;
	
	/**
	 * Same as the block, but with an Image of a wall
	 * @author Joao Borks
	 */
	public class Wall extends Image
	{
		public function Wall(posX:int, posY:int, bossWall:Boolean = false) 
		{
			var texture:Texture;
			bossWall ? texture = Game.assets.getTexture("wall_boss0000") : texture = Game.assets.getTexture("wall0000");
			super(texture);
			name = "wall";
			
			x = posX;
			y = posY;
				
			Level.colObjects.push(this);
		}
		
		public function get myBounds():Rectangle 
		{
			return bounds;
		}
	}
}