import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'culqi_checkout_screen.dart';

class CloudPaywallScreen extends StatelessWidget {
  const CloudPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.cloud_sync, size: 100, color: context.colors.primary),
                const SizedBox(height: 24),
                Text(
                  "PioSystem Cloud",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Protege tu negocio y accede a funcionalidades premium.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                _buildBenefitItem(context, Icons.security, "Respaldos Automáticos", "Tus ventas e inventario se guardan de forma segura en la nube."),
                const SizedBox(height: 24),
                _buildBenefitItem(context, Icons.devices, "Restauración Instantánea", "Si cambias de tablet, recupera toda tu información al instante."),
                const SizedBox(height: 24),
                _buildBenefitItem(context, Icons.update, "Sincronización en Tiempo Real", "Tus datos siempre al día y protegidos ante cualquier pérdida."),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.primary.withOpacity(0.3), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Suscripción Mensual",
                        style: TextStyle(fontSize: 18, color: context.colors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "S/ 39.00",
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: context.colors.primary),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CulqiCheckoutScreen()),
                            );
                          },
                          icon: Icon(Icons.payment, color: context.colors.onPrimary),
                          label: Text(
                            "Suscribirse Ahora",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onPrimary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Pago seguro procesado por Culqi. Cancelación en cualquier momento.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: context.colors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: context.colors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(fontSize: 14, color: context.colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
