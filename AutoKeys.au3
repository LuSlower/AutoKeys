#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=AutoKeys.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Description=AutoKey
#AutoIt3Wrapper_Res_Fileversion=0.0.0.0
#AutoIt3Wrapper_Res_ProductName=AutoKeys
#AutoIt3Wrapper_Res_ProductVersion=0.0.0.0
#AutoIt3Wrapper_Res_CompanyName=AutoKeys
#AutoIt3Wrapper_Res_LegalCopyright=Copyright © Luis Garcia
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Tidy_Stop_OnError=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstants.au3>
#include <EditConstants.au3>
#include <TrayConstants.au3>
#include <WinAPIProc.au3>
#include <Misc.au3>
#include <Restart.au3>
#include <HotKeyInput.au3>
#include <HotKey_21b.au3>

_Singleton("AutoKeys.exe")

#Region ;INI Params
Global $INI = @ScriptDir & "\AutoKey.ini"
$save_sleep = IniRead($INI, "Config", "Sleep", "10")
$save_count = IniRead($INI, "Config", "CountKeys", "4")
$save_autokey = StringSplit(IniRead($INI, "Config", "KeySet", "WASD"), "")
$save_hotkey = IniRead($INI, "Config", "HotKey", "0x0072")
$save_keydelay = IniRead($INI, "Delay", "KeyDelay", "0")
$save_keydowndelay = IniRead($INI, "Delay", "KeyDownDelay", "0")
#EndRegion ;INI Params

Opt("SendKeyDelay", $save_keydelay) ;delete KeyDelay
Opt("SendKeyDownDelay", $save_keydowndelay) ;delete DownDelay
Opt("TrayMenuMode", 3) ;enable tray personalizado
Opt("TrayOnEventMode", 1) ;enable tray event mode
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
TraySetClick(8) ;solo clic derecho

;Tray Group
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "_close")
TraySetState($TRAY_ICONSTATE_SHOW)


Global $Main = GUICreate("AutoKeys | LuSlower", 361, 185)

;HotKey
GUICtrlCreateGroup("KeySet", 8, 8, 209, 169)
GUICtrlCreateLabel("HotKey", 95, 24, 55, 17)
$_init = _GUICtrlHKI_Create(0, 90, 45, 50, 21)
_GUICtrlHKI_SetHotKey($_init, $save_hotkey)
$vk_key = "0x" & Hex(_GUICtrlHKI_GetHotKey($_init), 2)
Local $hot_key = GUICtrlRead($_init)

;SetKeys
GUICtrlCreateLabel("SetKeys (0 - 10)", 77, 85, 80, 17)
$auto_keys = GUICtrlCreateInput("", 51, 110, 121, 21, $ES_UPPERCASE)
GUICtrlSetLimit(-1, 10, 0)
For $sCount = 1 To $save_count
	GUICtrlSetData(-1, GUICtrlRead(-1) & $save_autokey[$sCount] & "")
Next
$keys = StringSplit(GUICtrlRead($auto_keys), "")
GUICtrlCreateButton("Exit AutoKeys", 25, 140)
GUICtrlSetOnEvent(-1, "_close")
$save = GUICtrlCreateButton("Save Changes", 120, 140)
GUICtrlSetOnEvent(-1, "_save")

;Options
GUICtrlCreateGroup("Options", 224, 8, 129, 169)
GUICtrlCreateLabel("KeyDelay", 232, 25, 76, 17)
GUICtrlCreateLabel("KeyDownDelay", 232, 75, 104, 17)
$_delay = GUICtrlCreateCombo("", 232, 45, 110, 29)
GUICtrlSetData(-1, "0|1|2|3|4|5|6|7|8|9|10|")
GUICtrlSetData(-1, $save_keydelay)
$_downdelay = GUICtrlCreateCombo("", 232, 95, 110, 29)
GUICtrlSetData(-1, "0|1|2|3|4|5|6|7|8|9|10|")
GUICtrlSetData(-1, $save_keydowndelay)
GUICtrlCreateLabel("Sleep (10 - 300)", 232, 130)
$_sleep = GUICtrlCreateInput("", 232, 145, 110, 20, $ES_NUMBER)
GUICtrlSetData(-1, $save_sleep)
GUICtrlSetLimit(-1, 3, 0)
$_sSleep = GUICtrlRead(-1)

;EVENTS
GUISetOnEvent($GUI_EVENT_CLOSE, "_close")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "_hide")
TraySetOnEvent($TRAY_EVENT_PRIMARYDOWN, "_show")
GUISetState(@SW_SHOW)
_WinAPI_EmptyWorkingSet()
_HotKey_Assign($vk_key, '_autokeys', $HK_FLAG_DEFAULT)

While True
		Sleep(10)
WEnd

Func _autokeys()
For $sCount = 1 To $keys [0]
	Send($keys [$sCount], 1)
	Sleep($_sSleep)
Next
EndFunc

Func _close()
Exit
EndFunc

Func _save()
Local $keys = StringSplit(GUICtrlRead($auto_keys), "")
IniWrite($INI, "Config", "KeySet", "")
For $sCount = 1 To $keys [0]
Local $old_data = IniRead($INI, "Config", "KeySet", "default")
IniWrite($INI, "Config", "KeySet", $old_data & $keys[$sCount] & "")
Next
IniWrite($INI, "Config", "CountKeys", $keys[0])
IniWrite($INI, "Config", "HotKey", _GUICtrlHKI_GetHotKey($_init))
IniWrite($INI, "Delay", "KeyDelay", GUICtrlRead($_delay))
IniWrite($INI, "Delay", "KeyDownDelay", GUICtrlRead($_downdelay))
IniWrite($INI, "Config", "Sleep", GUICtrlRead($_sleep))
MsgBox(64, "Hecho", "Cambios guardados correctamente")
_ScriptRestart()
EndFunc

Func _show()
	_WinAPI_EmptyWorkingSet()
	GUISetState(@SW_ENABLE)
	GUISetState(@SW_UNLOCK)
	GUISetState(@SW_SHOW)
EndFunc   ;==>_show

Func _hide()
	_WinAPI_EmptyWorkingSet()
	GUISetState(@SW_DISABLE)
	GUISetState(@SW_LOCK)
	GUISetState(@SW_HIDE)
EndFunc   ;==>_hide