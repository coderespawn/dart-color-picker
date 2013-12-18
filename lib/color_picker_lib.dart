part of color_picker;

class ColorPicker {
  /** The base element of the color picker */
  DivElement element;

  /** The initial color that was provided to the color picker */
  ColorValue initialColor;

  set currentColor(ColorValue value) {
    picker.color = value;
    hueSlider.hueAngle = picker.hue;
  }
  ColorValue get currentColor => picker.color;

  /** The HSV Color picker gradient */
  HsvGradientPicker picker;

  /** The Hue color slider */
  HueSlider hueSlider;

  /** Displays the information about the selected color */
  ColorPickerInfoBox infoBox;

  /** Notify any observers listening for color change events */
  ColorChangeListener _colorChangeListener;
  ColorChangeListener get colorChangeListener => _colorChangeListener;
  set colorChangeListener(ColorChangeListener value) {
    _colorChangeListener = value;
    // notify the new listener of the current color
    picker._notifyColorChanged();
  }

  /**
   * Creates a new Color picker control. Set [showInfoBox] to show
   * or hide the info box on the right.
   */
  ColorPicker(int size, {this.initialColor, bool showInfoBox}) {
    picker = new HsvGradientPicker(size, size, initialColor);
    initialColor = new ColorValue.copy(picker.color);

    hueSlider = new HueSlider(16, size);
    picker.colorChangeListener = onColorChanged;
    hueSlider.hueChangelistener = picker;
    hueSlider.hueAngle = picker.hue;

    infoBox = new ColorPickerInfoBox(this);
    infoBox.refresh();

    element = new DivElement();
    element.classes.add("color-picker");

    element.nodes.add(picker.canvas);
    element.nodes.add(hueSlider.canvas);
    element.nodes.add(infoBox.elementBase);

    if (showInfoBox != null && !showInfoBox) {
      infoBox.elementBase.style.display = "none";
    }

    // Add a dummy element in the end to clear the floats from the previous elements
    var dummyElement = new DivElement();
    dummyElement.style.clear = "both";
    element.nodes.add(dummyElement);
  }

  void onColorChanged(ColorValue color, num hue, num saturation, num brightness) {
    infoBox.refresh();
    if (colorChangeListener != null) {
      colorChangeListener(color, hue, saturation, brightness);
    }
  }

  /** Dispose off the color picker by removing it from the DOM. */
  void dispose() {
    element.remove();
  }
}

class ColorPickerInfoBox {
  ColorPicker colorPicker;

  ColorValue get color => colorPicker.picker.color;
  set color(ColorValue value) {
    colorPicker.picker.color = value;
    colorPicker.hueSlider.hueAngle = colorPicker.picker.hue;
    refresh();
  }

  Element elementBase;

  EntryControl entryRed;
  EntryControl entryGreen;
  EntryControl entryBlue;

  EntryControl entryHue;
  EntryControl entrySaturation;
  EntryControl entryBrightness;

  /** The base element for the preview controls */
  DivElement previewBase;

  /** The preview color of the intial color */
  DivElement previewPrevious;

  /** The preview color of the current color */
  DivElement previewCurrent;

  ColorPickerInfoBox(this.colorPicker) {
    previewBase = new DivElement();
    previewPrevious = new DivElement();
    previewCurrent = new DivElement();
    previewBase.classes.add("color-picker-preview-base");
    previewPrevious.classes.add("color-picker-preview-previous");
    previewCurrent.classes.add("color-picker-preview-current");
    previewBase.nodes.add(previewPrevious);
    previewBase.nodes.add(previewCurrent);

    entryRed = new EntryControl("R", () => color.r.toString(), (String value) {
      final _color = color;
      _color.r = max(0, min(255, int.parse(value)));
      color = _color;
    });

    entryGreen = new EntryControl("G", () => color.g.toString(), (String value) {
      final _color = color;
      _color.g = max(0, min(255, int.parse(value)));
      color = _color;
    });

    entryBlue = new EntryControl("B", () => color.b.toString(), (String value) {
      final _color = color;
      _color.b = max(0, min(255, int.parse(value)));
      color = _color;
    });

    entryHue = new EntryControl("H", () {
          num hue = colorPicker.picker.hue;
          int degrees = (hue * 180 ~/ PI);
          return degrees.toString();
        }, (String value) {});
    entryHue.elementBase.style.marginTop = "6px";

    entrySaturation= new EntryControl("S", () {
      num saturation = colorPicker.picker.saturation;
      int saturationInt = (saturation * 255).round().toInt();
      return saturationInt.toString();
    }, (String value) {});

    entryBrightness = new EntryControl("V", () => colorPicker.picker.value.toInt().toString(), (String value) {});

    elementBase = new DivElement();
    elementBase.classes.add("color-picker-info-box");

    // Add the elements to the info box DOM element
    elementBase.nodes.add(previewBase);
    elementBase.nodes.add(entryRed.elementBase);
    elementBase.nodes.add(entryGreen.elementBase);
    elementBase.nodes.add(entryBlue.elementBase);
    elementBase.nodes.add(entryHue.elementBase);
    elementBase.nodes.add(entrySaturation.elementBase);
    elementBase.nodes.add(entryBrightness.elementBase);

  }

  void refresh() {
    entryRed.refresh();
    entryGreen.refresh();
    entryBlue.refresh();
    entryHue.refresh();
    entrySaturation.refresh();
    entryBrightness.refresh();

    // refresh the preview color
    _setPreviewColor(previewPrevious, colorPicker.initialColor);
    _setPreviewColor(previewCurrent, colorPicker.picker.color);
  }

  void _setPreviewColor(Element element, ColorValue color) {
    element.style.backgroundColor = color.toString();
  }
}

typedef void ColorChangeListener(ColorValue color, num hue, num saturation, num brightness);

