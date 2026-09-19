import 'package:flutter/material.dart';
import '../widgets/numpad_widget.dart';
import '../services/isar_service.dart';
import 'main_layout.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final IsarService _isarService = IsarService();
  bool _isAdminLogin = false;

  // Cajero State
  String _pin = '';

  // Admin State
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onPinNumberTapped(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
      });
      if (_pin.length == 4) {
        _attemptCashierLogin();
      }
    }
  }

  void _onPinDeleteTapped() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _onPinClearTapped() {
    setState(() {
      _pin = '';
    });
  }

  void _attemptCashierLogin() async {
    bool success = await _isarService.authenticateCashier(_pin);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso concedido (Cajero)')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayout())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('PIN Incorrecto'), backgroundColor: context.colors.error),
      );
      _onPinClearTapped();
    }
  }

  void _attemptAdminLogin() async {
    bool success = await _isarService.authenticateAdmin(
      _emailController.text, 
      _passwordController.text
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso concedido (Admin)')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayout())
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Credenciales Incorrectas'), backgroundColor: context.colors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background, // Fondo ultra oscuro
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 600;
          
          List<Widget> children = [
            // Branding / Imagen
            Expanded(
              flex: isWide ? 1 : 0,
              child: Container(
                width: double.infinity,
                height: isWide ? double.infinity : 300,
                color: context.colors.primary.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fastfood,
                      size: isWide ? 120 : 80,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "PioSystem",
                      style: TextStyle(
                        fontSize: isWide ? 48 : 36,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      "Punto de Venta Local-First",
                      style: TextStyle(
                        fontSize: 16,
                        color: context.colors.textSecondary,
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Formulario de Login
            Expanded(
              flex: isWide ? 1 : 1,
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: EdgeInsets.all(isWide ? 32 : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Toggle Rol
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildRoleTab('Cajero', !_isAdminLogin, () => setState(() => _isAdminLogin = false)),
                          _buildRoleTab('Administrador', _isAdminLogin, () => setState(() => _isAdminLogin = true)),
                        ],
                      ),
                      const SizedBox(height: 48),

                    // Contenido Dinámico según Rol
                    if (!_isAdminLogin) _buildCashierLogin() else _buildAdminLogin(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ];

          return isWide 
            ? Row(children: children) 
            : Column(children: children);
        },
      ),
    );
  }

  Widget _buildRoleTab(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? context.colors.primary : context.colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? context.colors.primary : context.colors.borderLight,
          )
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? context.colors.textPrimary : context.colors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCashierLogin() {
    return Column(
      children: [
        Text(
          "Ingrese su PIN",
          style: TextStyle(color: context.colors.textPrimary.withOpacity(0.7), fontSize: 18),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            bool isFilled = index < _pin.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled ? context.colors.primary : context.colors.transparent,
                border: Border.all(
                  color: isFilled ? context.colors.primary : context.colors.borderLight,
                  width: 2,
                )
              ),
            );
          }),
        ),
        const SizedBox(height: 48),
        NumPadWidget(
          onNumberTap: _onPinNumberTapped,
          onDeleteTap: _onPinDeleteTapped,
          onClearTap: _onPinClearTapped,
        )
      ],
    );
  }

  Widget _buildAdminLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "Correo Electrónico",
            prefixIcon: Icon(Icons.email, color: context.colors.textSecondary),
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: context.colors.textPrimary),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Contraseña",
            prefixIcon: Icon(Icons.lock, color: context.colors.textSecondary),
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: context.colors.textPrimary),
        ),
        const SizedBox(height: 48),
        SizedBox(
          height: 55,
          child: ElevatedButton(
            onPressed: _attemptAdminLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              )
            ),
            child: Text("INGRESAR", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
          ),
        )
      ],
    );
  }
}
