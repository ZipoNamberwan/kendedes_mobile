class MarkerDisplayStrategy {
  static MarkerRenderMode getRenderMode({required double zoom}) {
    if (zoom < 18) {
      return MarkerRenderMode.simple;
    } else {
      return MarkerRenderMode.complex;
    }
  }
}

enum MarkerRenderMode { simple, complex, hidden }
