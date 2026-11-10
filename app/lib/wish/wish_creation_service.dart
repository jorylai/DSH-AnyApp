import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/connection_state.dart';
import 'wish_creation_plan.dart';
import 'wish_creator.dart';
import 'wish_models.dart';

/// Optimization reuses the connected local model. It never switches a running
/// work's profile or creates a project/session just to rewrite a prompt.
final wishCreationCompleteProvider = Provider<Future<String> Function(String)>(
  (ref) => (prompt) async {
    final connection = await ref.read(localConnectionProvider.future);
    if (connection == null) throw StateError('MODEL_NOT_CONFIGURED');
    await connection.client.mux.ready();
    await WishModels.ready(connection.client);
    final response = await WishModels.complete(connection.client, prompt);
    return response['text'] as String? ?? '';
  },
);

class WishCreationSubmission {
  WishCreationSubmission({
    required this.request,
    required this.creationPlan,
    required Set<WishCreationCapability> capabilities,
    required Set<WishCreationCapability> excluded,
    required this.smart,
    this.sourceId,
  }) : capabilities = Set.unmodifiable(capabilities),
       excluded = Set.unmodifiable(excluded);
  final String request;
  final String? creationPlan;
  final Set<WishCreationCapability> capabilities, excluded;
  final bool smart;
  final String? sourceId;
}

typedef WishCreationResult = ({String sessionId, String formId, String? error});
typedef WishCreationStarter = Future<WishCreationResult> Function(WidgetRef, WishCreationSubmission);

final wishCreationStarterProvider = Provider<WishCreationStarter>(
  (_) =>
      (ref, submission) => startWishCreator(
        ref,
        submission.request,
        modules: submission.capabilities.map((c) => c.name),
        creationPlan: submission.creationPlan,
        excludedModules: submission.excluded.map((c) => c.name),
        smartSelection: submission.smart,
        sourceId: submission.sourceId,
      ),
);
