import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../orders/orders_provider.dart';

class SalesChartScreen extends StatefulWidget {
  @override
  _SalesChartScreenState createState() => _SalesChartScreenState();
}

class _SalesChartScreenState extends State<SalesChartScreen> {
  final _orderService = OrderService();
  Map<String, int> _productSales = {};
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _fetchProductSales();
  }

  void _fetchProductSales() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_startDate != null && _endDate != null) {
        Map<String, int> sales = await _orderService.getProductSales(
          startDate: _startDate,
          endDate: _endDate,
          status: 'Entregado',
        );
        setState(() {
          _productSales = sales;
        });
      }
    } catch (e) {
      print('Error al cargar las ventas: $e');
    } finally {
      setState(() {
        _isLoading = false; 
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchProductSales();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráficos de Ventas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _selectDateRange(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_startDate != null && _endDate != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Mostrando pedidos desde ${DateFormat('yyyy-MM-dd').format(_startDate!)} hasta ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                  ),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _productSales.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal, 
                          child: Container(
                            width: _productSales.length * 100.0,  
                            height: 500,  
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), 
                                ),
                              ],
                            ),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceEvenly,
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 60,  
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        final productName = _productSales.keys.elementAt(value.toInt());
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Transform.rotate(
                                            angle: -0.5,  
                                            child: Text(
                                              productName,
                                              style: TextStyle(color: Colors.black, fontSize: 10),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (double value, TitleMeta meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(color: Colors.black, fontSize: 12),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  horizontalInterval: 1, 
                                ),
                                barGroups: _productSales.entries
                                    .map((entry) => BarChartGroupData(
                                          x: _productSales.keys.toList().indexOf(entry.key),
                                          barRods: [
                                            BarChartRodData(
                                              toY: entry.value.toDouble(),
                                              color: Colors.blue,
                                              width: 16,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        )
                      : Center(child: Text('No hay datos para mostrar')),
            ),
          ],
        ),
      ),
    );
  }
}
