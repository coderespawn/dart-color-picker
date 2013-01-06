part of color_picker;

/** 
 * Mouse event for the color pickers.   [x] and [y] are relative to the
 * element being listened to. If the mouse pointer is outside of the 
 * control while it is being dragged, the coordinates will be clamped
 * within the control's bounds
 */
typedef ColorPickerMouseEvent(int x, int y); 

/**
 * Listens for mouse events on the specified listener 
 */
class _MouseListener {
  Element element;
  
  /** 
   * If drag mode is set, the move move and up events are added top the body
   * when the user clicks on the element and starts to move it
   */
  bool dragMode;
  
  var _handlerMoveRef;
  var _handlerDownRef;
  var _handlerUpRef;
  
  ColorPickerMouseEvent onMouseMoved;
  ColorPickerMouseEvent onMouseUp;
  ColorPickerMouseEvent onMouseDown;

  /** The position of the mouse when the dragging started */
  MouseEvent startMouseEvent;
  int startMouseX;
  int startMouseY;
  
  // The cursor position
  int _cursorX = 0;
  int _cursorY = 0;
  
  _MouseListener(this.element, [this.dragMode = true]) {
    _handlerMoveRef = _handlerMove;
    _handlerDownRef = _handlerDown;
    _handlerUpRef = _handlerUp;
    
    element.on.mouseDown.add(_handlerDownRef);
    if (!dragMode) {
      element.on.mouseUp.add(_handlerUpRef);
      element.on.mouseMove.add(_handlerMoveRef);
    }
  }
  
  void dispose() {
    element.on.mouseDown.remove(_handlerDownRef);
    if (!dragMode) {
      element.on.mouseUp.remove(_handlerUpRef);
      element.on.mouseMove.remove(_handlerMoveRef);
    } else {
      document.body.on.mouseMove.remove(_handlerMoveRef);
      document.body.on.mouseUp.remove(_handlerUpRef);
    }
  }

  
  void _handlerDown(MouseEvent e) {
    startMouseEvent = e;
    startMouseX = e.offsetX;
    startMouseY = e.offsetY;
    _cursorX = startMouseX;
    _cursorY = startMouseY;
    _cursorX = max(0, min(element.width, _cursorX));
    _cursorY = max(0, min(element.height, _cursorY));
    if (dragMode) {
      document.body.on.mouseMove.add(_handlerMoveRef);
      document.body.on.mouseUp.add(_handlerUpRef);
    }

    // Disable text selection
    document.body.classes.add("color-picker-unselectable");
    
    if (onMouseDown != null) {
      onMouseDown(_cursorX, _cursorY);
    }
  }
  
  void _handlerMove(MouseEvent event) {

    // Get the cursor bounds clamped to the canvas rectangle
    _cursorX = startMouseX + event.pageX - startMouseEvent.pageX;
    _cursorY = startMouseY + event.pageY - startMouseEvent.pageY;
    _cursorX = max(0, min(element.width, _cursorX));
    _cursorY = max(0, min(element.height, _cursorY));
    
    if (onMouseMoved != null) {
      onMouseMoved(_cursorX, _cursorY);
    }
  }
  
  void _handlerUp(MouseEvent e) {
    _cursorX = e.offsetX;
    _cursorY = e.offsetY;
    if (dragMode) {
      document.body.on.mouseMove.remove(_handlerMoveRef);
      document.body.on.mouseUp.remove(_handlerUpRef);
    }
    if (onMouseUp != null) {
      onMouseUp(_cursorX, _cursorY);
    }
    
    // Restore text selection
    document.body.classes.remove("color-picker-unselectable");
  }
  
}
