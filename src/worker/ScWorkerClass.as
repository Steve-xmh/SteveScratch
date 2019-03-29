package worker 
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import scratch.ScratchSprite;
	
	import scratch.ScratchStage;
	
	import uiwidgets.DialogBox;

	/**
	 * 主swf与 Worker 端指挥的类
	 * 信息的传输格式：[信息类型,附带...]
	 * @author SteveXMH
	 */
	public class ScWorkerClass 
	{
		public static var mtw:MessageChannel;//使用这个发送
		private static var wtm:MessageChannel;
		private static var app:Scratch;
		
		public function ScWorkerClass(napp:Scratch, mainToWorker:MessageChannel, workerToMain:MessageChannel) 
		{
			mtw = mainToWorker;
			wtm = workerToMain;
			app = napp;
			wtm.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
			trace("正在监听Worker！");
		}
		
		public static function loadProjectUsingWorker(projectName:String, data:ByteArray):void
		{
			trace("正在呼叫 Worker 打开文件！");
			app.runtime.stopAll();
			app.oldWebsiteURL = '';
			app.loadInProgress = true;
			//installProjectFromData(data);
			//Scratch.app.setProjectName(fileName);
			mtw.send(["loadProject", data]);
		}
		
		private function onWorkerToMain(e:Event):void 
		{
			var msg:* = wtm.receive();
			//DialogBox.notify(msg[0], msg[1]);
			if (msg[0] == "Trace") 
			{
				trace("[Worker 端] " + msg[1]);
				return;
			}else if (msg[0] == "loadProcess")// 设置进度条
			{
				if (!app.lp) app.addLoadProgressBox(msg[1]);
				app.lp.setInfo(msg[2]);
				app.lp.setProgress(msg[3]);
			}else if (msg[0] == "removeLoadProcess")// 删除进度条
			{
				app.removeLoadProgressBox();
			}else if (msg[0] == "loadProject")
			{
				loadProjectFunction(msg);
			}else if (msg[0] == "replaceNewProject")// 替换当前工程
			{	/*
				var newProject:* = app.bgWorker.getSharedProperty("NewProject");
				trace(newProject as ScratchStage);
				app.runtime.projectToInstall = newProject as ScratchStage;
				app.bgWorker.setSharedProperty("NewProject",undefined);
				trace(app.runtime.projectToInstall);
				trace("已接收 Worker 的工程！");*/
			}else if (msg[0] == "projectLoadFailed")
			{
				app.loadProjectFailed();
			}else {
				trace("[警告] 接收了未知的指令：" + msg.toString())
			}
		}
		
		/**
		 * 这个专门处理打开工程的信息
		 * 因为反序列化实在是太奇葩了。。。
		 * @param	msg 传回的信息
		 */
		private function loadProjectFunction(msg:*):void 
		{
			if (msg[1] == "newSprite")//创建新角色
			{
				var newSprite:ScratchSprite = new ScratchSprite(msg[2]);
				newSprite.scratchX		 = msg[3];
				newSprite.scratchY		 = msg[4];
				newSprite.scaleX		 = msg[5];
				newSprite.scaleY		 = msg[5];
				newSprite.direction		 = msg[6];
				newSprite.rotationStyle	 = msg[7];
				newSprite.isDraggable	 = msg[8];
				newSprite.indexInLibrary = msg[9];
				newSprite.visible		 = msg[10];
				newSprite.spriteInfo	 = msg[11] as Object;
				newSprite.setScratchXY(msg[3], msg[4]);
				app.stageObj().addChild(newSprite);
				app.updateSpriteLibrary();
				trace(msg[2]);
			}else if (msg[1] == "newStage")//新建新舞台
			{
				var newStage:ScratchStage = new ScratchStage();
				app.runtime.projectToInstall = newStage;
			}
		}
		
	}

}