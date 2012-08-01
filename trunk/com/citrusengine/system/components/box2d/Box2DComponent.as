package com.citrusengine.system.components.box2d {

	import Box2DAS.Collision.Shapes.b2CircleShape;
	import Box2DAS.Collision.Shapes.b2PolygonShape;
	import Box2DAS.Collision.Shapes.b2Shape;
	import Box2DAS.Common.V2;
	import Box2DAS.Dynamics.b2Body;
	import Box2DAS.Dynamics.b2BodyDef;
	import Box2DAS.Dynamics.b2Fixture;
	import Box2DAS.Dynamics.b2FixtureDef;

	import com.citrusengine.core.CitrusEngine;
	import com.citrusengine.physics.Box2D;
	import com.citrusengine.physics.Box2DCollisionCategories;
	import com.citrusengine.system.Component;

	import flash.display.MovieClip;

	/**
	 * @author Aymeric
	 */
	public class Box2DComponent extends Component {
		
		protected var _box2D:Box2D;
		protected var _bodyDef:b2BodyDef;
		protected var _body:b2Body;
		protected var _shape:b2Shape;
		protected var _fixtureDef:b2FixtureDef;
		protected var _fixture:b2Fixture;
		
		protected var _inverted:Boolean = false;
		protected var _parallax:Number = 1;
		protected var _animation:String = "";
		protected var _visible:Boolean = true;
		protected var _x:Number = 0;
		protected var _y:Number = 0;
		protected var _view:* = MovieClip;
		protected var _rotation:Number = 0;
		protected var _width:Number = 1;
		protected var _height:Number = 1;
		protected var _radius:Number;
		
		private var _group:Number = 0;
		private var _offsetX:Number = 0;
		private var _offsetY:Number = 0;
		private var _registration:String = "center";

		public function Box2DComponent(name:String, params:Object = null) {
			
			_box2D = CitrusEngine.getInstance().state.getFirstObjectByType(Box2D) as Box2D;
			
			super(name, params);
			
			defineBody();
			createBody();
			createShape();
			defineFixture();
			createFixture();
			defineJoint();
			createJoint();
		}
		
		override public function destroy():void {
			
			_body.destroy();
			_fixtureDef.destroy();
			_shape.destroy();
			_bodyDef.destroy();
			
			super.destroy();
		}
		
		public function get x():Number
		{
			if (_body)
				return _body.GetPosition().x * _box2D.scale;
			else
				return _x * _box2D.scale;
		}
		
		[Property(value="0")]
		public function set x(value:Number):void
		{
			_x = value / _box2D.scale;
			
			if (_body)
			{
				var pos:V2 = _body.GetPosition();
				pos.x = _x;
				_body.SetTransform(pos, _body.GetAngle());
			}
		}
			
		public function get y():Number
		{
			if (_body)
				return _body.GetPosition().y * _box2D.scale;
			else
				return _y * _box2D.scale;
		}
		
		[Property(value="0")]
		public function set y(value:Number):void
		{
			_y = value / _box2D.scale;
			
			if (_body)
			{
				var pos:V2 = _body.GetPosition();
				pos.y = _y;
				_body.SetTransform(pos, _body.GetAngle());
			}
		}
			
		public function get parallax():Number
		{
			return _parallax;
		}
		
		[Property(value="1")]
		public function set parallax(value:Number):void
		{
			_parallax = value;
		}
		
		public function get rotation():Number
		{
			if (_body)
				return _body.GetAngle() * 180 / Math.PI;
			else
				return _rotation * 180 / Math.PI;
		}
		
		[Property(value="0")]
		public function set rotation(value:Number):void
		{
			_rotation = value * Math.PI / 180;
			
			if (_body)
				_body.SetTransform(_body.GetPosition(), _rotation); 
		}
			
		public function get group():Number
		{
			return _group;
		}
		
		[Property(value="0")]
		public function set group(value:Number):void
		{
			_group = value;
		}
		
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
		}
		
		public function get view():*
		{
			return _view;
		}
		
		[Property(value="", browse="true")]
		public function set view(value:*):void
		{
			_view = value;
		}
		
		public function get animation():String
		{
			return _animation;
		}
		
		public function get inverted():Boolean
		{
			return _inverted;
		}
		
		public function get offsetX():Number
		{
			return _offsetX;
		}
		
		[Property(value="0")]
		public function set offsetX(value:Number):void
		{
			_offsetX = value;
		}
		
		public function get offsetY():Number
		{
			return _offsetY;
		}
		
		[Property(value="0")]
		public function set offsetY(value:Number):void
		{
			_offsetY = value;
		}
		
		public function get registration():String
		{
			return _registration;
		}
		
		[Property(value="center")]
		public function set registration(value:String):void
		{
			_registration = value;
		}
		
		/**
		 * This can only be set in the constructor parameters. 
		 */		
		public function get width():Number
		{
			return _width * _box2D.scale;
		}
		
		[Property(value="30")]
		public function set width(value:Number):void
		{
			_width = value / _box2D.scale;
			
			if (_initialized)
			{
				trace("Warning: You cannot set " + this + " width after it has been created. Please set it in the constructor.");
			}
		}
		
		/**
		 * This can only be set in the constructor parameters. 
		 */	
		public function get height():Number
		{
			return _height * _box2D.scale;
		}
		
		[Property(value="30")]
		public function set height(value:Number):void
		{
			_height = value / _box2D.scale;
			
			if (_initialized)
			{
				trace("Warning: You cannot set " + this + " height after it has been created. Please set it in the constructor.");
			}
		}
		
		/**
		 * This can only be set in the constructor parameters. 
		 */	
		public function get radius():Number
		{
			return _radius * _box2D.scale;
		}
		
		/**
		 * The object has a radius or a width & height. It can't have both.
		 */
		[Property(value="")]
		public function set radius(value:Number):void
		{
			_radius = value / _box2D.scale;
			
			if (_initialized)
			{
				trace("Warning: You cannot set " + this + " radius after it has been created. Please set it in the constructor.");
			}
		}
		
		/**
		 * A direction reference to the Box2D body associated with this object.
		 */
		public function get body():b2Body
		{
			return _body;
		}
		
		/**
		 * This method will often need to be overriden to provide additional definition to the Box2D body object. 
		 */		
		protected function defineBody():void
		{
			_bodyDef = new b2BodyDef();
			_bodyDef.type = b2Body.b2_dynamicBody;
			_bodyDef.position.v2 = new V2(_x, _y);
			_bodyDef.angle = _rotation;
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D body object. 
		 */	
		protected function createBody():void
		{
			_body = _box2D.world.CreateBody(_bodyDef);
			_body.SetUserData(this);
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D shape object.
		 * The PhysicsObject creates a rectangle by default if the radius it not defined, but you can replace this method's
		 * definition and instead create a custom shape, such as a line or circle.
		 */	
		protected function createShape():void
		{
			if (_radius) {
				_shape = new b2CircleShape();
				b2CircleShape(_shape).m_radius = _radius;
			} else {
				_shape = new b2PolygonShape();
				b2PolygonShape(_shape).SetAsBox(_width / 2, _height / 2);
			}
		}
		
		/**
		 * This method will often need to be overriden to provide additional definition to the Box2D fixture object. 
		 */	
		protected function defineFixture():void
		{
			_fixtureDef = new b2FixtureDef();
			_fixtureDef.shape = _shape;
			_fixtureDef.density = 1;
			_fixtureDef.friction = 0.6;
			_fixtureDef.restitution = 0.3;
			_fixtureDef.filter.categoryBits = Box2DCollisionCategories.Get("Level");
			_fixtureDef.filter.maskBits = Box2DCollisionCategories.GetAll();
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D fixture object. 
		 */	
		protected function createFixture():void
		{
			_fixture = _body.CreateFixture(_fixtureDef);
		}
		
		/**
		 * This method will often need to be overriden to provide additional definition to the Box2D joint object.
		 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
		 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
		 * and b2Joint object.
		 */	
		protected function defineJoint():void
		{
			
		}
		
		/**
		 * This method will often need to be overriden to customize the Box2D joint object. 
		 * A joint is not automatically created, because joints require two bodies. Therefore, if you need to create a joint,
		 * you will also need to create additional bodies, fixtures and shapes, and then also instantiate a new b2JointDef
		 * and b2Joint object.
		 */		
		protected function createJoint():void
		{

		}
	}
}
