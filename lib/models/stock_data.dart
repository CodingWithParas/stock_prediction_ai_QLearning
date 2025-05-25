
class StockData {
  final String ticker;
  final String prediction;
  final String rationale;
  final String summary;

  StockData({
    required this.ticker,
    required this.prediction,
    required this.rationale,
    required this.summary,
  });

  factory StockData.fromJson(Map<String, dynamic> json, String ticker, String prediction, String rationale) {
    return StockData(
      ticker: ticker,
      prediction: prediction,
      rationale: rationale,
      summary: json['summary'] as String,
    );
  }
}
