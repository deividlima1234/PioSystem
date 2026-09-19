import 'package:flutter/material.dart';
import '../services/isar_service.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_modal_widget.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final IsarService _isarService = IsarService();
  String _businessName = "Cargando...";
  String _userName = "Usuario";
  String _userEmail = "correo@ejemplo.com";

  @override
  void initState() {
    super.initState();
    _loadHeaderData();
  }

  Future<void> _loadHeaderData() async {
    final config = await _isarService.getAppConfig();
    final user = await _isarService.getFirstAdmin();
    if (mounted) {
      setState(() {
        _businessName = config?.businessName ?? "PioSystem POS";
        _userName = user?.name ?? "Cajero(a)";
        _userEmail = user?.email ?? "Sin correo";
      });
    }
  }

  // Mock data para el MVP visual
  final List<Map<String, dynamic>> _products = [
    {"name": "1/4 de Pollo", "price": 18.00, "category": "Platos"},
    {"name": "1/2 Pollo", "price": 32.00, "category": "Platos"},
    {"name": "Pollo Entero", "price": 60.00, "category": "Platos"},
    {"name": "Porción de Papas", "price": 10.00, "category": "Extras"},
    {"name": "Gaseosa 1L", "price": 8.00, "category": "Bebidas"},
    {"name": "Gaseosa Personal", "price": 4.00, "category": "Bebidas"},
  ];

  final List<Map<String, dynamic>> _cart = [];

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      var existing = _cart.where((item) => item['name'] == product['name']);
      if (existing.isNotEmpty) {
        existing.first['quantity']++;
      } else {
        _cart.add({...product, 'quantity': 1});
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  double get _total {
    return _cart.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void _processSale() async {
    if (_cart.isEmpty) return;

    final order = Order()
      ..createdAt = DateTime.now()
      ..status = OrderStatus.paid
      ..totalAmount = _total
      ..paymentMethod = PaymentMethod.cash; // MVP: Efectivo por defecto

    List<OrderItem> items = _cart.map((item) {
      return OrderItem()
        ..productId = 0 // Mock ID para MVP
        ..productName = item['name']
        ..unitPrice = item['price']
        ..quantity = item['quantity']
        ..subtotal = item['price'] * item['quantity'];
    }).toList();

    await _isarService.saveOrder(order, items);

    if (mounted) {
      _clearCart();
      _showSuccessDialog(order.ticketNumber ?? "N/A");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;

        Widget productsGrid = Expanded(
          flex: isWide ? 2 : 1,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: Datos del Negocio y Usuario ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _businessName,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Caja Principal",
                            style: TextStyle(fontSize: 14, color: context.colors.primary),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => ProfileModal.show(context),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: context.colors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _userName,
                              style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: context.colors.borderFaint,
                              child: Text(
                                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                                style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                // --- FIN HEADER ---
                
                Text(
                  "Catálogo",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textSecondary),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return InkWell(
                        onTap: () => _addToCart(product),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.colors.borderFaint),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fastfood, size: 40, color: context.colors.primary),
                              const SizedBox(height: 12),
                              Text(
                                product['name'],
                                textAlign: TextAlign.center,
                                style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "S/ ${product['price'].toStringAsFixed(2)}",
                                style: TextStyle(color: context.colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );

        return Scaffold(
          backgroundColor: context.colors.transparent,
          body: isWide 
            ? Row(children: [productsGrid, _buildCartPanel(isWide: true)])
            : Column(children: [productsGrid]),
          floatingActionButton: !isWide && _cart.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _showCartBottomSheet,
                  backgroundColor: context.colors.primary,
                  icon: Icon(Icons.shopping_cart, color: context.colors.textPrimary),
                  label: Text(
                    "Ver Orden (S/ ${_total.toStringAsFixed(2)})",
                    style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }


  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.readColors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: context.colors.borderLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: _buildCartPanel(isWide: false, setModalState: setModalState),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(String ticketNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: context.readColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: context.colors.success, size: 80),
                const SizedBox(height: 24),
                Text(
                  "¡Cobro Exitoso!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  "La venta $ticketNumber ha sido registrada correctamente.",
                  style: TextStyle(color: context.colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.add_shopping_cart, color: context.colors.textPrimary),
                      label: Text("Guardar", style: TextStyle(color: context.colors.textPrimary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.borderFaint,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enviando a Ticketera...")));
                      },
                      icon: Icon(Icons.print, color: context.colors.textPrimary),
                      label: Text("Imprimir", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartPanel({required bool isWide, StateSetter? setModalState}) {
    return Container(
      width: isWide ? 350 : double.infinity,
      color: isWide ? context.colors.surface : context.colors.transparent,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: context.colors.surfaceDark,
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, color: context.colors.textPrimary),
                    const SizedBox(width: 8),
                    Text("Orden Actual", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                  ],
                ),
              ),
              Expanded(
                child: _cart.isEmpty
                    ? Center(child: Text("Orden vacía", style: TextStyle(color: context.colors.textSecondary)))
                    : ListView.builder(
                        itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return ListTile(
                          title: Text(item['name'], style: TextStyle(color: context.colors.textPrimary)),
                          subtitle: Text("S/ ${(item['price']).toStringAsFixed(2)}", style: TextStyle(color: context.colors.textSecondary)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: context.colors.textSecondary),
                                onPressed: () {
                                  void update() {
                                    if (item['quantity'] > 1) {
                                      item['quantity']--;
                                    } else {
                                      _cart.removeAt(index);
                                    }
                                    if (_cart.isEmpty && !isWide) Navigator.of(context).pop();
                                  }
                                  setState(update);
                                  if (setModalState != null) setModalState(update);
                                },
                              ),
                              Text("${item['quantity']}", style: TextStyle(color: context.colors.textPrimary, fontSize: 16)),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: context.colors.textSecondary),
                                onPressed: () {
                                  void update() {
                                    item['quantity']++;
                                  }
                                  setState(update);
                                  if (setModalState != null) setModalState(update);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      ),
              ),
              // Totales y Botones
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  border: Border(top: BorderSide(color: context.colors.borderFaint)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("TOTAL", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                        Text("S/ ${_total.toStringAsFixed(2)}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.primary)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cart.isEmpty ? null : () {
                            if (!isWide) Navigator.of(context).pop(); // Cerrar modal si aplica
                            _clearCart();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.borderFaint,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("DESCARTAR", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _cart.isEmpty ? null : () {
                            if (!isWide) Navigator.of(context).pop(); // Cerrar modal
                            _processSale();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("COBRAR", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
  }
}
