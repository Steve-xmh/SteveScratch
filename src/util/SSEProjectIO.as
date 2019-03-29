package util
{
	import flash.utils.ByteArray;
	import scratch.ScratchCostume;
	import scratch.ScratchObj;
	import scratch.ScratchSound;
	import scratch.ScratchStage;
	
	/**
	 * 用于分析工程并导出成SSEP格式
	 * @author SteveXMH
	 */
	public class SSEProjectIO
	{
		private const ssepVersion:int = 0;
		
		private var app:Scratch;
		private var imagesMD5:Array = [];
		private var images:Array = [];//存储图像
		
		private var soundsMD5:Array = [];
		private var sounds:Array = [];//存储音效
		
		private var objsName:Array = [];
		
		private var enumList:Array = [];//存储常量
		private var proj:ScratchStage;
		
		public function SSEProjectIO(app:Scratch):void
		{
			this.app = app
		}
		
		public function encodeProjectAsSSEP(proj:ScratchStage):ByteArray
		{
			this.proj = proj;
			delete proj.info.penTrails;
			
			proj.savePenLayer();
			proj.updateInfo();
			recordImagesAndSounds(proj.allObjects(), false , proj);
			return writeToSSEP(proj);
			
		}
		
		private function writeToSSEP(proj:ScratchStage):ByteArray 
		{
			var file:ByteArray = new ByteArray();
			file.writeByte(83);//S
			file.writeByte(83);//S
			file.writeByte(69);//E
			file.writeByte(80);//P
			file.writeShort(ssepVersion);
			file.writeUnsignedInt(proj.objName.length);
			file.writeUTF(proj.objName);
			file.writeBoolean(false);
			file.writeBoolean(false);
			file.writeBoolean(false);
			file.writeBoolean(false);
			
			return file;
		}
		
		/**
		 * 存储并返回指定常量值的位置（最好是 String 类）
		 * @param	enum 欲保存的值
		 * @return 常量所在的位置
		 */
		private function saveAndGetEnumNumber(enum:*):int
		{
			var num:int = enumList.indexOf(enum);
			if (num == -1)
			{
				return enumList.push(enum) - 1;
			}
			else
			{
				return num;
			}
		}
		
		/**
		 * 存储并返回指定音效的位置
		 * @param	enum 欲保存的值
		 * @return 常量所在的位置
		 */
		private function saveAndGetSoundNumber(sound:ByteArray,MD5:String):int
		{
			var num:int = soundsMD5.indexOf(MD5);
			if (num == -1)
			{
				sounds.push(sound);
				return soundsMD5.push(MD5) - 1;
			}
			else
			{
				return num;
			}
		}
		
		/**
		 * 存储并返回指定素材的位置
		 * @param	enum 欲保存的值
		 * @return 常量所在的位置
		 */
		private function saveAndGetImageNumber(image:ByteArray,MD5:String):int
		{
			var num:int = imagesMD5.indexOf(MD5);
			if (num == -1)
			{
				images.push(image);
				return imagesMD5.push(MD5) - 1;
			}
			else
			{
				return num;
			}
		}
		
		/**
		 * 记录图像和音频信息
		 * @param	objList ScratchObj 数组集
		 * @param	uploading 是否为上传模式
		 * @param	proj
		 */
		private function recordImagesAndSounds(objList:Array, uploading:Boolean, proj:ScratchStage = null):void
		{
			soundsMD5 = [];
			imagesMD5 = [];
			images = [];
			sounds = [];
			
			app.clearCachedBitmaps();
			
			for each (var obj:ScratchObj in objList)
			{
				objsName.push(obj.name);
				for each (var c:ScratchCostume in obj.costumes)
				{
					c.prepareToSave(); // encodes image and computes md5 if necessary
					c.baseLayerID = saveAndGetImageNumber(c.baseLayerBitmap, c.baseLayerMD5)
					if (c.textLayerBitmap)
					{
						c.textLayerID = saveAndGetImageNumber(c.textLayerBitmap, c.textLayerMD5);
					}
				}
				for each (var snd:ScratchSound in obj.sounds)
				{
					snd.prepareToSave(); // compute md5 if necessary
					snd.soundID = saveAndGetSoundNumber(snd.soundData, snd.md5);
				}
			}
		}
	
	}

}