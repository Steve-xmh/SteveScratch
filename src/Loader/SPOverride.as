// used in place of StagePart when the Green Flag bar is hidden

package Loader
{
	import scratch.*;
	import ui.parts.*;
	import flash.display.*;
	
	public class SPOverride extends StagePart
	{
		// allow adding children?
		private var allowAdd:Boolean;
		
		public function SPOverride():void
		{
			// don't add anything at this time
			allowAdd=false;
			
			// start normally
			super(Scratch.app);
		}
		
		// only allow adding elements sometimes
		public override function addChild(child:DisplayObject):DisplayObject
		{
			// add this element
			if(allowAdd)
			{
				super.addChild(child);
			}
			
			// this function is supposed to return the child that was added
			return(child);
		}
		
		// remove top bar
		public override function computeTopBarHeight():int
		{
			return 0;
		}
		
		// fill the window completely
		public override function setWidthHeight(ignoredWidth:int,ignoredHeight:int,ignoredScale:Number):void
		{
			// set dimensions based on minimum
			var newHeight:Number=Math.min(stage.stageHeight,stage.stageWidth*3/4);
			var newWidth:Number=newHeight*4/3;
			
			// set scale factor
			var newScale:Number=newHeight/360;
			
			// run normally after fixing parameters
			super.setWidthHeight(newWidth,newHeight,newScale);
		}
		
		// install the stage
		public override function installStage(newStage:ScratchStage,showStartButton:Boolean):void
		{
			// run the function normally
			// allow adding children during this
			allowAdd=true;
			super.installStage(newStage,showStartButton);
			allowAdd=false;
			
			// fix the 1px white bar on the left side
			app.stagePane.x=0;
			
			// fix play button position
			// TODO: sloppy way of finding it
			getChildAt(numChildren-1).x=0;
		}
	}
}
