import 'dart:html';
import 'package:color_picker/color_picker.dart';

void main() {
  window.onLoad.listen((e) => _create());
}

void _create() {
  // Large Color picker.  The size is configurable.  Set to 256 for pixel perfect color range
  var largeColorPicker = new ColorPicker(256);
  query("#large_picker").nodes.add(largeColorPicker.element);

  // Smaller color pickers can be created by specifying a smaller dimension.
  // The info box on the right can be hidden to save space
  // An initial color can be specifed while instantiating the color picker
  var smallColorPicker = new ColorPicker(128, showInfoBox: false, initialColor: new ColorValue.fromRGB(60, 190, 220));
  query("#small_picker").nodes.add(smallColorPicker.element);
  // Listen for color change events and update the UI
  smallColorPicker.colorChangeListener = (ColorValue color, num hue, num saturation, num brightness) {
    query("#small_color_value").innerHtml = color.toString();
  };


  // Specify an even smaller size for the color picker. Hide the info box
  var tinyColorPicker = new ColorPicker(64, showInfoBox: false);
  query("#tiny_picker").nodes.add(tinyColorPicker.element);
  // Listen for color change events
  tinyColorPicker.colorChangeListener = (ColorValue color, num hue, num saturation, num brightness) {
    query("#tiny_color_value").innerHtml = color.toString();
  };
}
