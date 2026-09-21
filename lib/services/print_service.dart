import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../models/order.dart';
import '../models/app_config.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';

class PrintService {
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  Future<bool> printTicket({
    required Order order,
    required List<OrderItem> items,
    required AppConfig config,
    required User user,
  }) async {
    bool? isConnected = await _bluetooth.isConnected;
    if (isConnected == null || !isConnected) {
      return false;
    }

    try {
      // Configuraciones de estilo básicas para BlueThermalPrinter
      // 0: normal, 1: bold, 2: underline, 3: underline+bold, 4: double height+width
      // Tamaño: 0: normal, 1: normal, 2: grande
      // Alineación: 0: Izquierda, 1: Centro, 2: Derecha
      
      // Cabecera
      if (config.businessName.isNotEmpty) {
        _bluetooth.printCustom(config.businessName, 2, 1);
      } else {
        _bluetooth.printCustom("PioSystem POS", 2, 1);
      }
      
      if (config.ruc.isNotEmpty) {
        _bluetooth.printCustom("RUC: ${config.ruc}", 0, 1);
      }
      if (config.address.isNotEmpty) {
        _bluetooth.printCustom(config.address, 0, 1);
      }
      if (config.phone.isNotEmpty) {
        _bluetooth.printCustom("Tel: ${config.phone}", 0, 1);
      }
      
      _bluetooth.printNewLine();
      _bluetooth.printCustom("--------------------------------", 0, 1);
      
      // Datos del Ticket
      _bluetooth.printLeftRight("Ticket:", order.ticketNumber ?? "N/A", 0);
      _bluetooth.printLeftRight("Fecha:", DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt), 0);
      _bluetooth.printLeftRight("Cajero:", user.name, 0);
      _bluetooth.printCustom("--------------------------------", 0, 1);
      
      // Cabecera de productos
      _bluetooth.printLeftRight("CANT. DESCRIPCION", "IMPORTE", 1);
      _bluetooth.printCustom("--------------------------------", 0, 1);
      
      // Productos
      for (var item in items) {
        String qty = "${item.quantity}x";
        String name = item.productName;
        // Si el nombre es muy largo, se puede cortar o imprimir en dos líneas, por simplicidad lo mantenemos así.
        _bluetooth.printLeftRight("$qty $name", "S/ ${item.subtotal.toStringAsFixed(2)}", 0);
      }
      
      _bluetooth.printCustom("--------------------------------", 0, 1);
      
      // Totales
      _bluetooth.printLeftRight("TOTAL:", "S/ ${order.totalAmount.toStringAsFixed(2)}", 1);
      _bluetooth.printLeftRight("PAGO:", order.paymentMethod?.name.toUpperCase() ?? "EFECTIVO", 0);
      
      _bluetooth.printNewLine();
      _bluetooth.printCustom("Gracias por su preferencia", 0, 1);
      _bluetooth.printNewLine();
      _bluetooth.printNewLine();
      
      // Cortar papel si la impresora lo soporta
      _bluetooth.paperCut();
      return true;
    } catch (e) {
      print("Error imprimiendo ticket: $e");
      return false;
    }
  }
}
