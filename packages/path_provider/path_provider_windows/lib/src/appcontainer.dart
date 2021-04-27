import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

bool isAppContainer() {
  final phToken = calloc<HANDLE>();
  final tokenInfo = calloc<DWORD>();
  final bytesReturned = calloc<DWORD>();

  try {
    final hProcess = GetCurrentProcess();
    if (OpenProcessToken(hProcess, TOKEN_READ, phToken) == FALSE) {
      OutputDebugString(
          "Error: Couldn\'t open the process token\n".toNativeUtf16());
    }

    if (GetTokenInformation(
            phToken.value,
            TOKEN_INFORMATION_CLASS.TokenIsAppContainer,
            tokenInfo,
            sizeOf<DWORD>(),
            bytesReturned) !=
        FALSE) {
      return (tokenInfo.value != 0);
    }
    return false;
  } finally {
    free(phToken);
    free(tokenInfo);
    free(bytesReturned);
  }
}

String getRoamingAppDataPathWinUWP() {
  final currAppData = ApplicationData.Current;
  final localFolder = currAppData.LocalFolder;
  final storageItem = IStorageItem(localFolder.cast());
  final hPath = storageItem.Path;

  final path = WindowsGetStringRawBuffer(hPath, nullptr).toDartString();

  print('Local folder path: $path');

  return path;
  //RoUninitialize();
}
