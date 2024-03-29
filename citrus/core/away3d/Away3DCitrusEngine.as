package citrus.core.away3d {

	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;

	import citrus.core.CitrusEngine;
	import citrus.core.State;

	import flash.display.DisplayObject;
	import flash.events.Event;

	/**
	 * Extends this class if you create an Away3D based game. Don't forget to call <code>setUpAway3D</code> function.
	 * 
	 * <p>CitrusEngine can access to the Stage3D power thanks to the <a href="http://www.away3d.com/">Away3D Framework</a>.</p>
	 */
	public class Away3DCitrusEngine extends CitrusEngine {
		
		protected var _away3D:View3D;
		
		protected var _antiAliasing:Number = 1;
		protected var _enableDepthAndStencil:Boolean = false;

		public function Away3DCitrusEngine() {
			
			super();
		}

		override public function destroy():void {
			if (_away3D.stage3DProxy)				
				_away3D.stage3DProxy.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			
			super.destroy();
		}
		
		/**
		 * You should call this function to create your Away3D view. Away3DState is added on the Away3D's scene.
		 * @param debugMode If true, display a AwayStats class instance.
		 * @param antiAliasing The antialiasing value allows you to set the anti-aliasing (0 - 16), generally a value of 4 is totally acceptable.
		 * @param scene3D You may already have a Scene3D to set up.
		 * @param stage3DProxy If you want to use Starling, or multiple Away3D instance you need to use a Stage3DProxy.
		 */
		public function setUpAway3D(debugMode:Boolean = false, antiAliasing:uint = 4, scene3D:Scene3D = null, stage3DProxy:Stage3DProxy = null):void {
			
			_away3D = new View3D(scene3D);
			_away3D.antiAlias = _antiAliasing = antiAliasing;
			
			if (stage3DProxy) {
				_away3D.stage3DProxy = stage3DProxy;
				_away3D.shareContext = true;
				
				// we're probably using Starling for a 2D menu/interface, we must listen the enter frame on Stage3DProxy
				_away3D.stage3DProxy.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
			
			addChildAt(_away3D, _stateDisplayIndex);
			
			if (debugMode)
				addChild(new AwayStats(_away3D));
		}
		
		public function get away3D():View3D {
			return _away3D;
		}
		
		override protected function handleEnterFrame(e:Event):void {

			if (_away3D.scene) {
				
				if (_newState) {
					
					if (_state) {
						
						if (_state is Away3DState) {
							
							_state.destroy();
							_away3D.scene.removeChild(_state as Away3DState);
							
							// Remove Box2D or Nape debug view
							var debugView:DisplayObject = stage.getChildByName("debug view");
							if (debugView)
								stage.removeChild(debugView);
								
						} else {
							
							_state.destroy();
							removeChild(_state as State);
						}
					}
					
					if (_newState is Away3DState) {
						
						_state = _newState;
						_newState = null;
						
						if (_futureState)
							_futureState = null;
						
						else {						
							_away3D.scene.addChild(_state as Away3DState);
							_state.initialize();
						}
					}
				}
				
				if (_stateTransitionning && _stateTransitionning is Away3DState) {
					
					_futureState = _stateTransitionning;
					_stateTransitionning = null;
					
					_away3D.scene.addChild(_futureState as Away3DState);
					_futureState.initialize();
				}
			}
			
			if (_playing && (_state && _state is Away3DState) || (_futureState && _futureState is Away3DState))
				_away3D.render();
				
			super.handleEnterFrame(e);
		}
		
		override protected function handleStageResize(evt:Event):void {
			super.handleStageResize(evt);
			if (_away3D)
			{
				_away3D.stage3DProxy.configureBackBuffer(stage.stageWidth, stage.stageHeight, _antiAliasing, _enableDepthAndStencil);
				_away3D.stage3DProxy.viewPort.width = _away3D.width = stage.stageWidth;
				_away3D.stage3DProxy.viewPort.height = _away3D.height = stage.stageHeight;
			}
		}

	}
}
