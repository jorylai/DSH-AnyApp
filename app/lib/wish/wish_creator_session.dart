import 'package:dsh_client/dsh_client.dart';

import 'wish_form.dart';
import 'wish_models.dart';
import 'wish_preferences.dart';
import 'wish_project.dart';

/// Both Creator entry points resolve the same verified conversation. Imported
/// works have no conversation yet; existing work conversations keep their model,
/// history and identity. Merely opening this entry never sends a model request.
Future<WishProject> ensureWishCreatorSession(DshClient client, WishProject project) async {
  final presets = await client.listAgentPresets();
  if (!presets.any((preset) => preset.id == 'cordis' && preset.broken == null)) {
    throw StateError('creator-preset-unavailable');
  }
  var sessionId = project.sessionId;
  final previous = sessionId == null ? null : await client.projections(sessionId);
  if (sessionId != null && previous == null) sessionId = null;
  if (previous != null && previous.agentPreset != 'cordis') throw StateError('creator-preset-not-active');
  final path = '/root/.dsh/wish/workspaces/${project.id}';
  final workspace = (await client.createWorkspace(path)).workspace;
  if (workspace.workspaceId.isEmpty || workspace.path != path) throw StateError('creator-workspace-unavailable');
  Map<String, dynamic>? route;
  var refreshed = false;
  if (sessionId == null) {
    route = await WishModels.ready(client);
    final created = await client.createSession(workspaceId: workspace.workspaceId, agentPreset: 'cordis');
    if (created.sessionId.isEmpty || created.agentPreset != 'cordis') {
      throw StateError('creator-preset-not-active');
    }
    sessionId = created.sessionId;
    refreshed = true;
  } else if (previous?.blank == true && !workspace.sessionIds.contains(sessionId)) {
    // Old imports made a bare, empty session. Attach that same identity to
    // its own workspace so the Web Client can restore it; keep all history.
    final adopted = await client.createSession(
      workspaceId: workspace.workspaceId,
      sessionId: sessionId,
      agentPreset: 'cordis',
    );
    if (adopted.sessionId != sessionId || adopted.agentPreset != 'cordis') {
      throw StateError('creator-session-adopt-failed');
    }
    refreshed = true;
  }
  // A label or the create response is not evidence that the running session
  // uses Creator. Never silently replace an existing non-Creator conversation.
  if ((refreshed ? await client.projections(sessionId) : previous)?.agentPreset != 'cordis') {
    throw StateError('creator-preset-not-active');
  }
  final preset = await WishPreferences.permissionPreset();
  if (!(await client.permissionPresets()).options.any((option) => option.value == preset)) {
    throw StateError('creator-approval-policy-unavailable');
  }
  if (!(await client.setPermissionPreset(sessionId, preset)).success) {
    throw StateError('creator-approval-policy-failed');
  }
  if (route == null) return project;
  await client.setModel(sessionId, provider: route['provider'] as String, model: route['model'] as String);
  final bound = WishProject(
    wishMap(await client.rpc.call('wishMobile/bind', {'form': project.id, 'sessionId': sessionId})),
  );
  if (bound.id != project.id || bound.sessionId != sessionId) throw StateError('creator-session-bind-failed');
  return bound;
}

/// A new unfinished work can have no installed plugin. For an existing work,
/// a disabled/broken plugin is a recovery error, not evidence of a new draft.
bool wishPreviewIsDraft(WishProject project, Object error) =>
    !project.published &&
    project.panel == null &&
    error is DshRemoteException &&
    error.code == 'wish/plugin-not-installed';
