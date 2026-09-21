import 'package:flutter/material.dart';

import 'pos_screen.dart';
import 'history_screen.dart';
import 'catalog_screen.dart';
import 'close_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';
import '../services/update_service.dart';
import '../widgets/update_modal.dart';
import '../widgets/profile_modal_widget.dart';
import '../widgets/about_modal_widget.dart';
import '../services/isar_service.dart';
import '../models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    _checkForUpdatesInBackground();
  }

  Future<void> _checkForUpdatesInBackground() async {
    final updateInfo = await UpdateService().checkForUpdates();
    if (updateInfo != null && updateInfo.hasUpdate && mounted) {
      UpdateModal.show(context, updateInfo);
    }
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
                          _buildNavItem(Icons.inventory_2_outlined, "Catálogo", 1),
                          _buildNavItem(Icons.history, "Historial", 2),
                          _buildNavItem(Icons.receipt_long, "Cierre", 3),
                          _buildNavItem(Icons.settings, "Ajustes", 4),
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
      isScrollControlled: true,
      builder: (modalContext) => AboutModalWidget(parentContext: context),
    );
  }
}
