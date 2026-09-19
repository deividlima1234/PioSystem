import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/isar_service.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final IsarService _isarService = IsarService();
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _isarService.getAllOrders();
    if (mounted) {
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    }
  }

  void _showOrderDetails(Order order) async {
    // Necesitamos cargar los items del IsarLink
    await order.items.load();
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.readColors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: context.colors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ticket ${order.ticketNumber}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
                      style: TextStyle(color: context.colors.success, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd/MM/yyyy hh:mm a').format(order.createdAt),
                style: TextStyle(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 24),
              Divider(color: context.colors.borderFaint),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items.elementAt(index);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.productName, style: TextStyle(color: context.colors.textPrimary)),
                      subtitle: Text("x${item.quantity}", style: TextStyle(color: context.colors.textSecondary)),
                      trailing: Text(
                        "S/ ${item.subtotal.toStringAsFixed(2)}",
                        style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              Divider(color: context.colors.borderFaint),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TOTAL PAGADO", style: TextStyle(color: context.colors.textSecondary, fontSize: 18)),
                  Text(
                    "S/ ${order.totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(color: context.colors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enviando a Ticketera...")));
                  },
                  icon: Icon(Icons.print, color: context.colors.textPrimary),
                  label: Text("Reimprimir Ticket", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.borderFaint,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        title: Text("Historial de Ventas", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: context.colors.textPrimary),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : _orders.isEmpty
              ? Center(
                  child: Text("Aún no hay comprobantes registrados.", style: TextStyle(color: context.colors.textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      color: context.colors.surface,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () => _showOrderDetails(order),
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: context.colors.primary.withOpacity(0.2),
                          child: Icon(Icons.receipt_long, color: context.colors.primary),
                        ),
                        title: Text(
                          "Ticket: ${order.ticketNumber ?? 'N/A'}",
                          style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('dd/MM/yyyy hh:mm a').format(order.createdAt),
                            style: TextStyle(color: context.colors.textSecondary),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "S/ ${order.totalAmount.toStringAsFixed(2)}",
                              style: TextStyle(color: context.colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.paymentMethod?.name.toUpperCase() ?? 'EFECTIVO',
                              style: TextStyle(color: context.colors.textPrimary.withOpacity(0.38), fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
