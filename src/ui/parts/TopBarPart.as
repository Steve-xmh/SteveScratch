/*
 * Scratch Project Editor and Player
 * Copyright (C) 2014 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// TopBarPart.as
// John Maloney, November 2011
//
// This part holds the Scratch Logo, cursor tools, screen mode buttons, and more.

package ui.parts
{
	import adobe.utils.CustomActions;
	import assets.Resources;
	FLASH::isFlash{
	import flash.desktop.NativeApplication;
	}
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import extensions.ExtensionDevManager;
	
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.*;
	
	import translation.Translator;
	
	import uiwidgets.*;
	
	public class TopBarPart extends UIPart
	{
		
		private var shape:Shape;
		protected var logoButton:IconButton;
		protected var languageButton:IconButton;
		
		protected var fileMenu:IconButton;
		protected var editMenu:IconButton;
		protected var helpMenu:IconButton;
		protected var advancedMenu:IconButton;
		
		private var copyTool:IconButton;
		private var cutTool:IconButton;
		private var growTool:IconButton;
		private var shrinkTool:IconButton;
		private var helpTool:IconButton;
		private var toolButtons:Array = [];
		private var toolOnMouseDown:String;
		
		private var offlineNotice:TextField;
		private const offlineNoticeFormat:TextFormat = new TextFormat(CSS.font, 13, CSS.white, true);
		
		private var closeButton:Sprite = new Sprite();//关闭
		private var maxsizeButton:Sprite = new Sprite();//最大化
		private var minsizeButton:Sprite = new Sprite();//最小化
		private var addedEvent:Boolean = false;
		private const chromeButtonsWidth:Number = 64;//每个按钮的宽度
		
		protected var loadExperimentalButton:Button;
		protected var exportButton:Button;
		protected var extensionLabel:TextField;
		
		public function TopBarPart(app:Scratch)
		{
			this.app = app;
			addButtons();
			refresh();
		}
		
		protected function addButtons():void
		{
			addChild(shape = new Shape());
			addChild(logoButton = new IconButton(goToTieba, 'scratchlogo'));
			
			addChild(languageButton = new IconButton(app.setLanguagePressed, 'languageButton'));
			
			languageButton.isMomentary = true;
			addTextButtons();
			addToolButtons();
			
			if (Scratch.app.isExtensionDevMode || Scratch.app.enabledScratchXPlugin)
			{
				if (Scratch.app.isExtensionDevMode) addChild(logoButton = new IconButton(app.logoButtonPressed, Resources.createBmp('scratchxlogo')));
				const desiredButtonHeight:Number = 20;
				if (Scratch.app.isExtensionDevMode) logoButton.scaleX = logoButton.scaleY = 1;
				var scale:Number = desiredButtonHeight / logoButton.height;
				if (Scratch.app.isExtensionDevMode) logoButton.scaleX = logoButton.scaleY = scale;
				
				addChild(exportButton = new Button('Save Project', function():void
				{
					app.exportProjectToFile();
				}));
				addChild(extensionLabel = makeLabel('My Extension', offlineNoticeFormat, 2, 2));
				
				var extensionDevManager:ExtensionDevManager = Scratch.app.extensionManager as ExtensionDevManager;
				if (extensionDevManager)
				{
					addChild(loadExperimentalButton = extensionDevManager.makeLoadExperimentalExtensionButton());
				}
			};
			
/*			FLASH::isFlash{
				if(Scratch.app.stage.nativeWindow != null){
					if (Scratch.app.stage.nativeWindow.systemChrome == NativeWindowSystemChrome.NONE)
					{
						addEventListener(MouseEvent.MOUSE_DOWN, chromeMove);
						
						addChild(closeButton);
						addChild(maxsizeButton);
						addChild(minsizeButton);
						
						addChromeControlButtons();
						
					}
				}
			}*/
		}
		FLASH::isFlash{
		private function addChromeControlButtons(w:int = 0):void
		{
/*			FLASH::isFlash{
				function drawCloseButton(bgColor:uint):void
				{
					var g:Graphics = closeButton.graphics;
					const posY:Number = 28;
					g.clear();
					g.beginFill(bgColor);
					g.drawRect(0, 0, chromeButtonsWidth, posY);
					g.endFill();
					
					g.beginFill(0xFFFFFF);
					g.lineStyle(1, 0xFFFFFF, 1, true, "normal", "none");
					g.moveTo(chromeButtonsWidth / 2 - 5, posY / 2 - 5);
					g.lineTo(chromeButtonsWidth / 2 + 5, posY / 2 + 5);
					g.endFill();
					
					g.beginFill(0xFFFFFF);
					g.moveTo(chromeButtonsWidth / 2 + 5, posY / 2 - 5);
					g.lineTo(chromeButtonsWidth / 2 - 5, posY / 2 + 5);
					g.endFill();
				}
				
				function drawMaxsizeButton(bgColor:uint):void
				{
				
				}
				
				function drawMinsizeButton(bgColor:uint):void
				{
				
				}
				
				drawCloseButton(0x101010);
				
				if (!addedEvent)
				{
					closeButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent)
					{
						if (NativeWindow.isSupported && NativeApplication.nativeApplication)
						{
							if (Scratch.app.stage.nativeWindow.dispatchEvent(new Event(Event.CLOSING,false,true))){
								NativeApplication.nativeApplication.exit();
							}
						}
					
					});
					addedEvent = true;
				}
				fixChromeButtonsLayout(w);
			};*/
		}
		
		private function fixChromeButtonsLayout(w:int = 0):void
		{
			
			closeButton.x = w - chromeButtonsWidth;
			closeButton.y = 0;
			maxsizeButton.x = w - chromeButtonsWidth * 2;
			maxsizeButton.y = 0;
			minsizeButton.x = w - chromeButtonsWidth * 3;
			minsizeButton.y = 0;
			trace(w);
		}
		
		private function chromeMove(e:MouseEvent):void
		{
/*			if (!Scratch.app.stage.nativeWindow.startMove())
			{
				Scratch.app.stage.nativeWindow.restore();
				Scratch.app.stage.nativeWindow.startMove();
			}*/
		}
		
		}
		
		private function goToTieba(b:IconButton):void
		{
			navigateToURL(new URLRequest("http://tieba.baidu.com/p/5953021529"));
		}
		
		public static function strings():Array
		{
			if (Scratch.app)
			{
				Scratch.app.showFileMenu(Menu.dummyButton());
				Scratch.app.showEditMenu(Menu.dummyButton());
				Scratch.app.showHelpMenu(Menu.dummyButton());
			}
			return ['File', 'Edit', 'Tips', 'Duplicate', 'Delete', 'Grow', 'Shrink', 'Block help', 'Offline Editor'];
		}
		
		protected function removeTextButtons():void
		{
			if (fileMenu.parent)
			{
				removeChild(fileMenu);
				removeChild(editMenu);
				removeChild(helpMenu);
				removeChild(advancedMenu);
			}
		}
		
		public function updateTranslation():void
		{
			removeTextButtons();
			addTextButtons();
			if (offlineNotice) offlineNotice.text = Translator.map('Offline Editor');
			refresh();
		}
		
		public function setWidthHeight(w:int, h:int):void
		{
			this.w = w;
			this.h = h;
			var g:Graphics = shape.graphics;
			g.clear();
			g.beginFill(CSS.topBarColor());
			g.drawRect(0, 0, w, h);
			g.endFill();
			fixLayout();
			FLASH::isFlash{
			fixChromeButtonsLayout(w);
		}
		
		}
		
		protected function fixLogoLayout():int
		{
			var nextX:int = 9;
			if (logoButton)
			{
				logoButton.x = nextX;
				logoButton.y = 5;
				nextX += logoButton.width + buttonSpace;
			}
			return nextX;
		}
		
		protected const buttonSpace:int = 12;
		
		protected function fixLayout():void
		{
			const buttonY:int = 5;
			
			var nextX:int = fixLogoLayout();
			
			languageButton.x = nextX;
			languageButton.y = buttonY - 1;
			nextX += languageButton.width + buttonSpace;
			
			// new/more/tips buttons//修正菜单按钮位置
			fileMenu.x = nextX;
			fileMenu.y = buttonY;
			nextX += fileMenu.width + buttonSpace;
			
			editMenu.x = nextX;
			editMenu.y = buttonY;
			nextX += editMenu.width + buttonSpace;
			
			advancedMenu.x = nextX;
			advancedMenu.y = buttonY;
			nextX += advancedMenu.width + buttonSpace;
			
			helpMenu.x = nextX;
			helpMenu.y = buttonY;
			nextX += helpMenu.width + buttonSpace;
			
			// cursor tool buttons
			var space:int = 3;
			copyTool.x = app.isOffline ? 493 : 427;
			cutTool.x = copyTool.right() + space;
			growTool.x = cutTool.right() + space;
			shrinkTool.x = growTool.right() + space;
			helpTool.x = shrinkTool.right() + space;
			copyTool.y = cutTool.y = shrinkTool.y = growTool.y = helpTool.y = buttonY - 3;
			
			if (offlineNotice)
			{
				offlineNotice.x = w - offlineNotice.width - 5;
				offlineNotice.y = 5;
			}
			
			// From here down, nextX is the next item's right edge and decreases after each item
			nextX = w - 5;
			
			if (loadExperimentalButton)
			{
				loadExperimentalButton.x = nextX - loadExperimentalButton.width;
				loadExperimentalButton.y = h + 5;
					// Don't upload nextX: we overlap with other items. At most one set should show at a time.
			}
			
			if (exportButton)
			{
				exportButton.x = nextX - exportButton.width;
				exportButton.y = h + 5;
				nextX = exportButton.x - 5;
			}
			
			if (extensionLabel)
			{
				extensionLabel.x = nextX - extensionLabel.width;
				extensionLabel.y = h + 5;
				nextX = extensionLabel.x - 5;
			}
			FLASH::isFlash{
			fixChromeButtonsLayout(Scratch.app.stage ? Scratch.app.stage.width : 0);
			}
		}
		
		public function refresh():void
		{
			if (app.isOffline)
			{
				helpTool.visible = app.isOffline;
			}
			
			if (Scratch.app.isExtensionDevMode || Scratch.app.enabledScratchXPlugin)
			{
				var hasExperimental:Boolean = app.extensionManager.hasExperimentalExtensions();
				exportButton.visible = hasExperimental;
				extensionLabel.visible = hasExperimental;
				loadExperimentalButton.visible = !hasExperimental;
				
				var extensionDevManager:ExtensionDevManager = app.extensionManager as ExtensionDevManager;
				if (extensionDevManager)
				{
					extensionLabel.text = extensionDevManager.getExperimentalExtensionNames().join(', ');
				}
			}
			fixLayout();
			
		}
		
		protected function addTextButtons():void
		{
			//addChild(fileMenu = makeMenuButton('File', app.showFileMenu, true));
			addChild(fileMenu = makeMenuButton('File', app.showFileMenu, true));
			addChild(editMenu = makeMenuButton('Edit', app.showEditMenu, true));
			addChild(advancedMenu = makeMenuButton('Advanced', app.showAdvancedMenu, true));
			addChild(helpMenu = makeMenuButton('Help', app.showHelpMenu, true));
		}
		
		private function addToolButtons():void
		{
			function selectTool(b:IconButton):void
			{
				var newTool:String = '';
				if (b == copyTool) newTool = 'copy';
				if (b == cutTool) newTool = 'cut';
				if (b == growTool) newTool = 'grow';
				if (b == shrinkTool) newTool = 'shrink';
				if (b == helpTool) newTool = 'help';
				if (newTool == toolOnMouseDown)
				{
					clearToolButtons();
					CursorTool.setTool(null);
				}
				else
				{
					clearToolButtonsExcept(b);
					CursorTool.setTool(newTool);
				}
			}
			
			toolButtons.push(copyTool = makeToolButton('copyTool', selectTool));
			toolButtons.push(cutTool = makeToolButton('cutTool', selectTool));
			toolButtons.push(growTool = makeToolButton('growTool', selectTool));
			toolButtons.push(shrinkTool = makeToolButton('shrinkTool', selectTool));
			toolButtons.push(helpTool = makeToolButton('helpTool', selectTool));
			if (!app.isMicroworld)
			{
				for each (var b:IconButton in toolButtons)
				{
					addChild(b);
				}
			}
			SimpleTooltips.add(copyTool, {text: 'Duplicate', direction: 'bottom'});
			SimpleTooltips.add(cutTool, {text: 'Delete', direction: 'bottom'});
			SimpleTooltips.add(growTool, {text: 'Grow', direction: 'bottom'});
			SimpleTooltips.add(shrinkTool, {text: 'Shrink', direction: 'bottom'});
			SimpleTooltips.add(helpTool, {text: 'Block help', direction: 'bottom'});
		}
		
		public function clearToolButtons():void
		{
			clearToolButtonsExcept(null)
		}
		
		private function clearToolButtonsExcept(activeButton:IconButton):void
		{
			for each (var b:IconButton in toolButtons)
			{
				if (b != activeButton) b.turnOff();
			}
		}
		
		private function makeToolButton(iconName:String, fcn:Function):IconButton
		{
			function mouseDown(evt:MouseEvent):void
			{
				toolOnMouseDown = CursorTool.tool
			}
			
			var onImage:Sprite = toolButtonImage(iconName, CSS.overColor, 1);
			var offImage:Sprite = toolButtonImage(iconName, 0, 0);
			var b:IconButton = new IconButton(fcn, onImage, offImage);
			b.actOnMouseUp();
			b.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown); // capture tool on mouse down to support deselecting
			return b;
		}
		
		private function toolButtonImage(iconName:String, color:int, alpha:Number):Sprite
		{
			const w:int = 23;
			const h:int = 24;
			var img:Bitmap;
			var result:Sprite = new Sprite();
			var g:Graphics = result.graphics;
			g.clear();
			g.beginFill(color, alpha);
			g.drawRoundRect(0, 0, w, h, 8, 8);
			g.endFill();
			result.addChild(img = Resources.createBmp(iconName));
			img.x = Math.floor((w - img.width) / 2);
			img.y = Math.floor((h - img.height) / 2);
			return result;
		}
		
		protected function makeButtonImg(s:String, c:int, isOn:Boolean):Sprite
		{
			var result:Sprite = new Sprite();
			
			var label:TextField = makeLabel(Translator.map(s), CSS.topBarButtonFormat, 2, 2);
			label.textColor = CSS.white;
			label.x = 6;
			result.addChild(label); // label disabled for now
			
			var w:int = label.textWidth + 16;
			var h:int = 22;
			var g:Graphics = result.graphics;
			g.clear();
			g.beginFill(c);
			g.drawRoundRect(0, 0, w, h, 8, 8);
			g.endFill();
			
			return result;
		}
	}
}
