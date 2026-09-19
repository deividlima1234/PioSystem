import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pos_screen.dart';
import 'history_screen.dart';
import '../theme/app_theme.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false; // Empezar colapsado en móviles

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = 280.0; // Ampliado

    final List<Widget> screens = [
      const PosScreen(),
      Center(child: Text("Cuentas Abiertas (En Desarrollo)", style: TextStyle(color: context.colors.textPrimary))),
      const HistoryScreen(),
      Center(child: Text("Cierre de Caja (En Desarrollo)", style: TextStyle(color: context.colors.textPrimary))),
      _buildSettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Área Central
            Positioned.fill(
              child: Container(
                color: context.colors.black,
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
                        _showProfileModal(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        color: context.colors.surfaceDark,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: context.colors.primary,
                              child: Text(
                                'A', // Letra inicial
                                style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin User',
                                    style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Administrador',
                                    style: TextStyle(color: context.colors.textMuted, fontSize: 13),
                                  ),
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

  Widget _buildSettingsScreen() {
    return Container(
      color: context.colors.background,
      child: Column(
        children: [
          AppBar(
            backgroundColor: context.colors.background,
            title: Text("Ajustes", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
            automaticallyImplyLeading: false,
            elevation: 0,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  "APARIENCIA",
                  style: TextStyle(color: context.colors.textMuted, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Card(
                  color: context.colors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 24, height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFF003C), // Rojo
                          ),
                        ),
                        title: Text("Tema Oscuro (Rojo Carmesí)", style: TextStyle(color: context.colors.textPrimary)),
                        trailing: context.read<ThemeProvider>().currentTheme == AppThemeType.darkRed
                            ? Icon(Icons.check, color: context.colors.primary)
                            : null,
                        onTap: () {
                          context.read<ThemeProvider>().switchTheme(AppThemeType.darkRed);
                        },
                      ),
                      Divider(height: 1, color: context.colors.borderFaint),
                      ListTile(
                        leading: Container(
                          width: 24, height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1565C0), // Azul
                          ),
                        ),
                        title: Text("Tema Claro (Azul Océano)", style: TextStyle(color: context.colors.textPrimary)),
                        trailing: context.read<ThemeProvider>().currentTheme == AppThemeType.lightBlue
                            ? Icon(Icons.check, color: context.colors.primary)
                            : null,
                        onTap: () {
                          context.read<ThemeProvider>().switchTheme(AppThemeType.lightBlue);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
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

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: context.colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header con gradiente rojo y avatar superpuesto
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.colors.primary, context.colors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.textPrimary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40, // Avatar mitad adentro, mitad afuera
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 54,
                          backgroundColor: context.colors.background,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: context.colors.surface,
                            child: Text(
                              'A',
                              style: TextStyle(fontSize: 40, color: context.colors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: context.colors.background,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: context.colors.surface,
                            child: Icon(Icons.camera_alt, size: 16, color: context.colors.primary),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50), // Espacio para el avatar
              // Info del usuario
              Text(
                'Admin User',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.colors.primary),
                ),
                child: Text(
                  'ADMINISTRADOR',
                  style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              // Tarjetas de información
              Expanded(
                child: Container(
                  color: context.colors.background,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildSectionHeader("INFORMACIÓN PERSONAL"),
                      _buildDarkInfoCard([
                        _buildDarkInfoRow(Icons.person_outline, "Nombre de Usuario", "admin"),
                        Divider(height: 1, indent: 50, color: context.colors.borderFaintest),
                        _buildDarkInfoRow(Icons.badge_outlined, "ID de Empleado", "#001"),
                      ]),
                      const SizedBox(height: 20),
                      _buildSectionHeader("ESTADO DE CUENTA"),
                      _buildDarkInfoCard([
                        _buildDarkInfoRow(
                          Icons.verified_user_outlined,
                          "Estado",
                          "Activo",
                          valueColor: context.colors.success,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              // Botón Cerrar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  border: Border(top: BorderSide(color: context.colors.borderFaintest)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.textPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cerrar", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: context.colors.textMuted,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDarkInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDarkInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: context.colors.textMuted),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: context.colors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.transparent,
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
