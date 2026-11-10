import 'dart:io';

import '../share_code/guest_fs.dart';

/// Exact, reversible UI additions for the two known legacy component layouts.
/// No records, configuration, bundle identity or business logic are replaced.
class WishWorkUpgrade {
  static const marker = '// dsh-wish navigation v3';
  static Future<bool> apply(String work) async {
    final fs = await GuestFs.local();
    if (fs == null) return false;
    final file = fs.file('/root/.dsh/wish/workspaces/$work/client.js');
    if (!await file.exists() || await file.length() > 1500000) return false;
    var source = await file.readAsString();
    if (source.contains(marker)) return false;
    String? anchor, hook;
    if (work == 'local-hnwvo1n8rl-1kdqr9i' &&
        source.contains('const [sheet, setSheet]') &&
        source.contains('const [openGroupId, setOpenGroupId]')) {
      anchor = '      const openGroup = useMemo(';
      hook =
          '''
      $marker
      useEffect(() => {
        let off;
        const bind = () => {
          off?.(); const w = window.dshWish; if (!w?.ui?.registerNavigation) return;
          off = w.ui.registerNavigation({settings:()=>setSheet('settings'),back:()=>{
            if(sheet){setSheet(null);return true;}
            if(shot){setShot(null);return true;}
            if(agentDraft){setAgentDraft(null);return true;}
            if(groupSheet){setGroupSheet(null);return true;}
            if(openGroupId){setOpenGroupId(null);return true;}
            return false;
          }});
          w.work.describe({title:'小助',description:'个人手机助手'}).catch(()=>{});
          if(status==='ready')w.ui.ready().catch(()=>{});
        };
        bind();window.addEventListener('dsh-wish-ready',bind);
        return()=>{off?.();window.removeEventListener('dsh-wish-ready',bind);};
      },[sheet,shot,agentDraft,groupSheet,openGroupId,status]);

''';
    } else if (work == 'local-hnvuljmfee-1rteih8' && source.contains('const [settingsOpen, setSettingsOpen]')) {
      anchor = '      const finishRef = useRef(() => {});';
      hook =
          '''
      $marker
      useEffect(() => {
        let off;const bind=()=>{off?.();const w=window.dshWish;if(!w?.ui?.registerNavigation)return;
          off=w.ui.registerNavigation({settings:()=>setSettingsOpen(true),back:()=>{if(settingsOpen){setSettingsOpen(false);return true;}return false;}});
          w.work.describe({title:'番茄刻度',description:'专注与休息计时'}).catch(()=>{});
          if(store)w.ui.ready().catch(()=>{});
        };bind();window.addEventListener('dsh-wish-ready',bind);
        return()=>{off?.();window.removeEventListener('dsh-wish-ready',bind);};
      },[settingsOpen,!!store]);
''';
    }
    if (anchor == null || hook == null || !source.contains(anchor)) return false;
    final backup = File('${file.path}.pre-wish-v3');
    if (!await backup.exists()) await backup.writeAsString(source, flush: true);
    source = work == 'local-hnvuljmfee-1rteih8'
        ? source.replaceFirst(anchor, '$anchor\n$hook')
        : source.replaceFirst(anchor, '$hook$anchor');
    final temp = File('${file.path}.wish-v3-tmp');
    await temp.writeAsString(source, flush: true);
    await temp.rename(file.path);
    return true;
  }
}
