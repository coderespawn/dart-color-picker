import 'dart:html';
import '../../color_picker/color_picker_lib.dart';

void main() {
  var picker = new HsvGradientPicker(256, 256, new ColorValue.fromRGB(245, 200, 150));
  document.body.nodes.add(picker.canvas);
  picker.colorChangeListener = new TestObserver();
}


class TestObserver implements ColorChangeListener {
  DivElement element;
  TestObserver() {
    element = new DivElement();
    element.style.width = "256px";
    element.style.height = "40px";
    element.style.border = "1px solid black";
    document.body.nodes.add(element);
  }
  void onColorChanged(ColorValue color) {
    element.style.backgroundColor = "rgba(${color.r}, ${color.g}, ${color.b}, 1.0)";
  }
}