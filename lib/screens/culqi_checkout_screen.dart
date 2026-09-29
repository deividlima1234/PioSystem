import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/payment_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CulqiCheckoutScreen extends StatefulWidget {
  const CulqiCheckoutScreen({super.key});

  @override
  State<CulqiCheckoutScreen> createState() => _CulqiCheckoutScreenState();
}

class _CulqiCheckoutScreenState extends State<CulqiCheckoutScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  // Controladores Tarjeta
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController(); // MM/YY
  final _cvvController = TextEditingController();
  final _emailController = TextEditingController();

  // Controladores Yape
  final _yapePhoneController = TextEditingController();
  final _yapeCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _emailController.dispose();
    _yapePhoneController.dispose();
    _yapeCodeController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    setState(() => _isLoading = true);

    bool success = false;
    if (_tabController.index == 0) {
      // Tarjeta
      success = await _paymentService.processCardPayment(
        cardNumber: _cardNumberController.text,
        cvv: _cvvController.text,
        expiry: _expiryController.text,
        email: _emailController.text,
      );
    } else {
      // Yape
      success = await _paymentService.processYapePayment(
        phone: _yapePhoneController.text,
        approvalCode: _yapeCodeController.text,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Error al procesar el pago. Verifica tus datos."), backgroundColor: context.colors.error),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: context.colors.success, size: 80),
              const SizedBox(height: 24),
              Text(
                "¡Pago Exitoso!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                "Tu cuenta ha sido vinculada a PioSystem Cloud.",
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Cierra el dialog y regresa hasta la configuración
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text("Ir a mi Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
        title: Text("Pago Seguro", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.borderFaint),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Total
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceLight,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total a pagar", style: TextStyle(color: context.colors.textSecondary, fontSize: 14)),
                          Text("S/ 39.00", style: TextStyle(color: context.colors.primary, fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Icon(Icons.lock, color: context.colors.success, size: 32),
                    ],
                  ),
                ),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: context.colors.primary,
                  unselectedLabelColor: context.colors.textSecondary,
                  indicatorColor: context.colors.primary,
                  tabs: const [
                    Tab(icon: Icon(Icons.credit_card), text: "Tarjeta"),
                    Tab(icon: Icon(Icons.password), text: "Yape"),
                    Tab(icon: Icon(Icons.qr_code_scanner), text: "QR"),
                  ],
                ),

                // Formulario
                SizedBox(
                  height: 350,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCardForm(),
                      _buildYapeForm(),
                      _buildQRForm(),
                    ],
                  ),
                ),

                // Botón Pagar (Solo visible en Tarjeta y Yape)
                if (_tabController.index != 2)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: context.colors.onPrimary, strokeWidth: 2))
                            : Text("Pagar S/ 39.00", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onPrimary)),
                      ),
                    ),
                  ),
                if (_tabController.index == 2)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () async {
                          // Simular el pago completado vía WebSocket
                          setState(() => _isLoading = true);
                          await Future.delayed(const Duration(seconds: 2));
                          setState(() => _isLoading = false);
                          _showSuccessDialog();
                        },
                        icon: const Icon(Icons.webhook),
                        label: const Text("Simular recepción WebSocket"),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, size: 14, color: context.colors.textMuted),
                    const SizedBox(width: 4),
                    Text("Pagos procesados de forma segura por Culqi", style: TextStyle(fontSize: 12, color: context.colors.textMuted)),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildTextField(_cardNumberController, "Número de Tarjeta", Icons.credit_card, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField(_expiryController, "MM/AA", Icons.date_range, keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(_cvvController, "CVV", Icons.security, keyboardType: TextInputType.number, obscureText: true)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(_emailController, "Correo Electrónico", Icons.email, keyboardType: TextInputType.emailAddress),
      ],
    );
  }

  Widget _buildYapeForm() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pasos para pagar con Yape:", style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
              const SizedBox(height: 8),
              Text("1. Abre tu app Yape.", style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
              Text("2. Ve a 'Código de aprobación'.", style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
              Text("3. Ingresa el código de 6 dígitos aquí abajo.", style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(_yapePhoneController, "Tu número de Yape", Icons.phone_android, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildTextField(_yapeCodeController, "Código de Aprobación (6 dígitos)", Icons.password, keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildQRForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Escanea con Yape o Plin",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: context.colors.textPrimary),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 2),
          ),
          child: QrImageView(
            data: "00020101021143...MOCK_CULQI_QR_PAYLOAD",
            version: QrVersions.auto,
            size: 200.0,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              "Esperando confirmación en tiempo real...",
              style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, bool obscureText = false}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: context.colors.textSecondary),
        filled: true,
        fillColor: context.colors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      style: TextStyle(color: context.colors.textPrimary),
    );
  }
}
