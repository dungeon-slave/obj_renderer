for (int i = 0, length = _entities.values.length; i < length; i++) {
  final List<Vector4> triangle = _entities.values.elementAt(i);

  Vector4 temp;
  if (triangle[0].y > triangle[1].y) {
    temp = triangle[0];
    triangle[0] = triangle[1];
    triangle[1] = temp;
  }
  if (triangle[0].y > triangle[2].y) {
    temp = triangle[0];
    triangle[0] = triangle[2];
    triangle[2] = temp;
  }
  if (triangle[1].y > triangle[2].y) {
    temp = triangle[1];
    triangle[1] = triangle[2];
    triangle[2] = temp;
  }

  final Vector4 coefficient1 =
    (triangle[1] - triangle[0]) / (triangle[1].y - triangle[0].y);
  final Vector4 coefficient2 =
    (triangle[2] - triangle[0]) / (triangle[2].y - triangle[0].y);
  final Vector4 coefficient3 =
    (triangle[2] - triangle[1]) / (triangle[2].y - triangle[1].y);

  for (int minY = max(triangle[0].y.ceil(), 0),
    y = minY,
    maxY = min(triangle[2].y.ceil(), _screenSize.height.toInt() - 1);
    y < maxY;
    y++) {
    Vector4 a = triangle[0] + coefficient2 * (y - triangle[0].y);

    Vector4 b = y > triangle[1].y
    ? triangle[1] + coefficient3 * (y - triangle[1].y)
        : triangle[0] + coefficient1 * (y - triangle[0].y);

    if (a.x > b.x) {
      (a, b) = (b, a);
    }

    final Vector4 coeff_ab = (b - a) / (b.x - a.x);

    for (int minX = max(a.x.ceil(), 0),
      x = minX,
      maxX = min(b.x.ceil(), _screenSize.width.toInt() - 1);
      x < maxX;
      x++) {
      final double xD = x.toDouble();
      final Vector4 p = a + coeff_ab * (xD - a.x);
      final int pos = y * _screenSize.width.toInt() + x;
      final int value = deepnessBuffer[pos] + deepnessBuffer2[pos] - 1;

      if (value > offsetBuffer.length - 1) {
      break;
      }

      offsetBuffer[value] = Vector3(p.x, p.y, p.z);

      deepnessBuffer2[pos]++;
    }
  }
}