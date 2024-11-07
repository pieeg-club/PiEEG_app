class CircularBuffer {
  final List<double> buffer;
  List<double> warmUpData;
  final List<double> nextWarmUpData;
  int writeIndex = 0;
  final int capacity;
  final int warmUpLength;

  CircularBuffer(
    this.capacity,
    this.warmUpLength,
  )   : buffer = List<double>.filled(capacity, 0),
        warmUpData = List<double>.filled(warmUpLength, 0),
        nextWarmUpData = List<double>.filled(warmUpLength, 0);

  void add(double value) {
    buffer[writeIndex] = value;
    writeIndex = (writeIndex + 1) % capacity;
  }

  void addWithWarmUp(double value) {
    if (writeIndex > capacity - warmUpLength) {
      nextWarmUpData[writeIndex - (capacity - warmUpLength)] = value;
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
    List<double> previousWarmup = warmUpData.sublist(0);
    warmUpData = nextWarmUpData.sublist(0);
    nextWarmUpData.fillRange(0, warmUpLength, 0);
    return [...previousWarmup, ...buffer];
  }
}
