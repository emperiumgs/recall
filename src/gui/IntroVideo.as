package gui 
{
	import flash.events.AsyncErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.VideoEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.ImageDecodingPolicy;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import starling.display.Image;
	
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	
	public class IntroVideo extends Sprite
	{
		
		//variáveis de vídeo
		private var video:Video;
		private var videoName:String;
		private var ns:NetStream;
		private var bg:Quad;
		private var subtitle:Subtitle;
		
		public function IntroVideo()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,init);
			
			//inicia o vídeo
			video =  new Video(640, 480);
			
			//inclui o vídeo do native stage (o do flash "normal")
			Starling.current.nativeStage.addChild(video);
			
			end();
		}
		
		public function start():void{
			this.visible = true;
			video.visible = true;
			playVideo();
			stage.addEventListener(KeyboardEvent.KEY_DOWN,kDown);
		}
		
		public function end():void{
			this.visible = false;
			video.visible = false;
			if (subtitle)
				subtitle.end();
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,kDown);
		}
		
		private function kDown(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.SPACE){
				ns.close();
				end();
				instructions();
			}
		}
		
		private function playVideo():void
		{	
			//inicia conexão de vídeo
			var nc:NetConnection = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS , onConnect);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR , trace);
			
			nc.connect(null);
		}
		
		//quando mudar o status para empty. Termina o vídeo e chama para a outra tela
		private function onStatus(e:NetStatusEvent):void
		{
			trace(e.info.code);
			if (e.info.code == 'NetStream.Buffer.Empty') {
				ns.close();
				end();
				instructions();
			}
		}
		
		//quando conectar, inicia o vídeo
		private function onConnect(e:NetStatusEvent):void {
			if (e.info.code == 'NetConnection.Connect.Success') {
				trace(e.target as NetConnection);
				
				ns = new NetStream(e.target as NetConnection);
				
				ns.client = {};
				var file:ByteArray = Game.assets.getByteArray("introvid");
				
				ns.play(null);
				
				ns.appendBytes(file);
				video.attachNetStream(ns);
				
				if (Game.language == "en")
				{
					subtitle = new Subtitle(ns, "en_intro");
					Starling.current.nativeStage.addChild(subtitle);
				}
				
				ns.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
			}
		}
		
		private function instructions():void 
		{
			video.parent.removeChild(video);
			video = null;
			
			var image:Image = new Image(Game.assets.getTexture(Game.language + "_inst"));
			parent.addChild(image);
			
			addEventListener(KeyboardEvent.KEY_DOWN, function ():void
			{
				image.removeFromParent(true);
				image = null;
				
				parent.addChild(new Level());
				removeFromParent(true);
				removeEventListeners(KeyboardEvent.KEY_DOWN);
			});
		}
	}
}