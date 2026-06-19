import 'package:get/get.dart';
import 'package:cpk1989/config/constants/image_paths.dart';

class FeedItem {
  final String imagePath;
  final String userName;
  final String condition;
  final String itemName;
  final String price;
  final bool isVerified;
  final String size;
  final String wornCount;
  final String description;

  FeedItem({
    required this.imagePath,
    required this.userName,
    required this.condition,
    required this.itemName,
    required this.price,
    required this.size,
    required this.wornCount,
    required this.description,
    this.isVerified = true,
  });
}

class HomeController extends GetxController {
  final rxItems = <FeedItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFeedItems();
  }

  void _loadFeedItems() {
    rxItems.assignAll([
      FeedItem(
        imagePath: ImagePaths.onboardingImage2, // assets/images/luxury_bag.png
        userName: "Olivia Mendes",
        condition: "Excellent",
        itemName: "Classic Flap Bag",
        price: "AED 3,200",
        isVerified: true,
        wornCount: "Warn Twice",
        size: "Medium : 25cm",
        description: "Black caviar leather with gold hardware. Comes with original dust bag and authenticity card.",
      ),
      FeedItem(
        imagePath: "assets/images/luxury_heels.png",
        userName: "Sophia Rossi",
        condition: "Like New",
        itemName: "Patent Leather Heels",
        price: "AED 2,800",
        isVerified: true,
        wornCount: "Worn Once",
        size: "EU 38",
        description: "Elegant black patent leather heels with iconic red soles. Excellent condition, very minor wear on bottom.",
      ),
      FeedItem(
        imagePath: "assets/images/luxury_watch.png",
        userName: "James Miller",
        condition: "Pristine",
        itemName: "Speedmaster Chronograph",
        price: "AED 18,500",
        isVerified: true,
        wornCount: "Never Worn",
        size: "42mm",
        description: "Classic speedmaster professional chronograph luxury watch. Co-axial master chronometer with box and papers.",
      ),
    ]);
  }
}
