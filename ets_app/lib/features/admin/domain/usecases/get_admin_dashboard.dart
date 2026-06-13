import '../entities/admin_dashboard.dart';
import '../repositories/admin_repository.dart';

class GetAdminDashboard {
  const GetAdminDashboard(this._repository);

  final AdminRepository _repository;

  Future<AdminDashboard> call() {
    return _repository.getDashboard();
  }
}