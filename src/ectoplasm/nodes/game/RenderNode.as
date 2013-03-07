package ectoplasm.nodes.game
{
	import ash.core.Node;
	
	import ectoplasm.components.game.Display;
	import ectoplasm.components.game.Position;
	
	public class RenderNode extends Node
	{
		public var position : Position;
		public var display : Display;
	}
}