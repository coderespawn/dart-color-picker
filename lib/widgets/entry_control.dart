part of color_picker;

typedef String EntryControlGetter();
typedef void EntryControlSetter(String value);

/** 
 * Displays a label and a text box for displaying and entering values
 * Supports custom getter setters for updating the values 
 */
class EntryControl {
  /** The label of this entry control */
  String name;
  
  /** Entry control getter function */
  EntryControlGetter getValue;
  
  /** Entry control setter function */
  EntryControlSetter setValue;
  
  DivElement elementBase;
  DivElement elementName;
  InputElement elementValue;
  
  EntryControl(this.name, this.getValue, this.setValue) {
    elementBase = new DivElement();
    elementName = new DivElement();
    elementValue = new InputElement();
    
    elementBase.classes.add("entry-control-base");
    elementName.classes.add("entry-control-base-name");
    elementValue.classes.add("entry-control-base-value");
    

    elementBase.nodes.add(elementName);
    elementBase.nodes.add(elementValue);
    
    elementName.innerHtml = name;
    elementValue.value = getValue();
    
    elementValue.onChange.listen((e) {
      setValue(elementValue.value);
    });
  }
  
  void refresh() {
    elementValue.value = getValue();
  }
}
