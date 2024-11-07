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
    // Return data in the correct order
    return [...buffer.sublist(writeIndex), ...buffer.sublist(0, writeIndex)];
  }
}
