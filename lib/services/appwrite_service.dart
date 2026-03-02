import 'package:appwrite/appwrite.dart';
import 'package:graphitube_app/config/environment.dart'; // <--- Zid hadi

class AppwriteService {
  static final Client client = Client();
  static late final Account account;
  static late final Databases databases;

  static void init() {
    client
        .setEndpoint(Environment.appwritePublicEndpoint) // Sta3mel l-Environment
        .setProject(Environment.appwriteProjectId)    // Sta3mel l-Environment
        .setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
  }
}
