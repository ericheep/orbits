class Partial {

  float start, size;

  Partial (int i, int d) {
    start = i/float(d) * TWO_PI;
    size = 1.0/float(d) * TWO_PI;
  }

  void update(float x, float y, float r, float pos, float dir) {
    noFill();
    if (pos > 0.1) {
      if (dir == 0) {
        arc(x, y, r, r, start, start + size * pos);
      }
      if (dir == 1) {
        arc(x, y, r, r, start - size * pos, start);
      }
    }
  }
}