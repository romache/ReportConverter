package reportconverter
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	public class FileReadCollection extends ArrayCollection
	{
		public var loadedProp:String = "loaded";
		
		private var _toLoad:Number = 0;
		
		[Bindable("complete")]
		[Bindable("progress")]
		public function get toLoad():Number {
			return _toLoad;
		}
		
		[Bindable("complete")]
		[Bindable("progress")]
		public function get loaded():Boolean {
			return _toLoad == 0;
		}
		
		public function FileReadCollection(source:Array=null)
		{
			super(source);
			
			addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
		}
		
		override public function addItemAt(item:Object, index:int):void {
			checkAdd(item);
			super.addItemAt(item, index);
		}
		
		override public function setItemAt(item:Object, index:int):Object {
			checkAdd(item);
			var result:Object = super.setItemAt(item, index);
			if (result != null)
				checkRemove(result);
			return result;
		}
		
		override public function removeItemAt(index:int):Object {
			var result:Object = super.removeItemAt(index)
			checkRemove(result);
			return result;
		}
		
		private function checkAdd(item:Object):void {
			if (item.hasOwnProperty(loadedProp) && !item.loaded)
				incUnloaded();
		}
		
		private function checkRemove(item:Object):void {
			if (item.hasOwnProperty(loadedProp) && !item.loaded)
				decUnloaded();
		}
		
		private function incUnloaded():void {
			_toLoad++;
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
		}
		
		private function decUnloaded():void {
			_toLoad--;
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			if (loaded)
				dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onCollectionChange(event:CollectionEvent):void {
			if (event.kind == CollectionEventKind.UPDATE) {
				for (var i:int = 0; i < event.items.length; i++) {
					var pce:PropertyChangeEvent = event.items[i] as PropertyChangeEvent;
					if (pce.property == loadedProp && pce.newValue != pce.oldValue) {
						if (pce.newValue)
							decUnloaded();
						else
							incUnloaded();
					}
				}
			}
		}
	}
}