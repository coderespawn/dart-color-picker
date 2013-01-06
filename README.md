# Dart Color Picker

The Color Picker control creates a Adobe Photoshop style [HSV](http://en.wikipedia.org/wiki/HSL_and_HSV) color picker where the RGB values can be picked based on the Hue, Saturation and Value parameters.

![Color Picker](https://raw.github.com/coderespawn/dart-color-picker/master/docs/images/color_picker_large.png)

Create the color picker by instantiating the `ColorPicker` object with the desired size

		var colorPicker = new ColorPicker(256);

The size represents the no. of pixels of the gradient canvas.  Since the color range is from `0-255`, specify a size of 256 for pixel perfect color range. 

Add the color picker element to the DOM

		query("#my_picker").nodes.add(colorPicker.element);


The initial color and the currently selected color are shown on the top right corner along with the RGB values and its corresponding [HSV](http://en.wikipedia.org/wiki/HSL_and_HSV) values.

![Small Color Picker](https://raw.github.com/coderespawn/dart-color-picker/master/docs/images/color_picker_small.png)

A smaller color picker can be created with the following code:

		var smallColorPicker = new ColorPicker(128, showInfoBox: false);

The details on the right are hidden to save space by setting the `showInfoBox` parameter to `false`

![Tiny Color Picker](https://raw.github.com/coderespawn/dart-color-picker/master/docs/images/color_picker_tiny.png)

## Initial Color

Specify an initial color when launching the color picker by setting an optional `initialColor` parameter.

		var smallColorPicker = new ColorPicker(256, initialColor: new ColorValue.fromRGB(60, 190, 220));


## Color Change Callback
Listen for color change events:

		colorPicker.colorChangeListener = (ColorValue color, num hue, num saturation, num brightness) {
			// Process new color value here ...
		};

Read the selected color value at any time from the color picker:

		var color = colorPicker.currentColor;

## Cleanup
Call the `dispose()` method to remove the color picker from the DOM and then remove all references of the color picker object in your code.  The GC should cleanup the rest.

		colorPicker.dispose();

## Demo
Check out the live demo [here](http://htmlpreview.github.com/?https://raw.github.com/coderespawn/dart-color-picker/master/color_picker_demo/web/color_picker_demo.html)
