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

  StreamSubscription _handlerMoveRef;
  StreamSubscription _handlerDownRef;
  StreamSubscription _handlerUpRef;

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
    _handlerDownRef = element.onMouseDown.listen(_handlerDown);
    if (!dragMode) {
      _handlerUpRef = element.onMouseUp.listen(_handlerUp);
      _handlerMoveRef = element.onMouseMove.listen(_handlerMove);
    }
  }

  void dispose() {
    _handlerDownRef.cancel();
    if (_handlerUpRef != null) {
      _handlerUpRef.cancel();
    }
    if (_handlerMoveRef != null) {
      _handlerMoveRef.cancel();
    }
  }


  void _handlerDown(MouseEvent e) {
    startMouseEvent = e;
    startMouseX = e.offset.x;
    startMouseY = e.offset.y;
    _cursorX = startMouseX;
    _cursorY = startMouseY;
    _cursorX = max(0, min(element.clientWidth, _cursorX));
    _cursorY = max(0, min(element.clientHeight, _cursorY));
    if (dragMode) {
      _handlerMoveRef = document.body.onMouseMove.listen(_handlerMove);
      _handlerUpRef = document.body.onMouseUp.listen(_handlerUp);
    }

    // Disable text selection
    document.body.classes.add("color-picker-unselectable");

    if (onMouseDown != null) {
      onMouseDown(_cursorX, _cursorY);
    }
  }

  void _handlerMove(MouseEvent event) {

    // Get the cursor bounds clamped to the canvas rectangle
    _cursorX = startMouseX + event.page.x - startMouseEvent.page.x;
    _cursorY = startMouseY + event.page.y - startMouseEvent.page.y;
    _cursorX = max(0, min(element.clientWidth, _cursorX));
    _cursorY = max(0, min(element.clientHeight, _cursorY));

    if (onMouseMoved != null) {
      onMouseMoved(_cursorX, _cursorY);
    }
  }

  void _handlerUp(MouseEvent e) {
    _cursorX = e.offset.x;
    _cursorY = e.offset.y;
    if (dragMode) {
      if (_handlerMoveRef != null) _handlerMoveRef.cancel();
      if (_handlerUpRef != null) _handlerUpRef.cancel();
    }
    if (onMouseUp != null) {
      onMouseUp(_cursorX, _cursorY);
    }

    // Restore text selection
    document.body.classes.remove("color-picker-unselectable");
  }

}
