
#include "window_manager.h"
#include <vector>
#include <string>
#include <algorithm>

// Define the target window titles
const std::vector<std::wstring> target_titles = {
    L"Antigravity",
    L"Google Chrome",
    L"Mozilla Firefox"
};

// Callback function for EnumWindows
BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam) {
    const int title_length = 256;
    WCHAR window_title[title_length];
    if (GetWindowTextW(hwnd, window_title, title_length)) {
        std::wstring title_str(window_title);
        OutputDebugStringW(title_str.c_str());
        OutputDebugStringW(L"\n");
        for (const auto& target : target_titles) {
            // Case-insensitive search
            std::wstring lower_title_str = title_str;
            std::transform(lower_title_str.begin(), lower_title_str.end(), lower_title_str.begin(), ::towlower);
            std::wstring lower_target = target;
            std::transform(lower_target.begin(), lower_target.end(), lower_target.begin(), ::towlower);

            if (lower_title_str.find(lower_target) != std::wstring::npos) {
                // Minimize the window
                ShowWindow(hwnd, SW_MINIMIZE);
            }
        }
    }
    return TRUE; // Continue enumeration
}

void MinimizeTargetWindows() {
    EnumWindows(EnumWindowsProc, 0);
}
