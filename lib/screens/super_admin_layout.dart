import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/isar_service.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;

class SuperAdminLayout extends StatefulWidget {
  const SuperAdminLayout({super.key});

  @override
  State<SuperAdminLayout> createState() => _SuperAdminLayoutState();
}

class _SuperAdminLayoutState extends State<SuperAdminLayout> {
  int _selectedIndex = 0;
  bool _isSidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    final double sidebarWidth = 280.0;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Área Central
            Positioned.fill(
              child: Column(
                children: [
                  // Barra Superior con Hamburguesa
                  Container(
                    height: 50,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: IconButton(
                      icon: Icon(Icons.menu, color: context.colors.textPrimary, size: 32),
                      onPressed: () => setState(() => _isSidebarOpen = true),
                    ),
                  ),
                  // Pantalla Activa
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
            // Fondo oscuro semitransparente para cerrar al tocar fuera
            if (_isSidebarOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _isSidebarOpen = false),
                  child: Container(color: context.colors.overlay),
                ),
              ),
            // Sidebar
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
                    // Header con Gradiente
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
                          SvgPicture.asset('assets/logo.svg', width: 64, height: 64),
                          const SizedBox(height: 10),
                          Text(
                            'EddamCore System',
                            style: TextStyle(
                              color: context.colors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Super Administrador',
                            style: TextStyle(
                              color: context.colors.textPrimary.withOpacity(0.8),
                              fontSize: 14,
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
                          _buildNavItem(Icons.dashboard, "Dashboard", 0),
                          _buildNavItem(Icons.vpn_key, "Generador de Licencias", 1),
                          _buildNavItem(Icons.people, "Clientes Locales", 2),
                          _buildNavItem(Icons.cloud, "PioSystem Cloud", 3),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Divider(color: context.colors.borderLight),
                          ),
                          ListTile(
                            leading: Icon(Icons.exit_to_app, color: context.colors.error),
                            title: Text('Cerrar Sesión Segura', style: TextStyle(color: context.colors.error)),
                            onTap: () {
                              final isDark = context.readColors.isDark;
                              context.read<ThemeProvider>().switchTheme(isDark ? AppThemeType.darkRed : AppThemeType.lightBlue);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const LoginScreen())
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Footer de Usuario (EddamCore)
                    Divider(height: 1, color: context.colors.borderLight),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      color: context.colors.surfaceDark,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: context.colors.primary,
                            child: Text('E', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("EddamCore", style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                                Text("Fundador / Root", style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
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
        color: isActive ? context.colors.primary : context.colors.textSecondary,
        size: 28,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? context.colors.primary : context.colors.textSecondary,
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

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return Center(child: Text("Bienvenido al Modo Dios, EddamCore.", style: TextStyle(color: context.colors.textPrimary, fontSize: 24)));
      case 1:
        return const _KeygenModule();
      case 2:
        return const _LocalClientsModule();
      case 3:
        return const _CloudClientsModule();
      default:
        return Center(child: Text("Módulo en Construcción", style: TextStyle(color: context.colors.textMuted)));
    }
  }
}

class _KeygenModule extends StatefulWidget {
  const _KeygenModule();

  @override
  State<_KeygenModule> createState() => _KeygenModuleState();
}

class _KeygenModuleState extends State<_KeygenModule> {
  final TextEditingController _signatureController = TextEditingController();
  String _generatedCode = "";
  bool _isGenerating = false;
  bool _isCopied = false;

  void _generateCode() async {
    String sig = _signatureController.text.trim();
    if (sig.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa el Código de Equipo', style: TextStyle(color: context.colors.onPrimary)), backgroundColor: context.colors.error)
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedCode = "";
      _isCopied = false;
    });

    // Simular un proceso complejo de encriptación para dar un "Wow effect"
    await Future.delayed(const Duration(milliseconds: 2500));

    // Misma Sal y algoritmo de la pantalla de activación
    const secretSalt = "PioSystem_MasterKey_2026_@EddamCore";
    var bytes = utf8.encode(sig + secretSalt);
    var digest = sha256.convert(bytes);
    
    String hashString = digest.toString().toUpperCase();
    String expectedPart1 = hashString.substring(0, 4);
    String expectedPart2 = hashString.substring(4, 8);
    String expectedPart3 = hashString.substring(8, 12);
    
    if (mounted) {
      setState(() {
        _generatedCode = "$expectedPart1-$expectedPart2-$expectedPart3";
        _isGenerating = false;
      });
    }
  }

  void _copyToClipboard() async {
    Clipboard.setData(ClipboardData(text: _generatedCode));
    setState(() => _isCopied = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: context.colors.onPrimary),
            const SizedBox(width: 8),
            Text('Licencia copiada exitosamente', style: TextStyle(color: context.colors.onPrimary)),
          ],
        ), 
        backgroundColor: context.colors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isCopied = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Generador de Licencias", style: TextStyle(color: context.colors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Ingresa el 'Código de Equipo' del cliente para generar su Acceso Oficial.", style: TextStyle(color: context.colors.textSecondary)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.primary.withOpacity(0.3))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Código de Equipo (Hardware Signature):", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _signatureController,
                  decoration: InputDecoration(
                    hintText: "Ej: realme_RMX3511_TP1A...",
                    hintStyle: TextStyle(color: context.colors.textMuted),
                    filled: true,
                    fillColor: context.colors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: context.colors.primary)),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: context.colors.textMuted),
                      onPressed: () {
                        _signatureController.clear();
                        setState(() {
                          _generatedCode = "";
                        });
                      },
                    ),
                  ),
                  style: TextStyle(color: context.colors.textPrimary),
                  onChanged: (val) {
                    // Actualizar estado para mostrar/ocultar el botón limpiar si es necesario
                  },
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _isGenerating 
                    ? Container(
                        key: const ValueKey('loading'),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: context.colors.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.colors.primary.withOpacity(0.5))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(color: context.colors.primary, strokeWidth: 2)
                            ),
                            const SizedBox(width: 16),
                            Text("Generando llave criptográfica...", style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('button'),
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            foregroundColor: context.colors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 8,
                            shadowColor: context.colors.primary.withOpacity(0.5)
                          ),
                          onPressed: _generateCode,
                          child: const Text("ENCRIPTAR Y GENERAR LICENCIA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                        ),
                      ),
                ),
                if (_generatedCode.isNotEmpty && !_isGenerating) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Center(
                    child: Text("Código de Acceso Listo:", style: TextStyle(color: context.colors.success, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.background,
                      border: Border.all(color: context.colors.success),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SelectableText(
                          _generatedCode,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                            child: _isCopied
                                ? Icon(Icons.check_circle, color: context.colors.success, size: 32, key: const ValueKey('check'))
                                : Icon(Icons.copy, color: context.colors.primary, size: 28, key: const ValueKey('copy')),
                          ),
                          onPressed: _copyToClipboard,
                        )
                      ],
                    ),
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _LocalClientsModule extends StatefulWidget {
  const _LocalClientsModule();

  @override
  State<_LocalClientsModule> createState() => _LocalClientsModuleState();
}

