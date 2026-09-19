import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/device_lock.dart';
import '../models/app_config.dart';
import '../utils/crypto_utils.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [UserSchema, ProductSchema, OrderSchema, OrderItemSchema, DeviceLockSchema, AppConfigSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> saveProduct(Product newProduct) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.products.putSync(newProduct));
  }

  Future<void> deleteProduct(int id) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.products.deleteSync(id));
  }

  Future<List<Product>> getAllProducts() async {
    final isar = await db;
    return await isar.products.where().findAll();
  }

  Future<List<Product>> getAvailableProducts() async {
    final isar = await db;
    return await isar.products.filter().isAvailableEqualTo(true).findAll();
  }

  Future<void> seedProductsIfEmpty() async {
    final isar = await db;
    final count = await isar.products.count();
    if (count == 0) {
      final initialProducts = [
        Product()..name = "1/4 de Pollo"..price = 18.00..category = "Platos",
        Product()..name = "1/2 Pollo"..price = 32.00..category = "Platos",
        Product()..name = "Pollo Entero"..price = 60.00..category = "Platos",
        Product()..name = "Porción de Papas"..price = 10.00..category = "Extras",
        Product()..name = "Gaseosa 1L"..price = 8.00..category = "Bebidas",
        Product()..name = "Gaseosa Personal"..price = 4.00..category = "Bebidas",
      ];
      await isar.writeTxn(() async {
        await isar.products.putAll(initialProducts);
      });
    }
  }

  // --- MÉTODOS DE REGISTRO (PRIMER USO) ---

  Future<bool> hasAdminRegistered() async {
    final isar = await db;
    final adminCount = await isar.users.filter().roleEqualTo(Role.admin).count();
    return adminCount > 0;
  }

  Future<void> registerFirstAdmin({
    required String businessName,
    required String adminName,
    required String email,
    required String password,
  }) async {
    final isar = await db;
    
    final config = AppConfig()..businessName = businessName;
    
    final admin = User()
      ..name = adminName
      ..email = email
      ..passwordHash = CryptoUtils.hashPassword(password)
      ..pinHash = CryptoUtils.hashPassword('0000') // Placeholder for cashier
      ..role = Role.admin;

    await isar.writeTxn(() async {
      await isar.appConfigs.put(config);
      await isar.users.put(admin);
    });
  }

  // --- MÉTODOS DE ACTIVACIÓN (CANDADO DE HARDWARE) ---

  Future<bool> isDeviceActivated() async {
    final isar = await db;
    final lock = await isar.deviceLocks.where().findFirst();
    return lock?.isActivated ?? false;
  }

  Future<void> activateDevice(String signature, String token) async {
    final isar = await db;
    final lock = await isar.deviceLocks.where().findFirst() ?? DeviceLock()
      ..hardwareSignature = signature;
    
    lock.isActivated = true;
    lock.activationToken = token;

    await isar.writeTxn(() async {
      await isar.deviceLocks.put(lock);
    });
  }

  // --- MÉTODOS DE LOGIN ---

  Future<bool> authenticateAdmin(String email, String password) async {
    final isar = await db;
    final admin = await isar.users.filter()
      .roleEqualTo(Role.admin)
      .emailEqualTo(email)
      .findFirst();

    if (admin == null) return false;

    return CryptoUtils.verifyPassword(password, admin.passwordHash);
  }

  Future<bool> authenticateCashier(String pin) async {
    final isar = await db;
    // Para simplificar: cualquier usuario con ese PIN (en MVP usamos el admin o cajero predeterminado)
    final users = await isar.users.where().findAll();
    for (var user in users) {
      if (CryptoUtils.verifyPassword(pin, user.pinHash)) {
        return true;
      }
    }
    return false;
  }

  // --- MÉTODOS DE CONSULTA UI ---

  Future<AppConfig?> getAppConfig() async {
    final isar = await db;
    return await isar.appConfigs.where().findFirst();
  }

  Future<User?> getFirstAdmin() async {
    final isar = await db;
    return await isar.users.filter().roleEqualTo(Role.admin).findFirst();
  }

  // --- MÉTODOS DE VENTAS (ÓRDENES) ---

  Future<void> saveOrder(Order order, List<OrderItem> items) async {
    final isar = await db;

    // Generar número de ticket simple si no existe
    if (order.ticketNumber == null) {
      final count = await isar.orders.count();
      order.ticketNumber = "T-${(count + 1).toString().padLeft(6, '0')}";
    }

    await isar.writeTxn(() async {
      await isar.orders.put(order);
      await isar.orderItems.putAll(items);
      order.items.addAll(items);
      await order.items.save();
    });
  }

  Future<List<Order>> getAllOrders() async {
    final isar = await db;
    return await isar.orders.where().sortByCreatedAtDesc().findAll();
  }
}
