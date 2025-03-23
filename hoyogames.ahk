#Requires AutoHotkey v2.0

; Global variables
targetWindowID := "" ; Stores the ID of the target window
targetWindowTitle := "" ; Stores the title of the target window
toggle := false ; Controls whether the auto-key function is running

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

    ; Toggle the auto-key functionality when PgDn is pressed
PgDn::
    {
        global targetWindowID, targetWindowTitle, toggle

        ; Check if a target window has been set
        if (targetWindowID = "") {
            MsgBox("Please set a target window first using Page Up")
            return
        }

        ; Toggle the auto-key state
        toggle := !toggle

        if (toggle) {
            ; If turning ON
            ToolTip("Auto skip is turned ON in the window " targetWindowTitle)
            SetTimer () => ToolTip(), -1000

            ; Start the key sequence
            SetTimer GameKeys, 0
        } else {
            ; If turning OFF
            ToolTip("Auto skip is turned OFF in the window " targetWindowTitle)
            SetTimer () => ToolTip(), -1000

            ; Stop the timer
            SetTimer GameKeys, 0
        }
    }

    ; Main function that performs the key sending for games
    GameKeys() {
        global targetWindowID, targetWindowTitle, toggle

        ; Exit if toggle is off
        if (!toggle) {
            return
        }

        ; Check if the target window still exists
        if WinExist("ahk_id " targetWindowID) {
            ; Make sure the window is active
            if (WinGetID("A") != targetWindowID) {
                WinActivate("ahk_id " targetWindowID)
                Sleep(100) ; Give window time to activate
            }

            ; Send key "1" using SendPlay
            SendPlay("1")
            Sleep(50)

            ; Send key "F" using SendPlay
            SendPlay("{F}")

            Sleep(100)

            ; Schedule the next iteration
            SetTimer GameKeys, -10
        } else {
            ; If window no longer exists, stop the auto-key function
            toggle := false
            MsgBox("Target window not found. Stopping key sequence.")
            SetTimer GameKeys, 0
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