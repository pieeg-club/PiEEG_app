class DeviceDataProcessorService {
  static List<double> processRawDeviceData(List<int> dataReceived) {
    int dataResult = 0;
    int convertData = 0;
    int dataCheck = 0xFFFFFF;
    int dataTest = 0x7FFFFF;
    double result = 0.0;
    int bytesPerSample = 3;
    List<double> dataForGraph = [];

    for (int index = 0; index < dataReceived.length; index++) {
      int dataRead = dataReceived[index];
      dataResult = (dataResult << 8) | dataRead;

      if ((index + 1) % bytesPerSample == 0) {
        convertData = dataResult | dataTest;

        if (convertData == dataCheck) {
          result = (dataResult - 16777214).toDouble();
        } else {
          result = dataResult.toDouble();
        }

        result = ((1000000 * 4.5 * (result / 16777215)) * 100).round() / 100;

        dataForGraph.add(result);

        dataResult = 0;
      }
    }

    return dataForGraph;
  }
}
