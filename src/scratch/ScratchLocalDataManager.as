package scratch 
{
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import translation.Translator;
	import uiwidgets.DialogBox;
	import util.dataSizeFormat;
	/**
	 * ...
	 * @author SteveXMH
	 */
	public class ScratchLocalDataManager 
	{
		
		private static var app:Scratch;
		private var dataManagerGui:DialogBox;
		private var dataInfo:TextField;
		private static var sharedObj:SharedObject = SharedObject.getLocal("ScratchProjectData");
		private static var sharedObjTime:SharedObject = SharedObject.getLocal("ScratchProjectData/Time");
		
		public function ScratchLocalDataManager(sc:Scratch) 
		{
			app = sc;
			//sharedObj = SharedObject.getLocal("ScratchProjectData");
			
			reCreateGui();
			
			refresh();
			
		}
		
		private function reCreateGui():void
		{
			if (dataManagerGui != null) dataManagerGui.remove();
			if (dataInfo != null) dataInfo = null;
			
			dataInfo = new TextField();
			dataInfo.width = 410;
			dataInfo.height = 100;
			//dataInfo.embedFonts = false;
			dataInfo.defaultTextFormat = CSS.normalTextFormat;
			dataInfo.restrict = "";
			dataInfo.selectable = false;
			dataInfo.multiline = true;
			dataInfo.background = false;
			
			dataManagerGui = new DialogBox();
			dataManagerGui.addTitle(Translator.map("Local Data Manager"));
			dataManagerGui.addWidget(dataInfo);
			dataManagerGui.addButton(Translator.map("Clean all data"), cleanAllEvent);
			dataManagerGui.addButton(Translator.map("Clean old data"), cleanOldEvent);
			dataManagerGui.addButton(Translator.map("Export Data"), exportData);
			dataManagerGui.addButton(Translator.map("Import Data"), importData);
			dataManagerGui.addButton(Translator.map("Close"), hide);
			
			dataManagerGui.showOnStage(app.stage);
			dataManagerGui.visible = false;
			dataManagerGui.backGround.visible = false;
		}
		
		private function impFun(file:FileReference):void
		{
			var result:Object = JSON.parse(file.data.toString());
			cleanAllData(sharedObj.data, sharedObjTime.data);
			for (var key:String in result)
			{
				setLocalData(key, result[key]);
			}
			refresh();
		}
		
		private function importData():Boolean
		{
			
			var file:FileReference = new FileReference();
			file.browse([new FileFilter("Json 文件", "*.json"), new FileFilter("所有文件", "*.*")]);
			file.addEventListener(Event.SELECT, function(e:Event):void{
				if (file.name != "")
				{
					file.addEventListener(Event.COMPLETE, function(e:Event):void{
						impFun(file);
					});
					file.load();
				}
			});
			return true;
		}
		
		private function exportData():Boolean 
		{
			var file:FileReference = new FileReference();
			var json:String = JSON.stringify(sharedObj.data);
			
			file.save(json, "LocalData.json");
			
			return true;
		}
		
		private function cleanAllEvent():Boolean
		{
			cleanAllData(sharedObj.data, sharedObjTime.data);
			sharedObj.clear();
			sharedObjTime.clear();
			refresh();
			return true;
		}
		
		private function cleanAllData(obj:Object, timeObj:Object):void 
		{
			for (var key:String in obj)
			{
				//trace(key);
				sharedObj.setProperty(key);
				if (timeObj.hasOwnProperty(key)) sharedObjTime.setProperty(key);
			}
		}
		
		private function cleanOldEvent():Boolean
		{
			cleanOldData(sharedObj, sharedObjTime);
			refresh();
			return true;
		}
		
		private function cleanOldData(obj:Object, timeObj:Object):void
		{
			for (var key:String in obj)
			{
				if (timeObj.hasOwnProperty(key))
				{
					if (new Date().getTime() - timeObj[key] > 2592000000)//超过一个月
					{
						sharedObj.setProperty(key);
						sharedObjTime.setProperty(key);
					}
					
				}else{
					sharedObj.setProperty(key);
				}
			}
		}
		
		private function nope():Boolean 
		{
			return true;
		}
		
		private function refresh():void
		{
			var size:uint = sharedObj.size;
			var keyCount:int = 0;
			
			dataInfo.text = "";
			dataInfo.appendText("本地数据大小： " + dataSizeFormat.formatSize(size));
			
			if (size >= 10 * 1024 * 1024)
			{
				dataInfo.appendText("\n数据体积过大，建议进行清理！");
			}
			
			for (var k:String in sharedObj.data)
			{
				keyCount++;
			}
			
			dataInfo.appendText("\n\n已记录键值数量：" + keyCount.toFixed());
			
		}
		
		public function show():void
		{
			reCreateGui();
			dataManagerGui.visible = true;
			dataManagerGui.backGround.visible = true;
			refresh();
		}
		
		public function hide():Boolean
		{
			dataManagerGui.visible = false;
			dataManagerGui.backGround.visible = false;
			return true;
		}
		
		public function toString():String 
		{
			return "[本地数据管理器] 目前已存储数据大小： " + sharedObj.size + " 字节";
		}
		
		public static function setLocalData(key:String, value:* = null):Boolean
		{
			if (value == null || value is Number || value is String || value is Boolean)
			{
				if (value is String && value.length > 65536)
				{
					return false;
				}
			}else{
				return false;
			}
			sharedObj.setProperty(key, value);
			sharedObjTime.setProperty(key, new Date().getTime());
			return true;
		}
		
		public static function getLocalData(key:String):*
		{
			var result:* = null
			result = sharedObj.data[key];
			if (result != null)
			{
				sharedObjTime.setProperty(key, new Date().getTime());
			}
			return result;
		}
		
		//*/
		private function sizeFormat(num:Number,useFullWord:Boolean = false):String //输出简化估值大小
		{
			var sizeUnit:Array = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB", "BB", "NB", "DB", "WTF???"];
			var sizeUnitFull:Array = ["Byte", "KiloByte", "MegaByte", "GigaByte", "TeraByte", "PetaByte", "ExaByte", "ZettaByte", "YottaByte", "BrontoByte", "NonaByte", "DoggaByte", "What The Fuck???"];
			
			var backValue:uint = num;
			
			var unit:int = 0;
			
			while (backValue > 1024)
			{
				backValue = backValue / 1024;
				unit++;
			}
			
			return backValue.toString() + useFullWord ? sizeUnitFull[unit] : sizeUnit[unit];
			
		}//*/
		
	}

}