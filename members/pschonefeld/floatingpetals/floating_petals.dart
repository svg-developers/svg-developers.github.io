import 'dart:html';
import 'dart:svg';
import 'dart:async';
import 'dart:math';
import 'package:box2d/box2d.dart';

final double SCALE = 30.0;

World _world;
Map<String,TransformItem> _items = new Map<String,TransformItem>();
num _x, _y;
var _random = new Random();
Vector _targetPointOfAttraction;

void main() {
  
  //get header
  var headerUrl = "http://svg-developers.github.io/header.html";
  HttpRequest.getString(headerUrl).then((responseText)=>query("header").innerHtml = responseText);

  _world = new World(new Vector(0.0,0.05),true,new DefaultWorldPool());
  
  //ground fixture
  FixtureDef fixDef = new FixtureDef();
  fixDef..density = 1
      ..friction = 1.7 
      ..restitution = 1.2;
  
  var svgRect = query("#floatingPetals").getBoundingClientRect();
  _targetPointOfAttraction = new Vector(
      (svgRect.left+(svgRect.width/2))/SCALE,
      (svgRect.top+(svgRect.height/3))/SCALE);
  var rect = query("#ground").getBoundingClientRect();
  fixDef.shape = new PolygonShape();
  fixDef.shape.setAsBox(rect.width/SCALE/2, rect.height/SCALE/2);
  //fixDef.shape = new CircleShape();
  //fixDef.shape.radius = 2.0/SCALE;    

  BodyDef bodyDef = new BodyDef();  
  bodyDef..type = BodyType.STATIC
      //..position.x = 250/SCALE//(rect.left+rect.width/2)/SCALE
      //..position.y = 871/SCALE;
      ..position.x = (rect.left+rect.width/2)/SCALE
      ..position.y = (rect.top-120)/SCALE;
  _world.createBody(bodyDef).createFixture(fixDef);

  //items
  bodyDef.type = BodyType.DYNAMIC;
  //use css selector to create a collection of svg elements to animate
  //(shapes defined as <path id="path_138" ...  d="..."/> )
  queryAll("[id^='path']").forEach((SvgElement e){
    
    //determine position of the shape in the box2d world
    var rect = e.getBoundingClientRect();
    fixDef.shape = new CircleShape();
    fixDef.shape.radius = 5.0/SCALE;    
    bodyDef.position.x = (rect.left+rect.width/2)/SCALE;
    bodyDef.position.y = rect.top/SCALE;
    
    //link the svg element to the fixture via the id
    bodyDef.userData = e.id;
    
    //TransformItem is a helper class for operating on the SVG Element
    //and is held in a Map for easy access, note the position is on 
    //SVG canvas not at world scale.
    TransformItem item = new TransformItem(e);
    item.center = new Vector(
        (rect.left+rect.width/2).toDouble(),
        (rect.top+rect.height/2).toDouble());
    _items[e.id] = item;

    //add the item to world
    Body b = _world.createBody(bodyDef);
    b.createFixture(fixDef);
    
    //playing with mass adds a jitter effect
    item.orginalMass = b.mass;  
    
    //add some user interaction
    e.onMouseOver.listen((_)=> _.currentTarget.attributes["opacity"] = "0.2");
    
  });

  requestAnimationFrame().then(update);  
}

Future requestAnimationFrame(){
  return window.animationFrame;
}

dynamic update(num highResTime){

  _world.step(1/50,10,10); 
  _world.clearForces();
  
  requestAnimationFrame().then(update);
  //iterate through each box body
  for(Body b = _world.bodyList; b != null; b = b.next){
    if(b.type!=BodyType.STATIC){
      
      //set up the relationship between body and point of attraction 
      Vector itemPosition = b.position;
      Vector targetPosition = _targetPointOfAttraction;
      Vector targetDistance = new Vector.zero(); 
      targetDistance.addLocal(itemPosition);
      targetDistance.subLocal(targetPosition);
      num finalDistance = targetDistance.length;
      targetDistance.negateLocal();
      //divsors reduce the magnitude of force
      targetDistance = new Vector(targetDistance.x/50,targetDistance.y/50);

      //get the svg element's helper object
      TransformItem path = _items[b.userData]; 
      
      //playing around with mass
      double multiplier = 1+1.1755*(_random.nextBool()?1:-1);
      b.mass = _random.nextBool()? b.mass * multiplier: path.orginalMass;
      
      //apply the attraction (comment this out for falling elements)      
      b.applyForce(targetDistance, b.position);
      
      //translate the position of the svg Element
      path.setTransform(
          new Vector(b.position.x, b.position.y),
          b.originTransform.rotation.toString());
      
      //play around with opacity for effect
      double opacity = double.parse(path.element.attributes["opacity"]);
      path.element.attributes["opacity"] = "${opacity + 0.02 * (_random.nextBool()?-1:1)}";
    }
  }

}

class TransformItem {
  Vector currentTranslate = new Vector.zero();
  Vector center = new Vector.zero();
  double orginalMass;
  SvgElement element;
  TransformItem(this.element);
  void setTransform(Vector originTransform, String rotation){
    num x = originTransform.x*SCALE - center.x;
    num y = originTransform.y*SCALE - center.y;
    this.element.attributes["transform"] = "translate($x,$y) rotate(${1*((x+y)/10)} ${x/2},${y/2})"; 
  }
}
