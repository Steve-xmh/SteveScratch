package util 
{
	/**
	 * 格式化数据大小单位
	 * @author SteveXMH
	 */
	public class dataSizeFormat 
	{
		
		static public function formatSize(size:uint, useLowerUnit:Boolean = false):String {
			const power = useLowerUnit ? 1000 : 1024;
			var finalSize:Number = new Number(size);
			var unit:int = 0;
			var sizes:Array = ["Byte", "KB", "MB", "GB", "TB", "PB"];//没人会转换出PB吧。。。
			while (finalSize > power && unit < sizes.length - 1){
				unit ++;
				finalSize = finalSize / power;
			}
			return finalSize.toFixed(2) + sizes[unit];
		}
		
	}

}