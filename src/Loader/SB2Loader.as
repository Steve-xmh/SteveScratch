// replaces Scratch as the main class
// applies the settings and automatically loads the project

package Loader
{
	import flash.display.*;
	import flash.events.InvokeEvent;
	import flash.desktop.NativeApplication;
	import flash.utils.*;
	import translation.Translator;
	import ui.parts.*;
	import flash.ui.*;
	import util.Server;
	
	public class SB2Loader extends Scratch
	{
		// settings byte offsets
		private static const SETTING_FULLSCREEN:int=0;
		private static const SETTING_GREEN_FLAG_BAR:int=1;
		private static const SETTING_TURBO_MODE:int=2;
		private static const SETTING_AUTO_START:int=3;
		private static const SETTING_EDIT_MODE:int=4;
		private static const SETTING_HIDE_CURSOR:int=5;
		
		// settings string characters
		private static const CHAR_0:int=48;
		private static const CHAR_1:int=49;
		
		// embedded resource files
		[Embed(source="Project.sb2", mimeType="application/octet-stream")]
		private static const Project:Class;
		[Embed(source="Settings.txt", mimeType="application/octet-stream")]
		private static const Settings:Class;
		private var settings:ByteArray=new Settings() as ByteArray;
		
		public function SB2Loader():void
		{
			isLoader = true;
			
			server = new Server()
			server.getSelectedLang(Translator.setLanguageValue);
			
			if(!getSetting(SETTING_GREEN_FLAG_BAR))
			{
				// TODO: allow choosing?
				stage.color=0x000000;
			}
			
			// TODO: sloppy
			// keep hiding the mouse cursor in case it reappears
			if(getSetting(SETTING_HIDE_CURSOR))
			{
				setInterval(hideCursor,20);
				function hideCursor():void
				{
					Mouse.hide();
				}
			}
			
			// set edit mode
			setEditMode(getSetting(SETTING_EDIT_MODE));
			
			// try to go fullscreen
			if(getSetting(SETTING_FULLSCREEN))
			{
				try
				{
				
					stage.displayState=StageDisplayState.FULL_SCREEN_INTERACTIVE;
				}
				catch(error:*)
				{
					// couldn't go fullscreen
					// seems to happen in the browser sometimes
				}
			}
			
			// remove extra context menu items
			var contextMenuFixed:ContextMenu=new ContextMenu();
			contextMenuFixed.hideBuiltInItems();
			contextMenu=contextMenuFixed;
			
			// set autostart
			autostart=getSetting(SETTING_AUTO_START);
			
			// don't try to connect to the server
			// TODO: check if this is necessary
			isOffline = true;
			
			// set turbo mode
			interp.turboMode=(getSetting(SETTING_TURBO_MODE));
			
			// update the stage UI readouts
			// TODO: only necessary in show green flag mode?
			stagePart.refresh();
			
			// install the project file
			runtime.installProjectFromFile("",new Project() as ByteArray);
		}
		
		// replace the default StagePart if hiding green flag bar
		protected override function getStagePart():StagePart
		{
			// set whether the green flag bar is visible
			if(!getSetting(SETTING_GREEN_FLAG_BAR))
			{
				return new SPOverride();
			}
			else
			{
				return new StagePart(app);
			}
		}
		
		// prevent attempted communication with page
		// TODO: is this necessary?
		protected override function determineJSAccess():void
		{
			jsEnabled=false;
			initialize();
		}
		
		// fix the layout if the green flag bar is hidden
		protected override function updateLayout(width:int,height:int):void
		{
			// run normally
			super.updateLayout(width,height);
			
			// green flag bar is hidden
			if(!getSetting(SETTING_GREEN_FLAG_BAR))
			{
				// center StagePart
				stagePart.x=(stage.stageWidth-stagePart.width)/2;
				stagePart.y=(stage.stageHeight-stagePart.height)/2;
				
				// move ScratchStage to top left corner of StagePart
				stagePane.x=0;
			    stagePane.y=0;
			}
		}
		
		// get settings from the settings ByteArray
		private function getSetting(index:int):Boolean
		{
			return settings[index]==CHAR_1;
		}
	}
}
