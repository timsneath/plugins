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
  final pObj = calloc<COMObject>();
  final pIID_IApplicationData = calloc<GUID>()
    ..ref.setGUID(IID_IApplicationData);
  final currAppData = ApplicationData.Current;
  currAppData.QueryInterface(pIID_IApplicationData, pObj.cast());
  final pAppData = IApplicationData(pObj);

  final pObj2 = calloc<COMObject>();
  final pIID_IStorageItem = calloc<GUID>()..ref.setGUID(IID_IStorageItem);
  final localFolder = IUnknown(pAppData.LocalFolder.cast());
  localFolder.QueryInterface(pIID_IStorageItem, pObj2.cast());

  final storageItem = IStorageItem(pObj2.cast());
  final hPath = storageItem.Path;

  final path = WindowsGetStringRawBuffer(hPath, nullptr).toDartString();

  print('Local folder path: $path');

  return path;
  //RoUninitialize();
}
