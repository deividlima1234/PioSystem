import 'package:flutter/material.dart';
import '../services/isar_service.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final IsarService _isarService = IsarService();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    // Verificar si está vacío para poblado inicial
    await _isarService.seedProductsIfEmpty();
    final products = await _isarService.getAllProducts();
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAvailability(Product product, bool value) async {
    product.isAvailable = value;
    await _isarService.saveProduct(product);
    _loadProducts();
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text('Eliminar Producto', style: TextStyle(color: context.colors.textPrimary)),
        content: Text('¿Seguro que deseas eliminar ${product.name}?', style: TextStyle(color: context.colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: context.colors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.error),
            child: Text('Eliminar', style: TextStyle(color: context.colors.onError)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _isarService.deleteProduct(product.id);
      _loadProducts();
    }
  }

  void _showProductModal({Product? product}) {
    final formKey = GlobalKey<FormState>();
    String name = product?.name ?? '';
    String price = product?.price.toString() ?? '';
    String category = product?.category ?? 'Platos';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.readColors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  product == null ? 'Nuevo Producto' : 'Editar Producto',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  initialValue: name,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Nombre del Producto',
                    labelStyle: TextStyle(color: context.colors.textMuted),
                    filled: true,
                    fillColor: context.colors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Precio (S/)',
                    labelStyle: TextStyle(color: context.colors.textMuted),
                    filled: true,
                    fillColor: context.colors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    if (double.tryParse(value) == null) return 'Precio inválido';
                    return null;
                  },
                  onSaved: (value) => price = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: category,
                  style: TextStyle(color: context.colors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: TextStyle(color: context.colors.textMuted),
                    filled: true,
                    fillColor: context.colors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  onSaved: (value) => category = value!,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      final newProduct = product ?? Product();
                      newProduct.name = name;
                      newProduct.price = double.parse(price);
                      newProduct.category = category;
                      
                      await _isarService.saveProduct(newProduct);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      _loadProducts();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onPrimary)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.transparent, // Fondo manejado por MainLayout
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Catálogo de Productos",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Administra los precios y disponibilidad en caja",
                    style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _products.isEmpty
                        ? Center(child: Text("No hay productos", style: TextStyle(color: context.colors.textMuted)))
                        : ListView.separated(
                            itemCount: _products.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final product = _products[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: context.colors.borderFaint),
                                ),
                                child: Row(
                                  children: [
                                    // Ícono por defecto
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: context.colors.surfaceLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        product.category.toLowerCase() == 'bebidas' ? Icons.local_drink : Icons.fastfood,
                                        color: context.colors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: product.isAvailable ? context.colors.textPrimary : context.colors.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "S/ ${product.price.toStringAsFixed(2)} • ${product.category}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: context.colors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: product.isAvailable,
                                      activeColor: context.colors.primary,
                                      onChanged: (val) => _toggleAvailability(product, val),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: context.colors.textSecondary),
                                      onPressed: () => _showProductModal(product: product),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: context.colors.error),
                                      onPressed: () => _deleteProduct(product),
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
        onPressed: () => _showProductModal(),
        backgroundColor: context.colors.primary,
        icon: Icon(Icons.add, color: context.colors.textPrimary),
        label: Text("Nuevo Producto", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
