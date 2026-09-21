import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/isar_service.dart';
import '../theme/app_theme.dart';

class ChangePinModal extends StatefulWidget {
  const ChangePinModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.readColors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const ChangePinModal(),
      ),
    );
  }

  @override
  State<ChangePinModal> createState() => _ChangePinModalState();
}

class _ChangePinModalState extends State<ChangePinModal> {
  final _formKey = GlobalKey<FormState>();
  final IsarService _isarService = IsarService();

  String _adminPassword = '';
  String _newPin = '';
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscurePin = true;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Necesitamos el email del admin. Asumimos que es el único admin por ahora en el MVP.
      final admin = await _isarService.getFirstAdmin();
      if (admin == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "No se encontró un administrador.";
        });
        return;
      }

      final success = await _isarService.updateCashierPin(admin.email, _adminPassword, _newPin);
      
      if (!mounted) return;
      
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PIN actualizado correctamente", style: TextStyle(color: context.readColors.onPrimary)),
            backgroundColor: context.readColors.success,
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Contraseña maestra incorrecta";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al actualizar el PIN";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: context.colors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.password, color: context.colors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Actualizar PIN de Cajero',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu contraseña maestra de administrador por seguridad y luego el nuevo PIN de 4 dígitos.',
              style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.colors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: context.colors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: context.colors.error, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextFormField(
              obscureText: _obscurePassword,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Contraseña Maestra',
                labelStyle: TextStyle(color: context.colors.textMuted),
                prefixIcon: Icon(Icons.lock_outline, color: context.colors.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: context.colors.textMuted),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Requerido';
                return null;
              },
              onSaved: (value) => _adminPassword = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: TextStyle(color: context.colors.textPrimary, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Nuevo PIN de Cajero (4 dígitos)',
                labelStyle: TextStyle(color: context.colors.textMuted, letterSpacing: 0, fontWeight: FontWeight.normal),
                prefixIcon: Icon(Icons.dialpad, color: context.colors.textMuted),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, color: context.colors.textMuted),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.length != 4) return 'El PIN debe tener 4 dígitos';
                return null;
              },
              onSaved: (value) => _newPin = value!,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: context.colors.onPrimary, strokeWidth: 2),
                      )
                    : Text(
                        'Actualizar PIN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onPrimary),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
