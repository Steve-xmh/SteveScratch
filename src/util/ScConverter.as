package util
{
	import com.adobe.utils.StringUtil;
	import flash.display.Sprite;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import scratch.ScratchObj;
	import ui.ConverterEditor;
	import uiwidgets.DialogBox;
	import uiwidgets.IconButton;
	
	/**
	 * 用于导出成swf
	 * @author SteveXMH
	 */
	public class ScConverter
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
		
		// SWF projector parts
		[Embed(source = "PartHeader.bin", mimeType = "application/octet-stream")]
		private static const PartHeader:Class;
		[Embed(source = "PartChunkBefore.bin", mimeType = "application/octet-stream")]
		private static const PartChunkBefore:Class;
		[Embed(source = "PartSB2Header.bin", mimeType = "application/octet-stream")]
		private static const PartSB2Header:Class;
		[Embed(source = "PartChunkBetween.bin", mimeType = "application/octet-stream")]
		private static const PartChunkBetween:Class;
		[Embed(source = "PartChunkAfter.bin", mimeType = "application/octet-stream")]
		private static const PartChunkAfter:Class;
		[Embed(source = "Order.bin", mimeType = "application/octet-stream")]
		private static const Order:Class;
		
		private static var settingFrame:ConverterEditor = new ConverterEditor();
		
		public function ScConverter()
		{
		
		}
		
		public function open():void
		{
			function startConvert():void
			{
				var fullScreen:Boolean	 = settingFrame.checkboxes[0].isOn()
				var greenFlagBar:Boolean = settingFrame.checkboxes[1].isOn()
				var turboMode:Boolean	 = settingFrame.checkboxes[2].isOn()
				var autoStart:Boolean	 = settingFrame.checkboxes[3].isOn()
				var asEditor:Boolean	 = settingFrame.checkboxes[4].isOn()
				var hideCursor:Boolean	 = settingFrame.checkboxes[5].isOn()
				
				var save:FileReference = new FileReference();
				
				function squeakSoundsConverted():void
				{
					Scratch.app.scriptsPane.saveScripts(false);
					var projectType:String = Scratch.app.extensionManager.hasExperimentalExtensions() ? '.sbx' : '.sb2';
					var defaultName:String = StringUtil.trim(Scratch.app.projectName());
					defaultName = ((defaultName.length > 0) ? defaultName : 'project') + projectType;
					var zipData:ByteArray = projIO.encodeProjectAsZipFile(Scratch.app.stagePane);
					
					var partHeader:ByteArray = new PartHeader() as ByteArray;
					var partChunkBefore:ByteArray = new PartChunkBefore() as ByteArray;
					var partSB2Header:ByteArray = new PartSB2Header() as ByteArray;
					var partChunkBetween:ByteArray = new PartChunkBetween() as ByteArray;
					var partChunkAfter:ByteArray = new PartChunkAfter() as ByteArray;
					
					// multiply by 20 for pixels to twips conversion
					var partDimensions:ByteArray = toRECT(ScratchObj.STAGEW * 20, ScratchObj.STAGEH * 20);
					
					// SWF total filesize
					var partSWFSize:ByteArray = toUI32(partHeader.length + 4 + partDimensions.length + partChunkBefore.length + 4 + partSB2Header.length + zipData.length + partChunkBetween.length + 21 + partChunkAfter.length);
					
					// SB2 filesize
					var partSB2Size:ByteArray = toUI32(6 + zipData.length);
					
					// SB2 file
					var partSB2:ByteArray = zipData;
					
					// force some settings based on other settings
					var greenFlagBarOn:Boolean = greenFlagBar || asEditor;
					var hideCursorOn:Boolean = hideCursor && !asEditor;
					
					// make settings part
					// TODO: make variables for things like settings file length
					var partSettings:ByteArray = new ByteArray();
					for (var padding:int = 0; padding < 21; padding++)
					{
						partSettings[padding] = CHAR_0;
					}
					partSettings[SETTING_FULLSCREEN] = fullScreen ? CHAR_1 : CHAR_0;
					partSettings[SETTING_GREEN_FLAG_BAR] = greenFlagBar ? CHAR_1 : CHAR_0;
					partSettings[SETTING_TURBO_MODE] = turboMode ? CHAR_1 : CHAR_0;
					partSettings[SETTING_AUTO_START] = autoStart ? CHAR_1 : CHAR_0;
					partSettings[SETTING_EDIT_MODE] = asEditor ? CHAR_1 : CHAR_0;
					partSettings[SETTING_HIDE_CURSOR] = hideCursor ? CHAR_1 : CHAR_0;
					
					// combine parts
					var swf:ByteArray = new ByteArray();
					swf.writeBytes(partHeader);
					swf.writeBytes(partSWFSize);
					swf.writeBytes(partDimensions);
					swf.writeBytes(partChunkBefore);
					
					// order of converter-added binary files can change
					// this happens at random when building the projector
					// it is based on mxmlc's optimizations and cannot be controlled
					// the build script detects which is first
					// this information is written to Order.bin
					var sb2BinaryFirst:Boolean = (new Order() as ByteArray)[0] == CHAR_1;
					if (sb2BinaryFirst)
					{
						swf.writeBytes(partSB2Size);
						swf.writeBytes(partSB2Header);
						swf.writeBytes(partSB2);
						swf.writeBytes(partChunkBetween);
						swf.writeBytes(partSettings);
					}
					else
					{
						swf.writeBytes(partSettings);
						swf.writeBytes(partChunkBetween);
						swf.writeBytes(partSB2Size);
						swf.writeBytes(partSB2Header);
						swf.writeBytes(partSB2);
					}
					swf.writeBytes(partChunkAfter);
					try{
						save.save(swf, defaultName + ".swf");
					}catch (err:*){
						DialogBox.notify("Error", err);
					}
				}
				
				if (Scratch.app.loadInProgress) return;
				var projIO:ProjectIO = new ProjectIO(Scratch.app);
				projIO.convertSqueakSounds(Scratch.app.stagePane, squeakSoundsConverted);
			
			}
			DialogBox.close("Export to SWF", null, settingFrame, "Export to SWF", null, startConvert);
		}
		
		// convert an int to a 4 byte unsigned integer
		private function toUI32(number:int):ByteArray
		{
			var result:ByteArray = new ByteArray();
			var i:int = 0;
			while (i < 4)
			{
				result[i] = number % 256;
				number = (number - result[i]) / 256;
				i++;
			}
			return result;
		}
		
		// TODO: using Strings of 1's and 0's is really, really stupid
		// TODO: redo this some day
		
		// generate the width and height RECT
		private function toRECT(w:int, h:int):ByteArray
		{
			var length:int = Math.max(toBits(w).length, toBits(h).length) + 1;
			var a:String = pad(toBits(length), 5);
			var b:String = "0";
			var c:String = "0" + toBits(w);
			var d:String = "0";
			var e:String = "0" + toBits(h);
			function pad(string:String, length:int):String
			{
				while (string.length < length)
				{
					string = "0" + string;
				}
				return string;
			}
			var bits:String = a + pad(b, length) + pad(c, length) + pad(d, length) + pad(e, length);
			var i:int = 0;
			while (i <= bits.length % 8)
			{
				i++;
				bits = bits + "0";
			}
			return (toBytes(bits));
		}
		
		// convert an int to a String of 1's and 0's
		private function toBits(number:int):String
		{
			var result:String = "";
			while (number != 0)
			{
				result = (number % 2).toString(10) + result;
				number = (number - number % 2) / 2;
			}
			return result;
		}
		
		// convert a String of 1's and 0's to the corresponding bytes
		private function toBytes(binary:String):ByteArray
		{
			var result:ByteArray = new ByteArray();
			var byte:int = 0;
			var index:int = 0;
			var number:int;
			var place:int;
			var bit:int;
			while (byte < binary.length / 8)
			{
				number = 0;
				place = 128;
				bit = 0;
				while (bit < 8)
				{
					number = number + (binary.charAt(index) == "1" ? place : 0);
					place = place / 2;
					bit++;
					index++;
				}
				result[byte] = number;
				byte++;
			}
			return result;
		}
	
	}

}