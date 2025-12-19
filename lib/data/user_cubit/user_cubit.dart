import 'package:coffee_pos/data/user_cubit/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/users_repository.dart';

class UsersCubit extends Cubit<UsersState> {
  final UsersRepository repo;

  UsersCubit(this.repo) : super(UsersInitial());

  // ===== جلب الموظفين =====
  Future<void> loadEmployees() async {
    emit(UsersLoading());
    try {
      final employees = await repo.getAllEmployees();
      emit(UsersLoaded(employees));
    } catch (e) {
      emit(UsersError('فشل تحميل البيانات'));
    }
  }

  // ===== إضافة موظف =====
  Future<void> addEmployee({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      await repo.addUser(
        name: name,
        username: username,
        password: password,
        role: role,
      );
      await loadEmployees(); // ✅ تحديث البيانات بعد الإضافة
    } catch (e) {
      emit(UsersError('فشل إضافة الموظف: ${e.toString()}'));
    }
  }

  // ===== حذف موظف =====
  Future<void> deleteEmployee(int id) async {
    try {
      final db = await repo.dbHelper.database;
      await db.delete('users', where: 'id = ?', whereArgs: [id]);
      await loadEmployees(); // تحديث البيانات بعد الحذف
    } catch (e) {
      emit(UsersError('فشل حذف الموظف'));
    }
  }
}
