part of color_picker;

/** 
 * Draws the color grandient of a cross section of the HSV cylinder
 * based on the specified hue angle
 * http://en.wikipedia.org/wiki/HSL_and_HSV#Basic_principle
 */ 
class HsvGradientPicker {
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
  ColorValue color;

  /** The pure color calculated from the hue angle */
  ColorValue hueColor;
  
  /** Radius of the cursor circle in pixels */
  final cursorRadius = 4;
  
  /** Color change observers */
  ColorChangeListener colorChangeListener;
  
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  ImageData buffer;
  
  // Mouse handlers
  var _handlerMouseMoved;
  var _handlerMouseDown;
  var _handlerMouseUp;
  
  // The cursor position
  int _cursorX = 0;
  int _cursorY = 0;
  
  HsvGradientPicker(int width, int height, [this.color]) {
    canvas = new CanvasElement(width: width, height: height);
    canvas.classes.add("color-picker-hsv-gradient");
    context = canvas.context2d;
    if (color == null) {
      color = new ColorValue();
    }
    
    _handlerMouseDown = onMouseDown;
    _handlerMouseMoved = onMouseMoved;
    _handlerMouseUp = onMouseUp;
    canvas.on.mouseDown.add(_handlerMouseDown);
    
    _calculateHSV(true);
    _rebuildGradient();
    _draw();
    
    _notifyColorChanged();
  }
  
  /** Rebuilds the grandient in the buffer image */
  void _rebuildGradient() {
    buffer = context.createImageData(canvas.width, canvas.height);
    var data = buffer.data;
    final height = buffer.height;
    final width = buffer.width;
    for (var h = 0; h < height; h++) {
      num intensity = (height - 1 - h) / (height - 1);
      int greyScaleComponent = (255 * intensity).toInt();
      var startColor = new ColorValue.fromRGB(greyScaleComponent, greyScaleComponent, greyScaleComponent); 
      var endColor = hueColor * intensity;
      for (var w = 0; w < width; w++) {
        num pixelIntensity = w / (width - 1);
        var pixelColor = startColor + (endColor - startColor) * pixelIntensity;
        int index = (width * h + w) * 4;
        buffer.data[index + 0] = pixelColor.r;
        buffer.data[index + 1] = pixelColor.g;
        buffer.data[index + 2] = pixelColor.b;
        buffer.data[index + 3] = 255;
      }
    }

    // Calculate the position of the cursor in the canvas
    _cursorX = (canvas.width * saturation).toInt();
    _cursorY = (canvas.height * (1 - value / 255)).toInt();
  }
  
  /** Calcualtes the HSV components of the current color */
  void _calculateHSV([bool calculateHue = false]) {
    if (calculateHue) {
      // Calculate the hue (H) component in the HSV color space
      final alpha = (2 * color.r - color.g - color.b) / 2;
      final beta = sqrt(3) / 2 * (color.g - color.b);
      hue = atan2(beta, alpha);
      chroma = sqrt(alpha * alpha + beta * beta);
    }
    
    // Get the value (V) component in the HSV color space 
    value = _getHsvValueComponent(color);
    
    // Get the saturation (S) component 
    saturation = (chroma == 0) ? 0 : chroma / value;
    
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
  
  /** Draws the cursor on the currently selected color position */
  _drawCursor() {
    
    // Find out the luminosity of the selected color to choose an 
    // appropriate color for the cursor
    final luma = _getColorLuma(color);
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


  /** The position of the mouse the dragging started */
  MouseEvent startMouseEvent;
  int startMouseX;
  int startMouseY;
  
  // Mouse Event Handlers
  void onMouseDown(MouseEvent e) {
    startMouseEvent = e;
    startMouseX = e.offsetX;
    startMouseY = e.offsetY;
    _setCursorPosition(e);

    // Listen to global mouse move events
    document.body.on.mouseMove.add(_handlerMouseMoved);
    document.body.on.mouseUp.add(_handlerMouseUp);
    
    document.body.classes.add("unselectable");
  }
  
  void onMouseMoved(MouseEvent e) {
    _setCursorPosition(e);
  }
  
  void onMouseUp(MouseEvent e) {
    // Stop listening to global mouse events 
    document.body.on.mouseMove.remove(_handlerMouseMoved);
    document.body.on.mouseUp.remove(_handlerMouseUp);
    document.body.classes.remove("unselectable");
  }
  
  void _setCursorPosition(MouseEvent event) {
    // Get the cursor bounds clamped to the canvas rectangle
    _cursorX = startMouseX + event.pageX - startMouseEvent.pageX;
    _cursorY = startMouseY + event.pageY - startMouseEvent.pageY;
    _cursorX = max(0, min(canvas.width, _cursorX));
    _cursorY = max(0, min(canvas.height, _cursorY));
  
    num nx = _cursorX / canvas.width;
    num ny = _cursorY / canvas.height;
    
    // Calculate the new color value
    final newValue = hueColor * (1 - ny);
    
    final intensity = ((1 - ny) * 255).round().toInt();
    var startColor = new ColorValue.fromRGB(intensity, intensity, intensity);
    var endColor = newValue;
    
    color = startColor + (endColor - startColor) * nx;
    _calculateHSV();
    
    // Notify the observers that the color has changed
    _notifyColorChanged();
    
    // Redraw the scene
    _draw();
  }

  /** Notify the observer that the color has changed */
  void _notifyColorChanged() {
    if (colorChangeListener != null) {
      colorChangeListener.onColorChanged(color);
    }
  }
}
