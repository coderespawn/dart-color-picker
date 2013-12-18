part of color_picker;

/**
 * Draws the color grandient of a cross section of the HSV cylinder
 * based on the specified hue angle
 * http://en.wikipedia.org/wiki/HSL_and_HSV#Basic_principle
 */
class HsvGradientPicker implements HueChangeListener {
  /**
   * The hue component of the color. This is the angle in the HSV cylinder
   * and is represented in radians
   */
  num hue;

  /** The chroma component */
  num chroma;

  /** The Saturation component (x-axis). Value is in the range [0..1] */
  num saturation;

  /**
   * The value component. This is the maximum of R, G, B
   * and is in the range [0..1].  This field represents the (y-axis)
   * in the gradient
   */
  num value;

  /** The current color value selected on the widget */
  ColorValue _color;

  ColorValue get color => _color;
  set color(ColorValue value) {
    _color = value;
    _rebuildColor();
    _draw();
  }

  /** The pure color calculated from the hue angle */
  ColorValue hueColor;

  /** Radius of the cursor circle in pixels */
  final cursorRadius = 4;

  /** Color change observers */
  ColorChangeListener colorChangeListener;

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  ImageData buffer;

  // The cursor position
  int _cursorX = 0;
  int _cursorY = 0;

  /** Listener for mouse events in the canvas element */
  _MouseListener mouseListener;

  HsvGradientPicker(int width, int height, [this._color]) {
    canvas = new CanvasElement(width: width, height: height);
    canvas.classes.add("color-picker-hsv-gradient");
    context = canvas.context2D;
    if (_color == null) {
      _color = new ColorValue();
    }

    mouseListener = new _MouseListener(canvas, true);
    mouseListener.onMouseDown = onMouseDown;
    mouseListener.onMouseMoved = onMouseMoved;

    _rebuildColor();
    _draw();

    _notifyColorChanged();
  }

  /** Recalcualtes the HSV and rebuilds the color gradient based on the new color */
  void _rebuildColor() {
    _calculateHSV(true);
    _rebuildGradient();

    // Calculate the position of the cursor in the canvas
    _cursorX = (canvas.width * saturation).toInt();
    _cursorY = (canvas.height * (1 - value / 255)).toInt();
  }

  /** Rebuilds the grandient in the buffer image */
  void _rebuildGradient() {
    buffer = context.createImageData(canvas.width, canvas.height);
    final height = buffer.height;
    final width = buffer.width;
    final intensityDelta = 1 / (width - 1);
    final _buffer = buffer.data;
    int index = 0;
    for (var h = 0; h < height; h++) {
      num intensity = (height - 1 - h) / (height - 1);
      int greyScaleComponent = (255 * intensity).toInt();
      var startColor = new ColorValue.fromRGB(greyScaleComponent, greyScaleComponent, greyScaleComponent);
      var endColor = hueColor * intensity;
      num pixelIntensity = 0;
      for (var w = 0; w < width; w++) {
        final pixelColor = startColor + (endColor - startColor) * pixelIntensity;
        _buffer[index++] = pixelColor.r;
        _buffer[index++] = pixelColor.g;
        _buffer[index++] = pixelColor.b;
        _buffer[index++] = 255;
        pixelIntensity += intensityDelta;
      }
    }
  }

  /** Calcualtes the HSV components of the current color */
  void _calculateHSV([bool calculateHue = false]) {
    // Get the value (V) component in the HSV color space
    value = _getHsvValueComponent(_color);

    if (calculateHue) {
      // Calculate the hue (H) component in the HSV color space
      final alpha = (2 * _color.r - _color.g - _color.b) / 2;
      final beta = sqrt(3) / 2 * (_color.g - _color.b);
      hue = atan2(beta, alpha);
      if (hue < 0) {
        hue += PI * 2;
      }

      chroma = sqrt(alpha * alpha + beta * beta);

      // Get the saturation (S) component
      saturation = (chroma == 0) ? 0 : chroma / value;

    }


    /** Get the pure color from the hue angle */
    hueColor = _getHueColor(hue);
  }

  /**
   * Draws the buffered gradient image on to the canvas
   * Also draws the selected color value
   */
  void _draw() {
    context.putImageData(buffer, 0, 0);
    _drawCursor();
  }

  /**
   * Implements HueChagneListner. Called whenever the hue angle is changed.
   * [angle] is in radians
   */
  void onHueChanged(num angle) {
    hue = angle;

    /** Get the pure color from the hue angle */
    hueColor = _getHueColor(hue);

    _recalculateColorFromCursor();
    // Update the selected color since the hue has changed
//    _recalculateColor();

    // Rebuild the gradient and redraw
    _rebuildGradient();
    _draw();
    _notifyColorChanged();
  }

  /** Draws the cursor on the currently selected color position */
  _drawCursor() {

    // Find out the luminosity of the selected color to choose an
    // appropriate color for the cursor
    final luma = _getColorLuma(_color);
    var cursorColor = "black";
    if (luma < 0.5) {
      // color around this area is too dark. make the cursor color white
      cursorColor = "white";
    }
    context.strokeStyle = cursorColor;
    context.beginPath();
    context.arc(_cursorX, _cursorY, cursorRadius, 0 , 2 * PI, false);
    context.closePath();
    context.stroke();
  }


  // Mouse Event Handlers
  void onMouseDown(int x, int y) {
    _setCursorPosition(x, y);
  }

  void onMouseMoved(int x, int y) {
    _setCursorPosition(x, y);
  }

  void _setCursorPosition(int x, int y) {
    // Get the cursor bounds clamped to the canvas rectangle
    _cursorX = x;
    _cursorY = y;
    _recalculateColorFromCursor();
    _calculateHSV();
    _notifyColorChanged();
    _draw();
  }

  void _recalculateColorFromCursor() {
    saturation = _cursorX / canvas.width;
    value = (canvas.height - _cursorY) / canvas.height * 255;

    // Normalize the value
    final num nvalue = value / 255;
    // Calculate the new color value (V) component of HSV
    final ColorValue valueColor = hueColor * nvalue;

    final intensity = (nvalue * 255).round().toInt();
    var startColor = new ColorValue.fromRGB(intensity, intensity, intensity);
    var endColor = valueColor;
    _color = startColor + (endColor - startColor) * saturation;
  }

  /** Notify the observer that the color has changed */
  void _notifyColorChanged() {
    if (colorChangeListener != null) {
      colorChangeListener(_color, hue, saturation, value);
    }
  }
}
