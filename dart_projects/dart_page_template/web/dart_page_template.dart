import 'dart:html';
import 'dart:async';

//following is default dart code

void main() {
  
  //get header
  var headerUrl = "http://svg-developers.github.io/header.html";
  HttpRequest.getString(headerUrl).then((responseText)=>query("header").innerHtml = responseText);
  
  //Dartlang.org sample code
  query("#sample_text_id")
    ..text = "Click me!"
    ..onClick.listen(reverseText);
}

//Dartlang.org sample code
void reverseText(MouseEvent event) {
  var text = query("#sample_text_id").text;
  var buffer = new StringBuffer();
  for (int i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
  }
  query("#sample_text_id").text = buffer.toString();
}
