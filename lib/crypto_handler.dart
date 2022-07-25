import 'network.dart';

const String apiKey = 'A3DD0CF7-06AB-4263-A6F0-8737523E8D1D';
const String coinApiUrl = 'https://rest.coinapi.io/v1/exchangerate';

class Crypto {
  Future<dynamic> getExchangeRate(
      String realCurrency, String cryptoCurrency) async {
    var url = '$coinApiUrl/$cryptoCurrency/$realCurrency?apikey=$apiKey';

    Networking networkHelper = Networking(url: url);

    var coinData = await networkHelper.getData();
    return coinData;
  }
}
