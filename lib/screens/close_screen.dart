import 'package:flutter/material.dart';
import '../services/isar_service.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';

class CloseScreen extends StatefulWidget {
  const CloseScreen({super.key});

  @override
  State<CloseScreen> createState() => _CloseScreenState();
}

class _CloseScreenState extends State<CloseScreen> {
  final IsarService _isarService = IsarService();
  bool _isLoading = true;
  
  List<Order> _todayOrders = [];
  double _totalSales = 0.0;
  double _totalCash = 0.0;
  double _totalYape = 0.0;
  double _totalCard = 0.0;
  
  List<MapEntry<String, int>> _topProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final orders = await _isarService.getTodayOrders();
    
    double sales = 0;
    double cash = 0;
    double yape = 0;
    double card = 0;
    Map<String, int> productCounts = {};

    for (var order in orders) {
      if (order.status == OrderStatus.paid) {
        sales += order.totalAmount;
        
        switch (order.paymentMethod) {
          case PaymentMethod.cash:
            cash += order.totalAmount;
            break;
          case PaymentMethod.yape:
            yape += order.totalAmount;
            break;
          case PaymentMethod.card:
            card += order.totalAmount;
            break;
          default:
            cash += order.totalAmount; // Fallback
        }
        
        for (var item in order.items) {
          productCounts[item.productName] = (productCounts[item.productName] ?? 0) + item.quantity;
        }
      }
    }

    final sortedProducts = productCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (mounted) {
      setState(() {
        _todayOrders = orders;
        _totalSales = sales;
        _totalCash = cash;
        _totalYape = yape;
        _totalCard = card;
        _topProducts = sortedProducts;
        _isLoading = false;
      });
    }
  }

  void _printZReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: context.colors.success, size: 28),
            const SizedBox(width: 12),
            Text('Reporte Z Generado', style: TextStyle(color: context.colors.textPrimary)),
          ],
        ),
        content: Text(
          'El cierre de caja se ha realizado exitosamente.\n\nSe ha enviado la orden de impresión (Simulado).',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(String title, double amount, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.borderFaint),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              'S/ ${amount.toStringAsFixed(2)}',
              style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.transparent,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cierre de Caja",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Resumen financiero del día de hoy",
                    style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  
                  // Total Sales Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.colors.primary, context.colors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "VENTAS TOTALES",
                          style: TextStyle(color: context.colors.onPrimary.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "S/ ${_totalSales.toStringAsFixed(2)}",
                          style: TextStyle(color: context.colors.onPrimary, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_todayOrders.where((o) => o.status == OrderStatus.paid).length} transacciones exitosas",
                          style: TextStyle(color: context.colors.onPrimary.withOpacity(0.9), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Breakdown
                  Row(
                    children: [
                      _buildPaymentCard("Efectivo", _totalCash, Icons.payments, Colors.green),
                      const SizedBox(width: 16),
                      _buildPaymentCard("Yape / Plin", _totalYape, Icons.qr_code_scanner, Colors.purple),
                      const SizedBox(width: 16),
                      _buildPaymentCard("Tarjeta", _totalCard, Icons.credit_card, Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Top Selling Items
                  Text(
                    "Productos Más Vendidos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _topProducts.isEmpty
                        ? Center(child: Text("No hay ventas registradas hoy", style: TextStyle(color: context.colors.textMuted)))
                        : ListView.builder(
                            itemCount: _topProducts.length,
                            itemBuilder: (context, index) {
                              final entry = _topProducts[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: context.colors.borderFaint),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: index < 3 ? context.colors.primary.withOpacity(0.1) : context.colors.surfaceLight,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "#${index + 1}",
                                        style: TextStyle(
                                          color: index < 3 ? context.colors.primary : context.colors.textMuted,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        entry.key,
                                        style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Text(
                                      "${entry.value} uds.",
                                      style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _printZReport,
        backgroundColor: context.colors.primary,
        icon: Icon(Icons.receipt_long, color: context.colors.onPrimary),
        label: Text("Imprimir Reporte Z", style: TextStyle(color: context.colors.onPrimary, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