class _LocalClientsModuleState extends State<_LocalClientsModule> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final isar = IsarService();
    final users = await isar.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator(color: context.colors.primary));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Clientes Locales (Este Dispositivo)", style: TextStyle(color: context.colors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Gestiona los cajeros y administradores registrados físicamente en esta terminal Isar.", style: TextStyle(color: context.colors.textSecondary)),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                color: context.colors.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: context.colors.borderLight)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.role == Role.admin ? context.colors.primary : context.colors.primaryDark,
                    child: Icon(user.role == Role.admin ? Icons.admin_panel_settings : Icons.person, color: context.colors.onPrimary),
                  ),
                  title: Text(user.name, style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                  subtitle: Text(user.role == Role.admin ? "Email: ${user.email}" : "Cajero", style: TextStyle(color: context.colors.textMuted)),
                  trailing: Text(user.role == Role.admin ? "Administrador" : "Cajero", style: TextStyle(color: user.role == Role.admin ? context.colors.primary : context.colors.textSecondary, fontWeight: FontWeight.bold)),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class _CloudClientsModule extends StatefulWidget {
  const _CloudClientsModule();

  @override
  State<_CloudClientsModule> createState() => _CloudClientsModuleState();
}

class _CloudClientsModuleState extends State<_CloudClientsModule> {
  List<dynamic> _businesses = [];
  List<dynamic> _devices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCloudData();
  }

  Future<void> _loadCloudData() async {
    try {
      final bRes = await http.get(Uri.parse('https://api-piosystem.colegiohuanoquite.org.pe/api/v1/superadmin/businesses'), headers: {'X-SuperAdmin-Key': 'EddamCore2026'});
      final dRes = await http.get(Uri.parse('https://api-piosystem.colegiohuanoquite.org.pe/api/v1/superadmin/devices'), headers: {'X-SuperAdmin-Key': 'EddamCore2026'});
      
      if (bRes.statusCode == 200 && dRes.statusCode == 200) {
        if (mounted) {
          setState(() {
            _businesses = jsonDecode(bRes.body);
            _devices = jsonDecode(dRes.body);
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator(color: context.colors.primary));
    
    int cloudDevices = _devices.where((d) => d['cloud'] == true).length;
    int localDevices = _devices.where((d) => d['cloud'] == false).length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PioSystem Cloud Master", style: TextStyle(color: context.colors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Panel de Control Mundial de Instalaciones y Suscripciones", style: TextStyle(color: context.colors.textSecondary)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard("Total Nube", cloudDevices.toString(), Icons.cloud, context.colors.primary),
              const SizedBox(width: 16),
              _buildStatCard("Total Locales", localDevices.toString(), Icons.phone_android, context.colors.textSecondary),
            ],
          ),
          const SizedBox(height: 32),
          Text("Empresas Registradas (Nube)", style: TextStyle(color: context.colors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_businesses.isEmpty)
            Text("No hay empresas conectadas a la base de datos de producción aún.", style: TextStyle(color: context.colors.textMuted))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _businesses.length,
              itemBuilder: (context, index) {
                final b = _businesses[index];
                bool isActive = b['active'] ?? false;
                return Card(
                  color: context.colors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: context.colors.borderLight)),
                  child: ListTile(
                    onTap: () => _showBusinessDetails(context, b),
                    leading: CircleAvatar(
                      backgroundColor: isActive ? context.colors.success.withOpacity(0.2) : context.colors.error.withOpacity(0.2),
                      child: Icon(isActive ? Icons.check_circle : Icons.cancel, color: isActive ? context.colors.success : context.colors.error),
                    ),
                    title: Text(b['name'] ?? 'Sin Nombre', style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text("RUC: ${b['ruc'] ?? 'N/A'}\nExpira: ${b['subscriptionEndDate'] ?? 'Sin Fecha'}", style: TextStyle(color: context.colors.textMuted)),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(Icons.settings, color: context.colors.primary),
                      onPressed: () => _showBusinessDetails(context, b),
                    ),
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(count, style: TextStyle(color: context.colors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showBusinessDetails(BuildContext context, dynamic b) {
    bool isActive = b['active'] ?? false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Detalles de Empresa", style: TextStyle(color: context.colors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(icon: Icon(Icons.close, color: context.colors.textSecondary), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow("Nombre:", b['name'] ?? 'N/A', Icons.business),
              _buildDetailRow("Propietario:", b['ownerName'] ?? 'No registrado', Icons.person),
              _buildDetailRow("Teléfono:", b['phone'] ?? 'No registrado', Icons.phone),
              _buildDetailRow("Email:", b['email'] ?? 'No registrado', Icons.email),
              _buildDetailRow("RUC:", b['ruc'] ?? 'N/A', Icons.receipt),
              _buildDetailRow("Límite Disp.:", "${b['maxDevices'] ?? 1}", Icons.devices),
              _buildDetailRow("Plan:", b['planName'] ?? 'No especificado', Icons.star),
              _buildDetailRow("Vencimiento:", b['subscriptionEndDate'] ?? 'Sin fecha', Icons.calendar_today),
              const SizedBox(height: 24),
              Text("Acciones Administrativas", style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? context.colors.error : context.colors.success,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _toggleBusinessStatus(b['id'], !isActive);
                      },
                      icon: Icon(isActive ? Icons.block : Icons.check_circle, color: Colors.white),
                      label: Text(isActive ? "Suspender" : "Reactivar", style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _extendSubscription(b['id']);
                      },
                      icon: const Icon(Icons.add_circle, color: Colors.white),
                      label: const Text("+1 Mes", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: context.colors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(color: context.colors.textPrimary, fontSize: 16))),
        ],
      ),
    );
  }

  Future<void> _toggleBusinessStatus(String id, bool activate) async {
    final url = activate ? "/businesses/$id/activate" : "/businesses/$id/suspend";
    try {
      final res = await http.put(Uri.parse('https://api-piosystem.colegiohuanoquite.org.pe/api/v1/superadmin$url'), headers: {'X-SuperAdmin-Key': 'EddamCore2026'});
      if (res.statusCode == 200) {
        _loadCloudData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(activate ? "Empresa reactivada." : "Empresa suspendida.")));
      }
    } catch(e) {}
  }

  Future<void> _extendSubscription(String id) async {
    try {
      final res = await http.put(Uri.parse('https://api-piosystem.colegiohuanoquite.org.pe/api/v1/superadmin/businesses/$id/extend?months=1'), headers: {'X-SuperAdmin-Key': 'EddamCore2026'});
      if (res.statusCode == 200) {
        _loadCloudData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Suscripción extendida 1 mes.")));
      }
    } catch(e) {}
  }
}
