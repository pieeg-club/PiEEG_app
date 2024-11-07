class CircularBuffer {
  final List<double> buffer;
  final List<double> warmUpData;
  int writeIndex = 0;
  final int capacity;
  final int warmUpLength;

  CircularBuffer(
    this.capacity,
    this.warmUpLength,
  )   : buffer = List<double>.filled(capacity, 0),
        warmUpData = List<double>.filled(warmUpLength, 0);

  void add(double value) {
    buffer[writeIndex] = value;
    writeIndex = (writeIndex + 1) % capacity;
  }

  void addWithWarmUp(double value) {
    if (writeIndex > capacity - warmUpLength) {
      warmUpData[writeIndex - (capacity - warmUpLength)] = value;
    }
    buffer[writeIndex] = value;
    writeIndex = (writeIndex + 1) % capacity;
  }

  List<double> getData() {
    // Return data in the correct order
    return [...buffer.sublist(writeIndex), ...buffer.sublist(0, writeIndex)];
  }

  List<double> getDataWithWarmUp() {
    // Return data in the correct order
    return [...warmUpData, ...buffer];
  }
}
