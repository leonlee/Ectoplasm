package ectoplasm.systems.game
{
	import flash.utils.Dictionary;
	
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	
	import ectoplasm.common.GameConfig;
	import ectoplasm.nodes.game.CameraNode;
	import ectoplasm.nodes.game.GameNode;
	import ectoplasm.nodes.game.RenderNode;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	
	public class RenderSystem extends System
	{
		[Inject] public var engine : Engine;
		[Inject] public var config : GameConfig;
		
		private var container : Sprite;		
		private var nodes : NodeList;
		private var cameras : NodeList;
		
		public static var map : Dictionary;
		
		public function RenderSystem(container:Sprite)
		{
			this.container = container;
			map = new Dictionary(true);
		}
		
		override public function addToEngine( engine : Engine ) : void
		{
			nodes = engine.getNodeList( RenderNode );
			cameras = engine.getNodeList( CameraNode );
			for( var node : RenderNode = nodes.head; node; node = node.next )
			{
				addToDisplay( node );
			}
			nodes.nodeAdded.add( addToDisplay );
			nodes.nodeRemoved.add( removeFromDisplay );
		}
		
		private function addToDisplay( node : RenderNode ) : void
		{
			map[node.display.container] = node;
			container.addChild( node.display.container );
		}
		
		private function removeFromDisplay( node : RenderNode ) : void
		{
			map[node.display.container] = null;
			container.removeChild( node.display.container );
		}
		
		override public function update( time : Number ) : void
		{
			var cam : CameraNode = engine.getNodeList( CameraNode ).head;
			var game : GameNode = engine.getNodeList( GameNode ).head;
			if(!cam || !game) return;
			
			container.sortChildren(sort);
			//container.scaleX = container.scaleY = 0.5;
			//container.x = 300;
			//container.y = 200;
			
			if(config.renderLayerBlurAmount<=0) container.filter = null;
			else setFilter(config.renderLayerBlurAmount);
			
			
			for( var node : RenderNode = nodes.head; node; node = node.next )
			{
				node.display.container.x = node.position.position.x - cam.position.position.x * node.position.position.z;
				node.display.container.y = node.position.position.y - cam.position.position.y;
			}
		}	
		
		private function setFilter(renderLayerBlurAmount:Number):void
		{
			var bf : BlurFilter = container.filter as BlurFilter;
			if(!bf)
			{
				// Calculating the correct resolution for this filer, important because
				// the filter creates a render texture the size of the rendering container 
				// and we cant have textures that are too big
				var rw : Number = Math.min(512/Starling.current.viewPort.width,1);
				var rh : Number = Math.min(512/Starling.current.viewPort.height,1);
				var r : Number = Math.min(rw,rh);
				bf = new BlurFilter(1,1,r);
				container.filter = bf;
			}
			bf.blurX = bf.blurY = renderLayerBlurAmount;
		}
		
		private function sort(a:DisplayObject,b:DisplayObject):int
		{
			var na : RenderNode = map[a];
			var nb : RenderNode = map[b];
			var n : Number = na.display.depth-nb.display.depth;
			return n>0?1:-1;
		}
	}
}