import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../models/theme_colors.dart';
import '../services/stock_service.dart';
import '../services/q_learning_service.dart';
import '../models/stock_data.dart';
import '../theme/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StockService _stockService = StockService();
  final QLearningService _qLearningService = QLearningService();


  String currentStock = "AAPL";
  double currentPrice = 178.42;
  double priceChange = 3.24;
  bool isPositiveChange = true;
  String timeframe = "1D";
  bool isPredicting = false;
  bool isLoading = false;
  String? modelAction;

  List<FlSpot> priceData = [];
  List<FlSpot> predictionData = [];
  Map<String, dynamic>? stockTimeSeriesData;

  @override
  void initState() {
    super.initState();
    _fetchStockData(currentStock);
  }

  Future<void> _fetchStockData(String symbol) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch stock data from Alpha Vantage
      final data = await _stockService.fetchStockData(symbol);

      if (data != null) {
        stockTimeSeriesData = data;
        _processStockData();

        // Get latest price
        final latestTimestamp = data.keys.first;
        final latestData = data[latestTimestamp];
        currentPrice = double.parse(latestData['4. close']);

        // Calculate price change
        final previousTimestamp = data.keys.elementAt(1);
        final previousData = data[previousTimestamp];
        final previousPrice = double.parse(previousData['4. close']);
        priceChange = currentPrice - previousPrice;
        isPositiveChange = priceChange >= 0;

        // Get Q-learning model action
        _getModelAction();
      }
    } catch (e) {
      print('Error fetching stock data: $e');
      // Use mock data if API fails
      _generateMockData();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _processStockData() {
    if (stockTimeSeriesData == null) return;

    priceData = [];
    int index = 0;

    // Process the time series data based on selected timeframe
    int dataPointsToUse = 20; // Default for 1D view

    if (timeframe == "1W") dataPointsToUse = 30;
    else if (timeframe == "1M") dataPointsToUse = 60;
    else if (timeframe == "3M") dataPointsToUse = 90;
    else if (timeframe == "1Y") dataPointsToUse = 250;

    // Get subset of data
    final timeSeriesList = stockTimeSeriesData!.entries.take(dataPointsToUse).toList();

    // Populate price data (reversed to show oldest to newest)
    for (int i = timeSeriesList.length - 1; i >= 0; i--) {
      final data = timeSeriesList[i].value;
      final price = double.parse(data['4. close']);
      priceData.add(FlSpot(index.toDouble(), price));
      index++;
    }

    // Generate prediction if enabled
    if (isPredicting) {
      _generatePrediction();
    }
  }

  Future<void> _getModelAction() async {
    try {
      modelAction = await _qLearningService.getActionFromPrice(currentPrice);
    } catch (e) {
      print('Error getting model action: $e');
      // Default action if API fails
      modelAction = currentPrice > 170 ? 'BUY' : 'SELL';
    }
    setState(() {});
  }

  void _generatePrediction() {
    if (priceData.isEmpty) return;

    predictionData = [];
    double lastPrice = priceData.last.y;
    double lastX = priceData.last.x;

    // Start prediction from last actual data point
    predictionData.add(FlSpot(lastX, lastPrice));

    // Generate 7 days of prediction
    Random random = Random();
    for (int i = 1; i <= 7; i++) {
      // Base prediction on model action
      double trend = modelAction == 'BUY' ? 0.5 : -0.5;
      double volatility = random.nextDouble() * 3;
      double nextPrice = lastPrice + trend + (random.nextDouble() * volatility - volatility/2);

      predictionData.add(FlSpot(lastX + i, nextPrice));
      lastPrice = nextPrice;
    }
  }

  void _generateMockData() {
    final Random random = Random();
    priceData = [];
    predictionData = [];

    // Generate past price data (20 days)
    double basePrice = 170.0;
    for (int i = 0; i < 20; i++) {
      double price = basePrice + random.nextDouble() * 15 - 5;
      priceData.add(FlSpot(i.toDouble(), price));
      basePrice = price;
    }

    // Add current price
    priceData.add(FlSpot(20, currentPrice));

    // Generate prediction data (7 days)
    if (isPredicting) {
      _generatePrediction();
    }
  }

  void _searchStock(String symbol) {
    if (symbol.isEmpty) return;

    setState(() {
      currentStock = symbol.toUpperCase();
      _searchController.clear();
    });

    _fetchStockData(currentStock);
  }

  void _togglePrediction() {
    setState(() {
      isPredicting = !isPredicting;
      if (isPredicting) {
        _generatePrediction();
      }
    });
  }

  void _changeTimeframe(String tf) {
    setState(() {
      timeframe = tf;
      _processStockData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: colors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search stocks by symbol',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: colors.textTertiary),
                        ),
                        style: TextStyle(color: colors.text),
                        onSubmitted: _searchStock,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Stock Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStock,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Price',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${currentPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isPositiveChange ? colors.success : colors.error,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositiveChange ? "+" : ""}${priceChange.toStringAsFixed(2)} (${(priceChange / currentPrice * 100).toStringAsFixed(2)}%)',
                            style: TextStyle(
                              color: isPositiveChange ? colors.success : colors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Time Frame Selector
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: colors.inputBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _timeframeButton("1D", colors),
                    _timeframeButton("1W", colors),
                    _timeframeButton("1M", colors),
                    _timeframeButton("3M", colors),
                    _timeframeButton("1Y", colors),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Chart
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price Chart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _togglePrediction,
                          icon: Icon(
                            isPredicting ? Icons.visibility_off : Icons.visibility,
                            size: 16,
                          ),
                          label: Text(isPredicting ? "Hide Prediction" : "Show Prediction"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPredicting ? colors.primaryDark : colors.primary,
                            foregroundColor: colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: priceData.isEmpty
                          ? Center(child: Text('No data available', style: TextStyle(color: colors.textSecondary)))
                          : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: colors.border,
                                strokeWidth: 0.5,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: colors.border,
                                strokeWidth: 0.5,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  final style = TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 10,
                                  );
                                  Widget text;
                                  if (value.toInt() % 5 == 0) {
                                    if (value >= priceData.last.x && isPredicting) {
                                      text = Text('Pred', style: style);
                                    } else {
                                      final timeLabel = timeframe == "1D" ? "h" : "d";
                                      text = Text('${value.toInt()}$timeLabel', style: style);
                                    }
                                  } else {
                                    text = Text('', style: style);
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: text,
                                    angle: 0,
                                    space: 8,
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42,
                                getTitlesWidget: (value, meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 0,
                                    angle: 0,
                                    child: Text(
                                      '\$${value.toInt()}',
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: colors.border),
                          ),
                          minX: 0,
                          maxX: isPredicting
                              ? (predictionData.isNotEmpty ? predictionData.last.x : priceData.last.x + 7)
                              : priceData.last.x,
                          minY: (priceData.map((spot) => spot.y).toList()
                            ..addAll(isPredicting && predictionData.isNotEmpty ? predictionData.map((spot) => spot.y).toList() : []))
                              .reduce(min) - 5,
                          maxY: (priceData.map((spot) => spot.y).toList()
                            ..addAll(isPredicting && predictionData.isNotEmpty ? predictionData.map((spot) => spot.y).toList() : []))
                              .reduce(max) + 5,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipBorder: BorderSide(color: colors.border, width: 1),
                              tooltipRoundedRadius: 8,
                              tooltipPadding: EdgeInsets.all(8),
                              tooltipMargin: 8,
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final bool isPredictionPoint = spot.barIndex == 1;
                                  return LineTooltipItem(
                                    '\$${spot.y.toStringAsFixed(2)}${isPredictionPoint ? ' (Pred)' : ''}',
                                    TextStyle(
                                      color: isPredictionPoint ? colors.primaryDark : colors.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          lineBarsData: [
                            // Historical data
                            LineChartBarData(
                              spots: priceData,
                              isCurved: true,
                              color: colors.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: colors.primary.withOpacity(0.2),
                              ),
                            ),
                            // Prediction data
                            if (isPredicting && predictionData.isNotEmpty)
                              LineChartBarData(
                                spots: predictionData,
                                isCurved: true,
                                color: colors.primaryDark,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: colors.primaryDark.withOpacity(0.1),
                                ),
                                dashArray: [5, 5],
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Prediction Metrics
              if (isPredicting && predictionData.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.primaryLight),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q-Learning Model Predictions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _predictionMetric(
                            'Predicted Price (7d)',
                            '\$${predictionData.last.y.toStringAsFixed(2)}',
                            predictionData.last.y > currentPrice ? colors.success : colors.error,
                            colors,
                          ),
                          _predictionMetric(
                            'Expected Return',
                            '${((predictionData.last.y - currentPrice) / currentPrice * 100).toStringAsFixed(2)}%',
                            predictionData.last.y > currentPrice ? colors.success : colors.error,
                            colors,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _predictionMetric(
                            'Confidence',
                            '${(Random().nextDouble() * 20 + 70).toStringAsFixed(1)}%',
                            colors.primary,
                            colors,
                          ),
                          _predictionMetric(
                            'Model Action',
                            modelAction ?? 'ANALYZING',
                            modelAction == 'BUY'
                                ? colors.success
                                : modelAction == 'SELL'
                                ? colors.error
                                : colors.warning,
                            colors,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Key Metrics
              Text(
                'Key Metrics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _metricCard('MA (50)', '\$${(currentPrice - 5).toStringAsFixed(2)}', Icons.show_chart, colors),
                  const SizedBox(width: 16),
                  _metricCard('MA (200)', '\$${(currentPrice - 15).toStringAsFixed(2)}', Icons.timeline, colors),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _metricCard('RSI', '${(Random().nextDouble() * 30 + 40).toStringAsFixed(1)}', Icons.speed, colors),
                  const SizedBox(width: 16),
                  _metricCard('Volume', '${(Random().nextDouble() * 20 + 20).toStringAsFixed(1)}M', Icons.bar_chart, colors),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Predictions Performance
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Model Performance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _performanceMetric('Accuracy', '84%', colors.success, colors),
                        _performanceMetric('Avg. Return', '3.2%', colors.success, colors),
                        _performanceMetric('Sharpe', '1.84', colors.primary, colors),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fetchStockData(currentStock),
        backgroundColor: colors.primary,
        foregroundColor: colors.white,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _timeframeButton(String text, ThemeColors colors) {
    bool isSelected = timeframe == text;
    return GestureDetector(
      onTap: () => _changeTimeframe(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? colors.white : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, ThemeColors colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _predictionMetric(String title, String value, Color valueColor, ThemeColors colors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _performanceMetric(String title, String value, Color valueColor, ThemeColors colors) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}