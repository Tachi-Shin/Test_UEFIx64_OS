#include <efi.h>
#include <efilib.h>

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    InitializeLib(ImageHandle, SystemTable);
	ST->ConOut->ClearScreen(ST->ConOut);
    Print(L"\r\n\r\n");
	Print(L"  ===============================\r\n");
	Print(L"  Hello x64 UEFI World!\r\n");
	Print(L"  ===============================\r\n");
	Print(L"\r\n");
	Print(L"  Boot successful!\r\n");
	Print(L"\r\n");
    while (1) { }
    return EFI_SUCCESS;
}
