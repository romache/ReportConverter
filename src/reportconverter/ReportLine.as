package reportconverter
{
	import flash.events.EventDispatcher;
	
	import mx.utils.StringUtil;

	public class ReportLine extends EventDispatcher
	{
		public function ReportLine(src:String) {
			_src = src;
			build(src);
		}
		
		private var _src:String;
		
		public var line:String;
		public var idx:Number;
		
		public static function create(line:String, parent:String):ReportLine {
			if (parent == "Done today:")
				return new Done(line);
			else if (parent == "TODO next:")
				return new Todo(line);
			else if (parent == "Problems:")
				return new Problem(line);
			return new ReportLine(line);
		}
		
		protected function build(src:String):void {
			var dotIdx:Number = src.indexOf(". ");
			if (dotIdx == -1)
				throw new ArgumentError("Line should start with an index: 1. Something...");
			idx = Number(src.substring(0, dotIdx));
			line = StringUtil.trim(src.substring(dotIdx + 2));
		}
	}
}