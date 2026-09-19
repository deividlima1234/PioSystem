import 'package:flutter/material.dart';

import 'pos_screen.dart';
import 'history_screen.dart';
import 'catalog_screen.dart';
import 'close_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_modal_widget.dart';
import '../services/isar_service.dart';
import '../models/user.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false; // Empezar colapsado en móviles
  String _userName = "Cargando...";
  String _userRole = "---";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await IsarService().getFirstAdmin();
    if (mounted && user != null) {
      setState(() {
        _userName = user.name;
        _userRole = user.role == Role.admin ? "Administrador" : "Cajero";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = 280.0; // Ampliado

    final List<Widget> screens = [
      const PosScreen(),
      Center(child: Text("Cuentas Abiertas (En Desarrollo)", style: TextStyle(color: context.colors.textPrimary))),
      const CatalogScreen(),
      const HistoryScreen(),
      const CloseScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Área Central
            Positioned.fill(
              child: Container(
                color: context.colors.background,
                child: Column(
                  children: [
                    // Barra Superior con Hamburguesa
                    Container(
                      height: 50,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        icon: Icon(Icons.menu, color: context.colors.textPrimary, size: 32),
                        onPressed: () {
                          setState(() {
                            _isSidebarOpen = true;
                          });
                        },
                      ),
                    ),
                    // Pantalla Activa
                    Expanded(
                      child: screens[_selectedIndex],
                    ),
                  ],
                ),
              ),
            ),
            // Fondo oscuro semitransparente para cerrar al tocar fuera
            if (_isSidebarOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSidebarOpen = false;
                    });
                  },
                  child: Container(
                    color: context.colors.overlay,
                  ),
                ),
              ),
            // Sidebar de Navegación Superpuesto (Animado)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _isSidebarOpen ? 0 : -sidebarWidth,
              top: 0,
              bottom: 0,
              width: sidebarWidth,
              child: Container(
                color: context.colors.surface,
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [context.colors.primary, context.colors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Icon(Icons.point_of_sale, color: context.colors.textPrimary, size: 48),
                          const SizedBox(height: 10),
                          Text(
                            'PioSystem',
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Navegación
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        children: [
                          _buildNavItem(Icons.point_of_sale, "Ventas", 0),
                          _buildNavItem(Icons.table_restaurant, "Cuentas", 1),
                          _buildNavItem(Icons.inventory_2_outlined, "Catálogo", 2),
                          _buildNavItem(Icons.history, "Historial", 3),
                          _buildNavItem(Icons.receipt_long, "Cierre", 4),
                          _buildNavItem(Icons.settings, "Ajustes", 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(color: context.colors.borderLight),
                          ),
                          ListTile(
                            leading: Icon(Icons.info_outline, color: context.colors.textMuted),
                            title: Text('Acerca de', style: TextStyle(color: context.colors.textMuted)),
                            onTap: () {
                              setState(() => _isSidebarOpen = false);
                              _showAboutModal(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.exit_to_app, color: context.colors.primary),
                            title: Text('Cerrar Sesión', style: TextStyle(color: context.colors.primary)),
                            onTap: () {
                              // TODO: Implement logout
                            },
                          ),
                        ],
                      ),
                    ),
                    // Footer de Usuario
                    Divider(height: 1, color: context.colors.borderLight),
                    InkWell(
                      onTap: () {
                        setState(() => _isSidebarOpen = false);
                        ProfileModal.show(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        color: context.colors.surfaceDark,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: context.colors.primary,
                              child: Text(
                                _userName.length > 1 ? _userName[0].toUpperCase() : 'U',
                                style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_userName, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                                  Text(_userRole, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: context.colors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? Theme.of(context).primaryColor : context.colors.textSecondary,
        size: 28,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Theme.of(context).primaryColor : context.colors.textSecondary,
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _isSidebarOpen = false;
        });
      },
    );
  }


  void _showAboutModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.readColors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[700], // Keeping for subtle drag handle
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(Icons.point_of_sale, size: 48, color: context.colors.primary),
            const SizedBox(height: 16),
            Text(
              'PioSystem',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
            ),
            Text(
              'Versión 1.0.0',
              style: TextStyle(color: context.colors.textMuted),
            ),
            const SizedBox(height: 32),
            Divider(color: context.colors.borderLight),
            const SizedBox(height: 24),
            _buildCreditRow("Desarrollado por", "Eddam Eloy"),
            const SizedBox(height: 12),
            _buildCreditRow("Corporación", "EddamCore © 2026"),
            const SizedBox(height: 40),
            Text(
              "Todos los derechos reservados",
              style: TextStyle(fontSize: 10, color: context.colors.textMuted),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: context.colors.textMuted, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
      ],
    );
  }
}
