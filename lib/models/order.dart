import 'package:isar/isar.dart';

part 'order.g.dart';

@collection
class Order {
  Id id = Isar.autoIncrement;

  late DateTime createdAt;

  DateTime? closedAt;

  String? ticketNumber; // Ej: T-0001

  @Enumerated(EnumType.name)
  late OrderStatus status;

  double totalAmount = 0.0;

  String? customerName; // O identificador de mesa

  @Enumerated(EnumType.name)
  PaymentMethod? paymentMethod;

  final items = IsarLinks<OrderItem>();
}

@collection
class OrderItem {
  Id id = Isar.autoIncrement;

  late int productId;
  late String productName;
  late double unitPrice;
  late int quantity;
  late double subtotal;
}

enum OrderStatus {
  open,    // Pos-pago o en espera
  paid,    // Pagado
  cancelled
}

enum PaymentMethod {
  cash,
  yape,
  card
}
