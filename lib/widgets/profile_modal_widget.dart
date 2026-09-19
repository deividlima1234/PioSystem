import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileModal {
  static void show(BuildContext context, {required String userName, required String role}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.readColors.transparent,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.75,
          decoration: BoxDecoration(
            color: modalContext.colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header con gradiente y avatar superpuesto
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [modalContext.colors.primary, modalContext.colors.primaryDark],
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
                        color: modalContext.colors.textPrimary.withOpacity(0.3),
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
                          backgroundColor: modalContext.colors.background,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: modalContext.colors.surface,
                            child: Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                              style: TextStyle(fontSize: 40, color: modalContext.colors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: modalContext.colors.background,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: modalContext.colors.surface,
                            child: Icon(Icons.camera_alt, size: 16, color: modalContext.colors.primary),
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
                userName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: modalContext.colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: modalContext.colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: modalContext.colors.primary),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(color: modalContext.colors.primary, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              // Tarjetas de información
              Expanded(
                child: Container(
                  color: modalContext.colors.background,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildSectionHeader("INFORMACIÓN PERSONAL", modalContext),
                      _buildDarkInfoCard([
                        _buildDarkInfoRow(Icons.person_outline, "Nombre de Usuario", userName.toLowerCase().replaceAll(' ', ''), modalContext),
                        Divider(height: 1, indent: 50, color: modalContext.colors.borderFaintest),
                        _buildDarkInfoRow(Icons.badge_outlined, "ID de Empleado", "#001", modalContext),
                      ], modalContext),
                      const SizedBox(height: 20),
                      _buildSectionHeader("ESTADO DE CUENTA", modalContext),
                      _buildDarkInfoCard([
                        _buildDarkInfoRow(
                          Icons.verified_user_outlined,
                          "Estado",
                          "Activo",
                          modalContext,
                          valueColor: modalContext.colors.success,
                        ),
                      ], modalContext),
                    ],
                  ),
                ),
              ),
              // Botón Cerrar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: modalContext.colors.background,
                  border: Border(top: BorderSide(color: modalContext.colors.borderFaintest)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(modalContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: modalContext.colors.primary,
                      foregroundColor: modalContext.colors.textPrimary,
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

  static Widget _buildSectionHeader(String title, BuildContext context) {
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

  static Widget _buildDarkInfoCard(List<Widget> children, BuildContext context) {
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

  static Widget _buildDarkInfoRow(IconData icon, String label, String value, BuildContext context, {Color? valueColor}) {
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
}
