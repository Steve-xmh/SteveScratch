package worker 
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import translation.Translator;
	
	import scratch.ScratchStage;
	
	import util.ObjReader;
	import util.OldProjectReader;
	import util.ProjectIO;

	/**
	 * 这里是 Worker 端的程序
	 * @author SteveXMH
	 */
	public class WorkerSideClass 
	{
		private static var mtw:MessageChannel;
		public static var wtm:MessageChannel;//使用这个发送
		private static var app:Scratch;
		
		public function WorkerSideClass(app:Scratch, mainToWorker:MessageChannel, workerToMain:MessageChannel) 
		{
			mtw = mainToWorker;
			wtm = workerToMain;
			app = app;
			workerTrace("Worker 开始工作！");
			mtw.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
		}
		
		private function onMainToWorker(e:Event):void 
		{
			var msg:Array = mtw.receive();
			if (msg[0] == "loadProject")
			{
				wtm.send(["loadProcess", Translator.map("Loading Project..."), Translator.map("Loading Data..."), 0]);
				//app.runtime.installProjectFromData(msg[1]);
				var data:ByteArray = msg[1];
				var newProject:ScratchStage;
				data.position = 0;
				if (data.length < 8 || data.readUTFBytes(8) != 'ScratchV') {
					data.position = 0;
					newProject = new ProjectIO(app).decodeProjectFromZipFile(data);
					if (!newProject) {
						wtm.send(["removeLoadProcess"]);
						return;
					}
				} else {
					var info:Object;
					var objTable:Array;
					data.position = 0;
					var reader:ObjReader = new ObjReader(data);
					try { info = reader.readInfo() } catch (e:Error) { data.position = 0 }
					try { objTable = reader.readObjTable() } catch (e:Error) { }
					if (!objTable) {
						wtm.send(["removeLoadProcess"]);
						return;
					}
					newProject = new OldProjectReader().extractProject(objTable);
					newProject.info = info;
					if (info != null) delete info.thumbnail; // delete old thumbnail
				}
				
				wtm.send(["loadProcess", Translator.map("Finish!"), "", 1]);
				wtm.send(["removeLoadProcess"]);
				Worker.current.setSharedProperty("NewProject",newProject);
				wtm.send(["replaceNewProject"]);
				//app.runtime.projectToInstall = null;
			}else {
				workerTrace("[警告] 接收了未知的指令：" + msg.toString())
			}
		}
		
		public static function workerTrace(msg:String = ""):void
		{
			wtm.send(["Trace", msg]);
		}
		
	}

}