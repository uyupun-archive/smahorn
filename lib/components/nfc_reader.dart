import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smahorn/constants/identifiers.dart';
import 'package:smahorn/utils/play_audio.dart';

class NfcReader extends HookWidget {
  const NfcReader({super.key});

  @override
  Widget build(BuildContext context) {
    final nfcManager = useState(NfcManager.instance);
    final isReading = useState(false);

    final reader = useCallback(() async {
      isReading.value = true;
      final check = await nfcManager.value.isAvailable();

      if (!check) {
        isReading.value = false;
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text('⚠️ エラー'),
                content: Text("NFC非対応の端末です"),
              );
            },
          );
        }
      }

      await nfcManager.value.startSession(
        onDiscovered: (NfcTag tag) async {
          print('🤖 startSession');
          final ndef = Ndef.from(tag);
          if (ndef != null) {
            final id = ndef.additionalData['identifier'];
            print(id);
            final tone = tones.entries.firstWhereOrNull(
              (ele) => listEquals(ele.value, id),
            );
            if (tone != null) {
              playAudio(tone.key);
            }
          } else {
            print("🤖 Tag is not compatible with NDEF");
          }
        },
        onError: (NfcError error) async {
          print("Error: ${error.type} - ${error.message}");
        },
      );
    }, [nfcManager.value, isReading.value]);

    useEffect(() {
      return () => nfcManager.value.stopSession();
    }, [nfcManager.value]);

    return ElevatedButton(
      onPressed: () async {
        if (isReading.value) {
          isReading.value = false;
          nfcManager.value.stopSession();
        } else {
          await reader();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      child: Text(isReading.value ? 'やめる' : '読み込む'),
    );
  }
}
