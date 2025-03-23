#Requires AutoHotkey v2.0

; Global variables
targetWindowID := "" ; Stores the ID of the target window
targetWindowTitle := "" ; Stores the title of the target window
toggle := false ; Controls whether the auto-click function is running

; Set the target window to the currently active window when PgUp is pressed
PgUp::
    {
        global targetWindowID, targetWindowTitle

        ; Get the ID and title of the active window
        targetWindowID := WinGetID("A")
        targetWindowTitle := WinGetTitle("A")

        ; Show a tooltip to confirm the target window was set
        ToolTip("Target window set to: " targetWindowTitle)

        ; Hide the tooltip after 1 second
        SetTimer () => ToolTip(), -1000
    }

    ; Toggle the auto-clicking functionality when PgDn is pressed
PgDn::
    {
        global targetWindowID, targetWindowTitle, toggle

        ; Check if a target window has been set
        if (targetWindowID = "") {
            MsgBox("Please set a target window first using Page Up")
            return
        }

        ; Toggle the auto-click state
        toggle := !toggle

        if (toggle) {
            ; If turning ON
            ToolTip("Auto skip is turned ON in the window " targetWindowTitle)
            SetTimer () => ToolTip(), -1000

            ; Start the clicking sequence
            SetTimer SpamKeys, 0
        } else {
            ; If turning OFF
            ToolTip("Auto skip is turned OFF in the window " targetWindowTitle)
            SetTimer () => ToolTip(), -1000

            ; Stop the timer
            SetTimer SpamKeys, 0
        }
    }

    ; Main function that performs the clicking and key sending
    SpamKeys() {
        global targetWindowID, targetWindowTitle, toggle

        ; Exit if toggle is off
        if (!toggle) {
            return
        }

        ; Check if the target window still exists
        if WinExist("ahk_id " targetWindowID) {
            ; Activate the window first
            WinActivate("ahk_id " targetWindowID)
            Sleep(50) ; Give window time to activate

            ; Send clicks using ControlClick with proper syntax
            ControlClick("x100 y100", "ahk_id " targetWindowID) ; Adjust coordinates as needed
            Sleep(50)
            ControlClick("x100 y100", "ahk_id " targetWindowID) ; Adjust coordinates as needed

            ; Send keys using Send instead of ControlSend for better reliability
            Send("1")
            Send("F")

            Sleep(100)

            ; Schedule the next iteration
            SetTimer SpamKeys, -10
        } else {
            ; If window no longer exists, stop the auto-clicking
            toggle := false
            MsgBox("Target window not found. Stopping spam.")
            SetTimer SpamKeys, 0
        }
    }

    ; Run script as admin if not already running with admin privileges
    if !A_IsAdmin {
        try {
            Run('*RunAs "' A_ScriptFullPath '"')
        } catch as e {
            MsgBox("Failed to restart with admin privileges. Error: " e.Message)
        }
        ExitApp
    }