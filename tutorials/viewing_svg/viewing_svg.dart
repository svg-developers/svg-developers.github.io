import 'dart:html';

void main() {
  //get header
  var headerUrl = "http://svg-developers.github.io/header.html";
  HttpRequest.getString(headerUrl).then((responseText)=>query("header").innerHtml = responseText);
}


