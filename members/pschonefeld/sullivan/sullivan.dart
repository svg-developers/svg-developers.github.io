import 'dart:html';
import 'dart:async';
import 'dart:math';

//following is default dart code

void main() {
  
  //get header
  var headerUrl = "http://svg-developers.github.io/header.html";
 HttpRequest.getString(headerUrl).then((responseText)=>query("header").innerHtml = responseText);

  var count = 51;
  var multiplier = 1;
  var rng = new Random();
  var timer = new Timer.periodic(const Duration(milliseconds: 100), (t){
    if(count==120 || count == 50){
      multiplier *= -1;
    }
    count += 1 * multiplier;
    query("#fltrTexture1").attributes["filterRes"] = "${count}";    
    query("#fltrprimTurbulence").attributes["seed"] = "${rng.nextInt(10)}"; 
  });  

}

