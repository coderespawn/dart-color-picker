library color_value_test;

import "package:color_picker/color_picker.dart";
import "package:unittest/unittest.dart";

void main() {
  group("Color Value:", () {
    
    test("parse_format_fff_1", () {
      var color = new ColorValue.from("#fff");
      expect(color.r, 0xff);
      expect(color.g, 0xff);
      expect(color.b, 0xff);
    });
    
    test("parse_format_fff_2", () {
      var color = new ColorValue.from("#ccc");
      expect(color.r, 0xcc);
      expect(color.g, 0xcc);
      expect(color.b, 0xcc);
    });
    
    test("parse_format_fff_3", () {
      var color = new ColorValue.from("#000");
      expect(color.r, 0);
      expect(color.g, 0);
      expect(color.b, 0);
    });

    test("parse_format_fff_caps", () {
      var color = new ColorValue.from("#FAD");
      expect(color.r, 0xff);
      expect(color.g, 0xaa);
      expect(color.b, 0xdd);
    });
    
    test("parse_format_fff_invalid_1", () {
      expect(() => new ColorValue.from("#-12"), throwsException);
    });
    
    test("parse_format_fff_invalid_2", () {
      expect(() => new ColorValue.from("#"), throwsException);
    });
    
    test("parse_format_fff_invalid_3", () {
      expect(() => new ColorValue.from("#0xf"), throwsException);
    });
    
    test("parse_format_ffffff_1", () {
      var color = new ColorValue.from("#ffffff");
      expect(color.r, 0xff);
      expect(color.g, 0xff);
      expect(color.b, 0xff);
    });
    
    test("parse_format_ffffff_2", () {
      var color = new ColorValue.from("#abcdef");
      expect(color.r, 0xab);
      expect(color.g, 0xcd);
      expect(color.b, 0xef);
    });

    test("parse_format_ffffff_3", () {
      var color = new ColorValue.from("#000000");
      expect(color.r, 0);
      expect(color.g, 0);
      expect(color.b, 0);
    });
    
    test("parse_format_ffffff_caps", () {
      var color = new ColorValue.from("#C0FFEE");
      expect(color.r, 0xc0);
      expect(color.g, 0xff);
      expect(color.b, 0xee);
    });
    

    test("parse_format_255_1", () {
      var color = new ColorValue.from("10, 123, 54");
      expect(color.r, 10);
      expect(color.g, 123);
      expect(color.b, 54);
    });
    
    test("parse_format_255_2", () {
      var color = new ColorValue.from("0, 0, 0");
      expect(color.r, 0);
      expect(color.g, 0);
      expect(color.b, 0);
    });
    
    test("parse_format_255_3", () {
      var color = new ColorValue.from("255, 255, 255");
      expect(color.r, 0xff);
      expect(color.g, 0xff);
      expect(color.b, 0xff);
    });
    
    test("parse_format_255_clamp", () {
      var color = new ColorValue.from("1000, -1000, 2000");
      expect(color.r, 0xff);
      expect(color.g, 0);
      expect(color.b, 0xff);
    });
    
  });
}



