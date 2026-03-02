import 'package:appwrite/appwrite.dart';
import 'package:graphitube_app/appwrite.dart';
import 'package:graphitube_app/models/service_model.dart';

class DataService {
  static final Databases _databases = Databases(client);

  static const String databaseId = '69a4c0de001d8de37afb';
  // <--- 7et l-Collection ID dyalk hna mn Appwrite Dashboard
  static const String collectionId = 'YOUR_COLLECTION_ID';

  static Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
      );
      
      return response.documents
          .map((doc) => ServiceModel.fromMap(doc.data))
          .toList();
    } catch (e) {
      print('Appwrite Error: $e');
      return [];
    }
  }
}
