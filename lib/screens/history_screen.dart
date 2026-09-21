import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/isar_service.dart';
import '../services/print_service.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_shape.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final IsarService _isarService = IsarService();
  final PrintService _printService = PrintService();
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
    
    // Obtener la configuración de negocio para el header del ticket
    final config = await _isarService.getAppConfig();
    final user = await _isarService.getFirstAdmin();
    
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.readColors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.colors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
              ),
              Expanded(
                child: CustomPaint(
                  painter: TicketShape(color: context.colors.surface),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // CABECERA DEL NEGOCIO
                        Text(
                          config?.businessName.isNotEmpty == true ? config!.businessName : "PioSystem POS",
                          style: TextStyle(
                            fontFamily: 'Courier', 
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: context.colors.textPrimary
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (config?.ruc.isNotEmpty == true)
                          Text("RUC: ${config!.ruc}", style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)),
                        if (config?.address.isNotEmpty == true)
                          Text(config!.address, style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary), textAlign: TextAlign.center),
                        if (config?.phone.isNotEmpty == true)
                          Text("Tel: ${config!.phone}", style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)),
                        
                        const SizedBox(height: 16),
                        Text(
                          "--------------------------------",
                          style: TextStyle(fontFamily: 'Courier', color: context.colors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: 8),

                        // DATOS DEL TICKET
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ticket:", style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)),
                            Text(order.ticketNumber ?? "N/A", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Fecha:", style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)),
                            Text(DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt), style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Cajero:", style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)),
                            Text(user?.name ?? "Cajero", style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        Text(
                          "--------------------------------",
                          style: TextStyle(fontFamily: 'Courier', color: context.colors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: 8),
                        
                        // CABECERA PRODUCTOS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("CANT. DESCRIPCION", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                            Text("IMPORTE", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // PRODUCTOS
                        Expanded(
                          child: ListView.builder(
                            itemCount: order.items.length,
                            itemBuilder: (context, index) {
                              final item = order.items.elementAt(index);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${item.quantity}x ${item.productName}", 
                                        style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)
                                      ),
                                    ),
                                    Text(
                                      "S/ ${item.subtotal.toStringAsFixed(2)}",
                                      style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "--------------------------------",
                          style: TextStyle(fontFamily: 'Courier', color: context.colors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: 8),

                        // TOTALES
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("TOTAL:", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 18, color: context.colors.textPrimary)),
                            Text(
                              "S/ ${order.totalAmount.toStringAsFixed(2)}",
                              style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 18, color: context.colors.textPrimary),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("PAGO:", style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)),
                            Text(order.paymentMethod?.name.toUpperCase() ?? 'EFECTIVO', style: TextStyle(fontFamily: 'Courier', color: context.colors.textPrimary)),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        Text("Gracias por su preferencia", style: TextStyle(fontFamily: 'Courier', color: context.colors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (config != null && user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Imprimiendo Ticket...")));
                      bool success = await _printService.printTicket(
                        order: order,
                        items: order.items.toList(),
                        config: config,
                        user: user,
                      );
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Error al imprimir. Revisa la conexión con la ticketera."),
                          backgroundColor: context.readColors.error,
                        ));
                      }
                    }
                  },
                  icon: Icon(Icons.print, color: context.colors.onPrimary),
                  label: Text("Reimprimir Ticket", style: TextStyle(color: context.colors.onPrimary, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
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
