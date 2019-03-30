package primitives
{
	import blocks.*;
	import assets.Resources;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import sound.ScratchSoundPlayer;
	import ui.parts.StagePart;
	import uiwidgets.DialogBox;
	
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.Dictionary;
	
	import interpreter.*;
	
	import scratch.*;
	
	/**
	 * SteveScratch 独占模块
	 * @author SteveXMH/Saprrow
	 */
	public class SteveBlocksPrims
	{
		private var app:Scratch;
		protected var interp:Interpreter;
		
		public function SteveBlocksPrims(app:Scratch, interpreter:Interpreter)
		{
			this.app = app;
			this.interp = interpreter;
		}
		
		public function addPrimsTo(primTable:Dictionary):void
		{
			primTable["getUnicodeToText"] = getunicodetotext;
			primTable["getTextToUnicode"] = gettexttounicode;
			
			primTable["getStrFromTo"] = getstrfromto;
			primTable["ifThenElse"] = ifThenElse;
			primTable["=="] = fixconpare;
			
			primTable["getColorOn"] = getColorOn;
			
			primTable["playSoundOnPos"] = playSoundOnPos;
			primTable["doPlaySoundOnPosAndWait"] = playSoundOnPosAndWait;
			primTable["posContainStr"] = posContainStr;
			
			primTable["drawRect"] = printRectangle;
			
			primTable["printText"] = printTextOn;
			primTable["setFont"] = setFont;
			primTable["setFontColor"] = setFontColor;
			primTable["setFontSize"] = setFontSize;
			primTable["setFontBold"] = setFontBold;
			primTable["setFontItalic"] = setFontItalic;
			primTable["setFontUnderline"] = setFontUnderline;
			
			primTable["addRotX"] = function(b:Block):void{ rotate3D('x', interp.numarg(b, 0), true)};
			primTable["addRotY"] = function(b:Block):void{ rotate3D('y', interp.numarg(b, 0), true)};
			primTable["addRotZ"] = function(b:Block):void{ rotate3D('z', interp.numarg(b, 0), true)};
			
			primTable["setRotX"] = function(b:Block):void{ rotate3D('x', interp.numarg(b, 0), false)};
			primTable["setRotY"] = function(b:Block):void{ rotate3D('y', interp.numarg(b, 0), false)};
			primTable["setRotZ"] = function(b:Block):void{ rotate3D('z', interp.numarg(b, 0), false)};
			
			primTable["rotX"] = function(b:Block):Number{ var s:ScratchSprite = interp.targetSprite(); return s.rotationX; };
			primTable["rotY"] = function(b:Block):Number{ var s:ScratchSprite = interp.targetSprite(); return s.rotationY; };
			primTable["rotZ"] = function(b:Block):Number{ var s:ScratchSprite = interp.targetSprite(); return s.rotationZ; };
			//primTable["connectCloud"] = connectCloud;
			primTable["setResolution"] = setResolution;
			
			primTable["strToUpper"] = strToUpper;
			primTable["strToLower"] = strToLower;
			primTable["invertStr"] = strInvert;
			
			primTable["setAllSpriteVisible"] = setAllSpriteVisible;
			primTable["setAllValueListVisible"] = setAllValueListVisible;
			
			primTable["setLocalData"] = setLocalData;
			primTable["getLocalData"] = getLocalData;
			
			//hdz2007
			primTable["binToDec"] = binToDec;
			primTable["binToHex"] = binToHex;
			primTable["binToOct"] = binToOct;
			primTable["decToBin"] = decToBin;
			primTable["decToHex"] = decToHex;
			primTable["decToOct"] = decToOct;
		}
		
		private function ifThenElse(b:Block):* 
		{
			var bool:Boolean = interp.boolarg(b, 0);
			var ifTrue:* = interp.arg(b, 1);
			var ifFalse:* = interp.arg(b, 2);
			return bool ? ifTrue : ifFalse;
		}
		
		private function setAllValueListVisible(b:Block):void 
		{
			var isShow:Boolean = (interp.arg(b, 0) == "Show")
			var vOl:Boolean = (interp.arg(b, 1) == "Lists")
			var obj:ScratchObj = (interp.arg(b, 2) == "_myself_") ? interp.targetObj() : app.stagePane.objNamed(String(interp.arg(b, 2)));
			
			
			if (!(obj is ScratchObj)) return;
			
			var vs:Array = vOl ? obj.listNames() : obj.varNames();
			
			for (var c:String in vs)
			{
				isShow ? app.runtime.showVarOrListFor(vs[c], vOl, obj) : app.runtime.hideVarOrListFor(vs[c], vOl, obj);
			}
			
		}
		
		private function printRectangle(b:Block):void 
		{
			var color:uint = interp.numarg(b, 0);
			var x:Number = interp.numarg(b, 1);
			var y:Number = interp.numarg(b, 2);
			var w:Number = interp.numarg(b, 3);
			var h:Number = interp.numarg(b, 4);
			
			var s:Shape = new Shape();
			s.graphics.beginFill(color);
			s.graphics.drawRect(0, 0, w, h);
			s.graphics.endFill();
			
			app.stagePane.penLayer.bitmapData.draw(s, new Matrix(1, 0, 0, 1, x + ScratchObj.STAGEW / 2, ScratchObj.STAGEH / 2 - y));
		}
		
		private function getLocalData(b:Block):* 
		{
			var key:String = interp.arg(b, 0);
			if (key == "" || key == null) return null;
			return ScratchLocalDataManager.getLocalData(key);
		}
		
		private function setLocalData(b:Block):void 
		{
			var key:String = interp.arg(b, 0);
			var val:String = interp.arg(b, 1);
			if (key == "" || key == null) return;
			ScratchLocalDataManager.setLocalData(key, val);
		}
		
		private function setAllSpriteVisible(b:Block):void 
		{
			var isVisible:Boolean = interp.boolarg(b, 0);
			//if (!interp.targetObj().isStage) return;
			for (var i:int = 0; i < app.stagePane.numChildren; i++) {
				var o:* = app.stagePane.getChildAt(i);
				if (o is ScratchSprite) {
					o.visible = isVisible;
					o.updateBubble();
				}
			}
			interp.redraw();
		}
		
		private function strInvert(b:Block):String 
		{
			var str:String = interp.arg(b, 0);
			
			var back:String = "";
			
			for (var index:int = str.length; index >= 0; index-- )
			{
				back += str.charAt(index);
			}
			
			return back;
		}
		
		private function strToLower(b:Block):String 
		{
			var str:String = interp.arg(b, 0);
			return str.toLowerCase();
		}
		
		private function strToUpper(b:Block):String 
		{
			var str:String = interp.arg(b, 0);
			return str.toUpperCase();
		}
		
		private function drawRect(b:Block):void 
		{
			var g:Graphics = new Graphics();
			var color:uint = interp.arg(b, 0);
			var sizeX:Number = interp.numarg(b, 1);
			var sizeY:Number = interp.numarg(b, 2);
		}
		
		private function setFontUnderline(b:Block):void 
		{
			var s:ScratchSprite = interp.targetSprite();
			if (s) s.fontUnderline = interp.boolarg(b, 0);
		}
		
		private function setFontItalic(b:Block):void 
		{
			var s:ScratchSprite = interp.targetSprite();
			if (s) s.fontItalic = interp.boolarg(b, 0);
		}
		
		private function setFontBold(b:Block):void 
		{
			var s:ScratchSprite = interp.targetSprite();
			if (s) s.fontBold = interp.boolarg(b, 0);
		}
		
		private function getColorOn(b:Block):Number 
		{
			var bm:BitmapData = app.stagePane.saveScreenData();
			var posX:Number = interp.numarg(b, 0);
			var posY:Number = interp.numarg(b, 1);
			trace(posX + ScratchObj.STAGEW / 2, posY + ScratchObj.STAGEH / 2);
			return Number(bm.getPixel(posX + ScratchObj.STAGEW / 2, posY + ScratchObj.STAGEH / 2));
		}
		
		private function setResolution(b:Block):void 
		{
			const x:Number = Math.max(480, Math.floor(interp.numarg(b, 0)));
			const y:Number = Math.max(360, Math.floor(interp.numarg(b, 1)));
			const CANVAS:Number = ScratchObj.CANVAS;
			
			app.imagesPart.editor.translateContents((x / 2) - (ScratchObj.STAGEW / 2),(y / 2) - (ScratchObj.STAGEH / 2));//偏移图像编辑器
			
			ScratchObj.STAGEW = x;
			ScratchObj.STAGEH = y;
			var stage:ScratchStage = app.stagePane;
			var oldData:Bitmap = stage.penLayer;
			//重新调整画板大小
			var bm:BitmapData = new BitmapData(x * CANVAS, y * CANVAS, true, 0);
			bm.draw(oldData.bitmapData);
			stage.penLayer = new Bitmap(bm);
			
			if (oldData.parent){
				oldData.parent.addChild(stage.penLayer);
				oldData.parent.removeChild(oldData);
			}
			
			//重新调整剪切矩形
			stage.fixSize();
			app.fixLayout();
			interp.redraw();
		}
		
		private function rotate3D(axis:String = "",r:Number = 0, addMode:Boolean = false):void 
		{
			var s:ScratchSprite = interp.targetSprite();
			var targetObj:Sprite = s;
			if (s && !s.isStage)
			{
				if (addMode)
				{
					if (axis == "x") targetObj.rotationX += r;
					if (axis == "y") targetObj.rotationY += r;
					if (axis == "z") targetObj.rotationZ += r;
				}else{
					if (axis == "x") targetObj.rotationX  = r;
					if (axis == "y") targetObj.rotationY  = r;
					if (axis == "z") targetObj.rotationZ  = r;
				}
				targetObj.cacheAsBitmap = false;
				if ((s.penIsDown) || (s.visible)) interp.redraw();
			}
		}
		//printText ===========================
		private function setFontSize(b:Block):void 
		{
			var s:* = interp.targetObj();
			if (s) s.fontSize = interp.numarg(b, 0);
		}
		
		private function setFontColor(b:Block):void 
		{
			var s:* = interp.targetObj();
			if (s) s.fontColor = interp.arg(b, 0);
		}
		
		private function setFont(b:Block):void 
		{
			var s:* = interp.targetObj();
			if (s) s.fontName = Resources.chooseFont([interp.arg(b, 0)]);
		}
		
		private function printTextOn(b:Block):void 
		{
			var s:* = interp.targetObj();
			var str:String = interp.arg(b, 0);
			var posX:Number = interp.numarg(b, 1) + ScratchObj.STAGEW/2;
			var posY:Number = -interp.numarg(b, 2) + ScratchObj.STAGEH/2;
			var label:TextField = new TextField();
			
			label.defaultTextFormat = new TextFormat(Resources.chooseFont([s.fontName]), s.fontSize, s.fontColor, s.fontBold, s.fontItalic, s.fontUnderline);
			
			label.width = ScratchObj.STAGEW;
			label.height = ScratchObj.STAGEH;
			label.cacheAsBitmap = true;
			//label.selectable = false;
			//label.restrict = "";
			label.text = str;
			app.stagePane.penLayer.bitmapData.draw(label, new Matrix(1, 0, 0, 1, posX, posY));
			//label = null;
			//interp.redraw();
		}
		//printText =================================
		private function posContainStr(b:Block):Number 
		{
			var pos:Number = interp.numarg(b, 0);
			var str:String = interp.arg(b , 1);
			var subStr:String = interp.arg(b, 2);
			pos = Math.floor(pos);
			if (pos < 1) pos = 1;
			var counter:Number = 1;
			var strPos:Number = 0;
			while (counter <= pos) 
			{
				//DialogBox.notify("", str + "\n" + str.replace(subStr, ""));
				if (str.replace(subStr, "") == str)
				{
					return -1;//如果已经没有匹配项则返回未找到
				}
				strPos += str.search(subStr);
				//DialogBox.notify("", str.search(subStr).toString());
				str = str.replace(subStr , "");
				counter += 1;
			}
			return strPos + 1;
		}
		
		private function getunicodetotext(b:Block):String //由unicode地址返回unicode字符
		{
			var num:Number = interp.arg(b, 0);
			return String.fromCharCode(num);
		}
		
		private function gettexttounicode(b:Block):Number//由unicode字符返回unicode地址
		{
			var str:String = interp.arg(b, 0);
			return str.length > 0 ? str.charCodeAt() : -1;
		}
		
		private function getstrfromto(b:Block):String
		{
			var str:String = interp.arg(b, 2);
			var pos:Number = interp.arg(b, 0);
			var len:Number = interp.arg(b, 1);
			
			return str.substr(pos, len);
		}
		
		private static const emptyDict:Dictionary = new Dictionary();
		private static var lcDict:Dictionary = new Dictionary();
		
		private function fixconpare(b:Block):Boolean
		{
			var a1:* = interp.arg(b, 0);
			var a2:* = interp.arg(b, 1);
			// This is static so it can be used by the list "contains" primitive.
			var n1:Number = Interpreter.asNumber(a1);
			var n2:Number = Interpreter.asNumber(a2);
			// X != X is faster than isNaN()
			if (n1 != n1 || n2 != n2)
			{
				// Suffix the strings to avoid properties and methods of the Dictionary class (constructor, hasOwnProperty, etc)
				if (a1 is String && emptyDict[a1]) a1 += '_';
				if (a2 is String && emptyDict[a2]) a2 += '_';
				
				// at least one argument can't be converted to a number: compare as strings
				var s1:String = lcDict[a1];
				if (!s1) s1 = lcDict[a1] = String(a1);
				var s2:String = lcDict[a2];
				if (!s2) s2 = lcDict[a2] = String(a2);
				return s1.localeCompare(s2) == 0;
			}
			else
			{
				// compare as numbers
				if (n1 < n2) return false;
				if (n1 == n2) return true;
				if (n1 > n2) return false;
			}
			return false;
		}
		
		private function playSoundOnPos(b:Block):void
		{
			var snd:ScratchSound = interp.targetObj().findSound(interp.arg(b, 0));
			var pos:Number = interp.numarg(b, 1);
			if (snd != null) playSound(snd, interp.targetObj(), pos);
		}
		
		private function playSoundOnPosAndWait(b:Block):void
		{
			var activeThread:Thread = interp.activeThread;
			var pos:Number = interp.numarg(b, 1);
			if (activeThread.firstTime)
			{
				var snd:ScratchSound = interp.targetObj().findSound(interp.arg(b, 0));
				if (snd == null) return;
				activeThread.tmpObj = playSound(snd, interp.targetObj(), pos);
				activeThread.firstTime = false;
			}
			var player:ScratchSoundPlayer = ScratchSoundPlayer(activeThread.tmpObj);
			if ((player == null) || (player.atEnd()))
			{ // finished playing
				activeThread.tmp = 0;
				activeThread.firstTime = true;
			}
			else
			{
				interp.doYield();
			}
		}
		
		private function playSound(s:ScratchSound, client:ScratchObj, position:Number = 0):ScratchSoundPlayer
		{
			var player:ScratchSoundPlayer = s.sndplayer();
			player.client = client;
			player.startPlaying(null, position);
			return player;
		}
		
		private function binToDec(b:Block):Number{
			var Bin:* = interp.arg(b, 0);
			var rDec:* = parseInt(Bin, 2);
			return rDec;
		}
		
		private function binToHex(b:Block):*{
			var Bin:* = interp.arg(b, 0);
			var rDec:* = parseInt(Bin, 2);
			var rHex:* = (rDec.toString(16))
			return rHex;
		}
		
		private function binToOct(b:Block):*{
			var Bin:* = interp.arg(b, 0);
			var rDec:* = parseInt(Bin, 2);
			var rOct:* = (rDec.toString(8))
			return rOct;
		}
		
		
		private function decToBin(b:Block):*{
			var dec:* = interp.arg(b, 0);
			return dec.toString(2);
		}
		private function decToHex(b:Block):*{
			var dec:* = interp.arg(b, 0);
			return dec.toString(16);
		}
		private function decToOct(b:Block):*{
			var dec:* = interp.arg(b, 0);
			return dec.toString(8);
		}
		//private function connectCloud(b:Block):*{
		//	var ip = interp.arg(b,0);
		//	var port = interp.arg(b,1);
		//}	
	}

}