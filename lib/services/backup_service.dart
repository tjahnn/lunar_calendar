import '../database/app_database.dart';

// TODO: share_plus, file_picker, path_provider 패키지 추가 후 구현
class BackupService {
  final AppDatabase db;

  BackupService(this.db);

  Future<void> export() async {
    throw UnimplementedError('share_plus 패키지 추가 필요');
  }

  /// 반환값: 가져온 일정 수, 취소 시 -1
  Future<int> import() async {
    throw UnimplementedError('file_picker 패키지 추가 필요');
  }
}
