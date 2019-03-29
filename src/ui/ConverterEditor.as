package ui
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import translation.Translator;
	import uiwidgets.IconButton;
	
	/**
	 * ...
	 * @author SteveXMH
	 */
	public class ConverterEditor extends Sprite
	{
		private var checkboxLabels:Array;
		private var base:Shape;
		private var text1:TextField;
		private var text2:TextField;
		private var text3:TextField;
		public var checkboxes:Array;
		public var options:Array = [];
		
		public function ConverterEditor()
		{
			addChild(base = new Shape());
			setWidthHeight(400, 10);
			addChild(text1 = makeLabel("This feature can export your scratch project to a swf flash file.", 14, false));
			addChild(text2 = makeLabel("So you can share this file to other people who aren't have a scratch editor.", 14, false));
			addChild(text3 = makeLabel("WARNING: Still testing! Maybe have problems!", 14, true));
			addCheckboxesAndLabels();
			fixLayout();
		}
		
		private function addCheckboxesAndLabels():void
		{
			checkboxLabels = [
			makeLabel('Full Screen', 14),
			makeLabel('Show Green Flag Bar', 14), 
			makeLabel('Start in Turbo Mode', 14),
			makeLabel('Automatically Start', 14), 
			makeLabel('Show as Editor', 14), 
			makeLabel('Hide Mouse Cursor', 14),];
			
			checkboxes = [new IconButton(null, 'checkbox'), new IconButton(null, 'checkbox'), new IconButton(null, 'checkbox'), new IconButton(null, 'checkbox'), new IconButton(null, 'checkbox'), new IconButton(null, 'checkbox')];
			var c:int = 0;
			for each (var label:TextField in checkboxLabels)
			{
				function toggleCheckbox(e:MouseEvent):void
				{
					var box:IconButton;
					var index:int = checkboxLabels.indexOf(e.currentTarget);
					box = checkboxes[index];
					box.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
				}
				c = c + 1;
				label.addEventListener(MouseEvent.MOUSE_DOWN, toggleCheckbox);
				addChild(label);
			}
			for each (var b:IconButton in checkboxes)
			{
				b.disableMouseover();
				addChild(b);
			}
		}
		
		private function makeLabel(s:String, fontSize:int, bold:Boolean = false):TextField
		{
			var tf:TextField = new TextField();
			tf.selectable = false;
			//tf.embedFonts = true;
			tf.defaultTextFormat = new TextFormat(CSS.font, fontSize, CSS.textColor, bold);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = Translator.map(s);
			addChild(tf);
			return tf;
		}
		
		private function setWidthHeight(w:int, h:int):void
		{
			var g:Graphics = base.graphics;
			g.clear();
			g.beginFill(CSS.white);
			g.drawRect(0, 0, w, h);
			g.endFill();
		}
		
		private function fixLayout():void
		{
			text1.y = 0
			text2.y = text1.height
			text3.y = text2.y + text2.height
			for (var i:int = 0; i < checkboxes.length; i++){
				var b:IconButton = checkboxes[i]
				if (i == 0)
				{
					b.y = text3.y + text3.height + 5
					checkboxLabels[i].y = b.y - 1
					checkboxLabels[i].x = b.width + 5
				}else{
					b.y = checkboxes[i-1].y + checkboxes[i-1].height + 5
					checkboxLabels[i].y = b.y - 1
					checkboxLabels[i].x = b.width + 5
				}
			}
		}
	
	}

}