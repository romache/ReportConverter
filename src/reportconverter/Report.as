package reportconverter
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.EventPriority;
	import mx.utils.StringUtil;
	
	import spark.collections.Sort;
	import spark.collections.SortField;

	public class Report extends EventDispatcher
	{
		public function Report(date:Date, file:File=null) {
			this.date = date;
			_file = file;
			if (_file != null) {
				addFileListeners(_file);
				_file.load();
			}
		}
		
		private var _src:String;
		
		[Bindable]
		public var date:Date;
		private var _file:File;
		[Bindable]
		public var lines:ArrayCollection;
		[Bindable]
		public var loaded:Boolean = false;
		
		private function addFileListeners(f:File):void {
			f.addEventListener(Event.COMPLETE, onFileLoadComplete, false, EventPriority.DEFAULT, true);
			f.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError, false, EventPriority.DEFAULT, true);
			f.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFileLoadError, false, EventPriority.DEFAULT, true);
		}
		private function removeFileListeners(f:File):void {
			f.removeEventListener(Event.COMPLETE, onFileLoadComplete);
			f.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			f.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onFileLoadError);
		}
		private function onFileLoadError(event:ErrorEvent):void {
			Alert.show("Couldn't load file at " + _file.nativePath, "Error writing");
		}
		private function onFileLoadComplete(event:Event):void {
			removeFileListeners(_file);
			build(_file.data.toString());
			_file = null;
		}
		
		public function build(src:String, date:Date=null):void {
			if (date != null)
				this.date = date;
			_src = src;
			lines = new ArrayCollection();
			var linesSrc:Array = src.split("\n");
			var type:String;
			var line:RegExp = /^\d+\.\s+.+$/mi;
			for (var i:int = 0; i < linesSrc.length; i++) {
				var s:String = StringUtil.trim(linesSrc[i]);
				if (s.length != 0 && s != "none") {
					if (line.test(s))
						lines.addItem(ReportLine.create(s, type));
					else
						type = s;
				}
			}
			loaded = true;
		}
		
		public function sort():void {
			applySort();
			lines.refresh();
		}
		
		public function removeSort():void {
			lines.sort = null;
			lines.refresh();
		}
		
		private function applySort():void {
			var sort:Sort = new Sort();
			sort.fields = [new SortField("idx", false, true)];
			lines.sort = sort;
		}
		
		public function filterDone(sort:Boolean=true):void {
			applyFilter(doneFilter, sort);
		}
		
		public function filterTodo(sort:Boolean=true):void {
			applyFilter(todoFilter, sort);
		}
		
		public function filterProblems(sort:Boolean=true):void {
			applyFilter(problemsFilter, sort);
		}
		
		public function removeFilter(sort:Boolean=true):void {
			lines.filterFunction = null;
			if (sort)
				lines.sort = null;
			lines.refresh();
		}
		
		private function applyFilter(filter:Function, sort:Boolean):void {
			lines.filterFunction = filter;
			if (sort)
				applySort();
			lines.refresh();
		}
		
		private function doneFilter(l:ReportLine):Boolean {
			return l is Done;
		}
		
		private function todoFilter(l:ReportLine):Boolean {
			return l is Todo;
		}
		
		private function problemsFilter(l:ReportLine):Boolean {
			return l is Problem;
		}
	}
}
