part of color_picker;

/**
 * Lets the user choose a hue color from the slider
 * The Hue angle in the HSV cylinder is calculated and
 * notified to the observers
 */
class HueSlider {
  /** Listener for hue value change events */
  HueChangeListener hueChangelistener;

  /** The canvas that displays the hue colors */
  CanvasElement canvas;

  /** The current hue angle in radians */
  num _hueAngle = 0;

  num get hueAngle => _hueAngle;
  set hueAngle(num value) {
    _hueAngle = value;
    _draw();
  }

  /** Listener for mouse events in the canvas element */
  _MouseListener mouseListener;

  /** The cached gradient object that represents the hue colors */
  CanvasGradient gradient;

  HueSlider(int width, int height) {
    canvas = new CanvasElement(width: width, height: height);
    canvas.classes.add("color-picker-hue-slider");

    mouseListener = new _MouseListener(canvas, true);
    mouseListener.onMouseDown = onMouseDown;
    mouseListener.onMouseMoved = onMouseMoved;

    // Build and cache the hue color gradient object
    _buildGradient();

    // Draw the hue slider
    _draw();
  }

  void _draw() {
    final context = canvas.context2D;
    context.fillStyle = gradient;
    context.fillRect(0, 0, canvas.width, canvas.height);

    // Find the appropriate color for the cursor
    String cursorColor = "black";

    // Find the hue color
    final hueColor = _getHueColor(_hueAngle);

    // Find the luminosity of the hue color
    final hueLuma = _getColorLuma(hueColor);
    if (hueLuma < 0.5) {
      // Color is too dark in this region.  Choose a bright cursor color
      cursorColor = "white";
    }

    // Draw the cursor at the prefered location
    final y = canvas.height * _hueAngle / (2 * PI) + 0.5;
    context.save();
    context.strokeStyle = cursorColor;
    context.lineWidth = 1;
    context.beginPath();
    context.moveTo(0, y);
    context.lineTo(canvas.width, y);
    context.closePath();
    context.stroke();

    // Draw rectangles on the side
    final triangleSize = 4;
    context.fillStyle = cursorColor;
    // Draw the left triangle
    context.beginPath();
    context.moveTo(0, y - triangleSize);
    context.lineTo(triangleSize, y);
    context.lineTo(0, y + triangleSize);
    context.closePath();
    context.fill();

    // Draw the right triangle
    context.beginPath();
    context.moveTo(canvas.width, y - triangleSize);
    context.lineTo(canvas.width - triangleSize, y);
    context.lineTo(canvas.width, y + triangleSize);
    context.closePath();
    context.fill();
    context.restore();
  }

  /** Builds the hue color gradient object.   The gradient is saved for later reuse */
  void _buildGradient() {
    var hueColors = [
        new ColorValue.fromRGB(255, 0,   0),
        new ColorValue.fromRGB(255, 255, 0),
        new ColorValue.fromRGB(0,   255, 0),
        new ColorValue.fromRGB(0,   255, 255),
        new ColorValue.fromRGB(0,   0,   255),
        new ColorValue.fromRGB(255, 0,   255),
        new ColorValue.fromRGB(255, 0,   0)
    ];

    // Create a hue color gradient object to draw in the canvas
    final context = canvas.context2D;
    gradient = context.createLinearGradient(0, 0, 0, canvas.height);

    // Calculate the gradient stop delta for each color
    final gradientStopDelta = 1 / (hueColors.length - 1);
    num gradientStop = 0;
    for (var i = 0; i < hueColors.length - 1; i++) {
      gradient.addColorStop(gradientStop, hueColors[i].toString());
      gradientStop += gradientStopDelta;
    }
    // Add the last one manually to avoid precision issues
    gradient.addColorStop(1.0, hueColors.last.toString());
  }

  void onMouseDown(int x, int y) {
    _updateHue(x, y);
  }
  void onMouseMoved(int x, int y) {
    _updateHue(x, y);
  }

  void _updateHue(int x, int y) {
    y %= canvas.height;
    num ratio = y / canvas.height;
    _hueAngle = 2 * PI * ratio;

    // Notify the observer
    if (hueChangelistener != null) {
      hueChangelistener.onHueChanged(_hueAngle);
    }

    // Redraw with the new cursor position
    _draw();
  }
}


/** Listen to Hue angle change events */
abstract class HueChangeListener {
  /**
   * Called whenever the hue angle is changed.
   * [angle] is in radians
   */
  void onHueChanged(num angle);
}
