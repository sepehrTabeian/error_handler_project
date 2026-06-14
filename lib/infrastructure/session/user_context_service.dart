abstract class UserContextService {
  String? get userId;

  bool get hasUserId;

  void setUserId(String userId);

  void clear();
}
class InMemoryUserContextService implements UserContextService {
  String? _userId;

  @override
  String? get userId => _userId;

  @override
  bool get hasUserId => _userId != null;

  @override
  void setUserId(String userId) {
    _userId = userId;
  }

  @override
  void clear() {
    _userId = null;
  }
}