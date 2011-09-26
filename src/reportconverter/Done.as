package reportconverter
{
	import mx.utils.StringUtil;

	public class Done extends ReportLine
	{
		public function Done(src:String)
		{
			super(src);
		}
		
		public var time:Number;
		public var inProgress:Boolean;
		public var lineExt:String;
		
		override protected function build(src:String):void {
			super.build(src);
			var brkIdx:Number = line.lastIndexOf("[");
			if (brkIdx == -1)
				throw new ArgumentError("Done line should end with time spent: 1. Something... [2h]");
			time = extractTime(line.substring(brkIdx + 1, line.length - 1));
			line = StringUtil.trim(line.substring(0, brkIdx));
			lineExt = line;
			brkIdx = line.lastIndexOf("[IN PROGRESS]");
			inProgress = brkIdx != -1;
			if (inProgress)
				line = StringUtil.trim(line.substring(0, brkIdx));
		}
		
		private function extractTime(src:String):Number {
			src = StringUtil.trim(src);
			// TODO Only hours ('h') for now
			return Number(src.substring(0, src.length - 1));
		}
	}
}