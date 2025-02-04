class CircularBuffer {
  final List<double> buffer;
  int writeIndex = 0;
  final int capacity;

  CircularBuffer(this.capacity) : buffer = List<double>.filled(capacity, 0);

  void add(double value) {
    buffer[writeIndex] = value;
    writeIndex = (writeIndex + 1) % capacity;
  }

  List<double> getData() {
    // Allocate a single list to avoid multiple memory allocations
    List<double> orderedBuffer = List<double>.filled(capacity, 0);
    int firstPartSize = capacity - writeIndex;

    // Copy the "newer" portion (from writeIndex to end)
    orderedBuffer.setRange(0, firstPartSize, buffer, writeIndex);

    // Copy the "older" portion (from start to writeIndex)
    orderedBuffer.setRange(firstPartSize, capacity, buffer, 0);

    return orderedBuffer;
  }
}
