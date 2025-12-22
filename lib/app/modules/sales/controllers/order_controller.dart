
import 'package:get/get.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_model.dart';
import 'package:stock_managament_admin/app/modules/sales/controllers/order_service.dart';
import 'package:stock_managament_admin/app/product/init/packages.dart';

class OrderController extends GetxController {
  // Gözlemlenebilir listeler
  var allOrders = <OrderModel>[].obs;
  var searchResult = <OrderModel>[].obs;

  // Veri yüklenme durumunu takip etmek için
  var isLoading = true.obs;
  // İlk veri setini kaybetmemek için bir yedek liste
  var _originalOrders = <OrderModel>[];
  final OrderService _orderService = OrderService();

  // Toplamlar için Rx değişkenleri
  var sumCost = 0.0.obs;
  var sumPrice = 0.0.obs;
  var sumProductCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders(); // Controller ilk oluşturulduğunda verileri çek
  }

  // Verileri servisten çekmek için merkezi bir fonksiyon
  Future<void> fetchOrders() async {
    try {
      isLoading(true); // Yükleme başladı
      final orders = await OrderService().getOrders();
      _originalOrders = List.from(orders); // Filtrelemeyi sıfırlamak için orijinal listeyi sakla
      allOrders.assignAll(orders);
      calculateTotals();
    } catch (e) {
      // Hata yönetimi eklenebilir. Örneğin bir hata mesajı göstermek için.
      print("Error fetching orders: $e");
    } finally {
      isLoading(false); // Yükleme bitti
    }
  }

  void filterByStatus(String status) {
    if (status.isEmpty) {
      clearFilter();
      return;
    }
    var filteredList = _originalOrders.where((element) {
      return element.status.toString().toLowerCase() == status.toLowerCase();
    }).toList();

    allOrders.assignAll(filteredList);
    Get.back();
    // Arama yapılıyorsa arama sonuçlarını da güncellemek mantıklı olabilir
  }

  void clearFilter() {
    allOrders.assignAll(_originalOrders);
    Get.back();
  }

  void addOrder(OrderModel model) {
    _originalOrders.insert(0, model);
    allOrders.insert(0, model);
    calculateTotals();
  }

  Future<void> createNewOrder({required OrderModel model, required List<Map<String, int>> products}) async {
    try {
      final newOrder = await _orderService.createOrder(model: model, products: products);
      print(newOrder);
      if (newOrder != null) {
        addOrder(newOrder); // addOrder metodu _originalOrders ve allOrders'ı günceller
        CustomWidgets.showSnackBar('success'.tr, 'Order added successfully'.tr, Colors.green);
        await Future.delayed(const Duration(milliseconds: 100));
        Get.back();
      } else {
        CustomWidgets.showSnackBar('error'.tr, 'Order not added'.tr, Colors.red);
      }
    } catch (e) {
      CustomWidgets.showSnackBar('error'.tr, 'An error occurred: $e'.tr, Colors.red);
    }
  }

  Future<void> deleteOrderFromUI({required OrderModel model}) async {
    try {
      // Önce API'ye isteği gönder ve başarılı olup olmadığını bekle.
      final bool success = await _orderService.deleteOrder(orderId: model.id);

      if (success) {
        // API isteği BAŞARILI ise UI'ı güncelle.
        _originalOrders.removeWhere((o) => o.id == model.id);
        allOrders.removeWhere((o) => o.id == model.id);
        if (searchResult.isNotEmpty) {
          searchResult.removeWhere((o) => o.id == model.id);
        }
        calculateTotals();

        // ÖNEMLİ: Önce snackbar göster, sonra sayfaları kapat
        // Route kapanmadan önce snackbar gösterilmeli
        CustomWidgets.showSnackBar('success'.tr, 'Order deleted successfully'.tr, Colors.green);

        // Snackbar'ın göründüğünden emin olmak için kısa bir gecikme
        await Future.delayed(const Duration(milliseconds: 100));

        // Sayfaları kapat
        Get.back(); // Onay dialog'unu kapat.
        Get.back(); // OrderProductsView sayfasını kapat.
      } else {
        // API isteği BAŞARISIZ ise kullanıcıya hata mesajı göster.
        CustomWidgets.showSnackBar('error'.tr, 'Failed to delete order. Please try again.'.tr, Colors.red);
      }
    } catch (e) {
      // Genel bir hata (örn. internet kopması) olursa yakala.
      CustomWidgets.showSnackBar('error'.tr, 'An error occurred: $e'.tr, Colors.red);
    }
  }

  void calculateTotals() {
    double totalSell = 0;
    double totalCost = 0;
    int totalCount = 0;
    // Toplamları her zaman orijinal filtrelenmemiş listeden hesaplamak daha doğru olabilir
    // Ancak mevcut mantıkta allOrders üzerinden gidiliyor, bu da filtrelenmiş görünümün toplamını verir.
    // Eğer genel toplam isteniyorsa _originalOrders kullanılmalı.
    for (var product in allOrders) {
      if (product.status == "2") {
        // "Tamamlandı" statusu varsayımı
        final sell = double.tryParse(product.totalsum.replaceAll(',', '.')) ?? 0.0;
        final cost = double.tryParse(product.totalchykdajy.replaceAll(',', '.')) ?? 0.0;
        final count = product.count ?? 0;

        totalSell += sell;
        totalCost += cost;
        totalCount += count;
      }
    }
    sumPrice.value = totalSell;
    sumCost.value = totalCost;
    sumProductCount.value = totalCount;
  }

  // Arama fonksiyonu _originalOrders üzerinde çalışmalı ki filtreler sıfırlandığında kayıp olmasın
  void onSearchTextChanged(String word) {
    if (word.isEmpty) {
      searchResult.clear();
      allOrders.assignAll(_originalOrders); // Arama bitince orijinal listeye dön
      return;
    }
    List<String> searchTerms = word.trim().toLowerCase().split(' ');
    var filteredList = _originalOrders.where((product) {
      final productNameString = (product.name).toLowerCase();
      final clientPhoneString = (product.clientDetailModel?.phone?.toString() ?? "").toLowerCase();
      final clientNameString = (product.clientDetailModel?.name.toString() ?? "").toLowerCase();
      return searchTerms.every((term) {
        return productNameString.contains(term) || clientPhoneString.contains(term) || clientNameString.contains(term);
      });
    }).toList();
    searchResult.assignAll(filteredList);
    allOrders.assignAll(filteredList); // Ana listeyi de arama sonucuyla güncelle
  }

  void editOrderInList(OrderModel updatedOrder) {
    // _originalOrders listesini güncelle
    int originalIndex = _originalOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (originalIndex != -1) {
      _originalOrders[originalIndex] = updatedOrder;
    }

    // Ekranda görünen listeyi (allOrders) güncelle
    int displayIndex = allOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (displayIndex != -1) {
      allOrders[displayIndex] = updatedOrder;
    }

    calculateTotals(); // Toplamları yeniden hesapla
  }

  // Bu metot OrderProductsView'de kullanıldığı için kalmalı
  dynamic getProductSortValue(SearchModel model, String key) {
    switch (key) {
      case 'name':
        return model.name ?? '';
      case 'count':
        return model.count ?? 0;
      case 'price':
        return double.tryParse(model.price) ?? 0.0;
      case 'cost':
        return double.tryParse(model.cost) ?? 0.0;
      case 'brends':
        return model.brend?.name ?? '';
      case 'category':
        return model.category?.name ?? '';
      case 'location':
        return model.location?.name ?? '';
      default:
        return '';
    }
  }
}
