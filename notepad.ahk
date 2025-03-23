#Requires AutoHotkey v2.0

; Global variables
targetWindowID := "" ; Stores the ID of the target window
targetWindowTitle := "" ; Stores the title of the target window
toggle := false ; Controls whether the auto-type function is running

; Set the target window to the currently active window when PgUp is pressed
PgUp::
    {
        global targetWindowID, targetWindowTitle

        ; Get the ID and title of the active window
        targetWindowID := WinGetID("A")
        targetWindowTitle := WinGetTitle("A")

        ; Show a tooltip to confirm the target window was set
        ToolTip("Target window set to: " targetWindowTitle)

        ; Hide the tooltip after 2 seconds
        SetTimer () => ToolTip(), -2000
    }

    ; Toggle the auto-typing functionality when PgDn is pressed
PgDn::
    {
        global targetWindowID, targetWindowTitle, toggle

        ; Check if a target window has been set
        if (targetWindowID = "") {
            MsgBox("Vui lòng đặt cửa sổ mục tiêu trước bằng cách nhấn Page Up")
            return
        }

        ; Toggle the auto-type state
        toggle := !toggle

        if (toggle) {
            ; If turning ON
            ToolTip("Tự động gõ đang BẬT cho cửa sổ " targetWindowTitle)
            SetTimer () => ToolTip(), -2000

            ; Start the typing sequence
            SetTimer TypeKeys, 100
        } else {
            ; If turning OFF
            ToolTip("Tự động gõ đang TẮT cho cửa sổ " targetWindowTitle)
            SetTimer () => ToolTip(), -2000

            ; Stop the timer
            SetTimer TypeKeys, 0
        }
    }

    ; Main function that performs the typing
    TypeKeys() {
        global targetWindowID, targetWindowTitle, toggle

        ; Exit if toggle is off
        if (!toggle) {
            return
        }

        ; Check if the target window still exists
        if WinExist("ahk_id " targetWindowID) {
            ; Try different approaches to send text

            ; Method 1: Activate and use Send
            WinActivate("ahk_id " targetWindowID)
            Sleep(100) ; Give window time to activate
            Send("Test ")

            ; Alternative methods if the above doesn't work:

            ; Method 2: Try ControlSend with default control
            ; ControlSend("Test ", , "ahk_id " targetWindowID)

            ; Method 3: Try ControlSendText (often works better in some applications)
            ; ControlSendText("Test ", , "ahk_id " targetWindowID)
        } else {
            ; If window no longer exists, stop the auto-typing
            toggle := false
            MsgBox("Không tìm thấy cửa sổ mục tiêu. Dừng tự động gõ.")
            SetTimer TypeKeys, 0
        }
    }