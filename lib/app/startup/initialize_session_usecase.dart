import 'package:error_handler_project/infrastructure/auth/user_id_resolver.dart';
import 'package:error_handler_project/infrastructure/session/user_context_service.dart';

class InitializeSessionUseCase {
  final UserIdResolver userIdResolver;
  final UserContextService userContextService;

  InitializeSessionUseCase({
    required this.userIdResolver,
    required this.userContextService,
  });

  Future<void> call() async {
    final userId = await userIdResolver.resolveUserId();

    if (userId == null || userId.isEmpty) {
      userContextService.clear();
      return;
    }

    userContextService.setUserId(userId);
  }
}