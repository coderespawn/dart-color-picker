part of color_picker;

class ColorValue {
  /** Red color component. Value ranges from [0..255] */
  int r;

  /** Green color component. Value ranges from [0..255] */
  int g;
  
  /** Blue color component. Value ranges from [0..255] */
  int b;
  
  /** 
   * Parses the color value with the following format:
   *    "#fff"
   *    "#ffffff"
   *    "255, 255, 255"
   */
  ColorValue.from(String value) {
    if (value.startsWith("#")) {
      // Remove the #
      value = value.substring(1);
      _parseHex(value);
    }
    else if (value.contains(",")) {
      List<String> tokens = value.split(",");
      if (tokens.length < 3) {
        throw new Exception("Invalid color value format");
      }
      r = int.parse(tokens[0]);
      g = int.parse(tokens[1]);
      b = int.parse(tokens[2]);
    }
  }
  
  ColorValue() : r = 0, g = 0, b = 0;
  ColorValue.fromRGB(this.r, this.g, this.b);
  ColorValue.copy(ColorValue other) {
    this.r = other.r;
    this.g = other.g;
    this.b = other.b;
  }
  
  void set(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  /** 
   * Parses the color value in the format FFFFFF or FFF 
   * and is not case-sensitive 
   */
  void _parseHex(String hex) {
    if (hex.length != 3 || hex.length != 6) {
      throw new Exception("Invalid color hex format");
    }
    
    if (hex.length == 3) {
      var a = hex.substring(0, 0);
      var b = hex.substring(1, 1);
      var c = hex.substring(2, 2);
      hex = "$a$a$b$b$c$c";
    }
    var hexR = hex.substring(0, 1);
    var hexG = hex.substring(2, 3);
    var hexB = hex.substring(4, 5);
    r = int.parse("0x$hexR");
    g = int.parse("0x$hexG");
    b = int.parse("0x$hexB");
  }
  
  ColorValue operator* (num value) {
    return new ColorValue.fromRGB(
        (r * value).toInt(), 
        (g * value).toInt(), 
        (b * value).toInt()); 
  }
  ColorValue operator+ (ColorValue other) {
    return new ColorValue.fromRGB(
        r + other.r, 
        g + other.g, 
        b + other.b); 
  }

  ColorValue operator- (ColorValue other) {
    return new ColorValue.fromRGB(
        r - other.r, 
        g - other.g, 
        b - other.b); 
  }

  String toString() => "rgba($r, $g, $b, 1.0)";
  String toRgbString() => "$r, $g, $b";
}


class HsvColor {
  
}