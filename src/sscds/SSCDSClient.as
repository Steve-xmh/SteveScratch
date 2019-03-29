package sscds 
{
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	/**
	 * 与 SteveScratchCloudDataServer 服务器进行交互操作的客户端
	 * @author SteveXMH
	 */
	public class SSCDSClient 
	{
		
		public var client:Socket;
		public var returned:Boolean;
		//返回值
		public var cmd:String;
		
		
		public function SSCDSClient() 
		{
			client = new Socket();
			client.addEventListener(ProgressEvent.SOCKET_DATA,getData)
		}
		
		private function getData(e:ProgressEvent):void 
		{
			var obj:Object = JSON.parse(client.readUTF());
			
			returned = true;
		}
		/**
		 * 连接服务器，并返回流值
		 * @param	ip
		 * @param	port
		 * @return
		 */
		public function connect(ip:String, port:int):int{
			returned = false;
			if (client.connected){
				client.close()
			}
		}
		
	}

}