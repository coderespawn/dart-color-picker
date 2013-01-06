part of color_picker;

/** 
 * Returns the color intensity (luma) for the specified [color]
 * Value ranges from [0..1]
 */
num _getColorLuma(ColorValue color) {
  return (0.3 * color.r + 0.59 * color.g + 0.11 * color.b) / 255;
}

/** Gets the Value (V) component in the HSV color space */
num _getHsvValueComponent(ColorValue color) {
  return max(max(color.r, color.g), color.b);
}

/** 
 * Get the pure color from the Hue [angle].
 * [angle] is in radians
 */
ColorValue _getHueColor(num angle) {
  var slots = [
      new ColorValue.fromRGB(255, 0,   0),
      new ColorValue.fromRGB(255, 255, 0),
      new ColorValue.fromRGB(0,   255, 0),
      new ColorValue.fromRGB(0,   255, 255),
      new ColorValue.fromRGB(0,   0,   255),
      new ColorValue.fromRGB(255, 0,   255)
  ];

  // Each slot is 60 degrees.  Find out which slot this angle lies in
  // http://en.wikipedia.org/wiki/Hue
  int degrees = (angle * 180 / PI).round().toInt();
  degrees %= 360;
  final slotPosition = degrees / 60;
  final slotIndex = slotPosition.toInt();
  final slotDelta = slotPosition - slotIndex;
  final startColor = slots[slotIndex];
  final endColor = slots[(slotIndex + 1) % slots.length];
  return startColor + (endColor - startColor) * slotDelta;
}
