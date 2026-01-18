#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Mouse", "Screen"
DetectHiddenWindows True
SetWinDelay 0

; ============================================
; 전역 변수
; ============================================
global Taskbars := []
global LastTaskbarUpdate := 0
global TaskbarUpdateInterval := 10000  ; 10초
global IsInitialized := false

; ============================================
; 스크립트 시작시 초기화
; ============================================
SetTimer InitializeScript, -100  ; 100ms 후 초기화

InitializeScript() {
    global IsInitialized
    GetTaskbarInfo()
    IsInitialized := true
}

; ============================================
; 작업 표시줄 정보 수집 (개선됨)
; ============================================
GetTaskbarInfo() {
    global Taskbars, LastTaskbarUpdate
    
    Taskbars := []  ; 초기화
    
    ; 1. 주 모니터 작업 표시줄
    try {
        mainTaskbar := WinExist("ahk_class Shell_TrayWnd")
        if (mainTaskbar) {
            WinGetPos &X, &Y, &Width, &Height, "ahk_id " mainTaskbar
            if (Width > 0 && Height > 0) {  ; 유효성 검사
                Taskbars.Push({
                    X: X, 
                    Y: Y, 
                    Width: Width, 
                    Height: Height,
                    Type: "Primary"
                })
            }
        }
    } catch as err {
        ; 에러 무시 (작업 표시줄이 없을 수도 있음)
    }
    
    ; 2. 보조 모니터 작업 표시줄 (수정된 방법)
    try {
        ; WinGetList로 모든 Shell_SecondaryTrayWnd 찾기
        secondaryTaskbars := WinGetList("ahk_class Shell_SecondaryTrayWnd")
        
        for hwnd in secondaryTaskbars {
            try {
                WinGetPos &X, &Y, &Width, &Height, "ahk_id " hwnd
                if (Width > 0 && Height > 0) {  ; 유효성 검사
                    Taskbars.Push({
                        X: X, 
                        Y: Y, 
                        Width: Width, 
                        Height: Height,
                        Type: "Secondary"
                    })
                }
            }
        }
    } catch as err {
        ; 에러 무시
    }
    
    LastTaskbarUpdate := A_TickCount
    
    ; 디버깅용: 찾은 작업 표시줄 개수 확인 (필요시 주석 해제)
    ; ToolTip "작업 표시줄 " Taskbars.Length "개 감지됨"
    ; SetTimer () => ToolTip(), -2000
}

; ============================================
; 작업 표시줄 정보 업데이트 (필요시)
; ============================================
UpdateTaskbarInfoIfNeeded() {
    global LastTaskbarUpdate, TaskbarUpdateInterval, IsInitialized
    
    ; 초기화되지 않았으면 즉시 업데이트
    if (!IsInitialized) {
        GetTaskbarInfo()
        return
    }
    
    ; 일정 시간 경과시에만 업데이트
    if (A_TickCount - LastTaskbarUpdate > TaskbarUpdateInterval) {
        GetTaskbarInfo()
    }
}

; ============================================
; 마우스가 작업 표시줄 위에 있는지 확인
; ============================================
MouseInTaskbar() {
    global Taskbars
    
    ; 주기적 업데이트 체크
    UpdateTaskbarInfoIfNeeded()
    
    ; 작업 표시줄 정보가 없으면 false
    if (Taskbars.Length = 0) {
        return false
    }
    
    ; 마우스 위치 가져오기 (한 번만)
    MouseGetPos &MouseX, &MouseY
    
    ; 각 작업 표시줄 영역 확인
    for bar in Taskbars {
        ; 여유 공간 추가 (클릭 감지 개선)
        margin := 5
        
        if (MouseX >= (bar.X - margin) && 
            MouseX <= (bar.X + bar.Width + margin) && 
            MouseY >= (bar.Y - margin) && 
            MouseY <= (bar.Y + bar.Height + margin)) {
            return true
        }
    }
    
    return false
}

; ============================================
; 볼륨 조절 함수
; ============================================
AdjustVolume(direction) {
    if (direction = "up") {
        Send "{Volume_Up}"
    } else if (direction = "down") {
        Send "{Volume_Down}"
    }
}

; ============================================
; 핫키 설정 (조건부 실행)
; ============================================
; #HotIf 대신 핫키 내부에서 조건 확인 (시스템 간섭 방지)
WheelUp:: {
    if (MouseInTaskbar()) {
        AdjustVolume("up")
    } else {
        Send "{WheelUp}"  ; 태스크바가 아니면 원래 동작 전달
    }
}

WheelDown:: {
    if (MouseInTaskbar()) {
        AdjustVolume("down")
    } else {
        Send "{WheelDown}"  ; 태스크바가 아니면 원래 동작 전달
    }
}

; ============================================
; 수동 업데이트 핫키 (선택사항)
; ============================================
F12:: {
    GetTaskbarInfo()
    ToolTip "작업 표시줄 정보 업데이트됨`n감지된 개수: " Taskbars.Length
    SetTimer () => ToolTip(), -2000
}

; ============================================
; 디스플레이 설정 변경시 자동 업데이트
; ============================================
OnMessage(0x007E, WM_DISPLAYCHANGE)  ; WM_DISPLAYCHANGE

WM_DISPLAYCHANGE(wParam, lParam, msg, hwnd) {
    ; 모니터 설정이 변경되면 1초 후 업데이트
    SetTimer () => GetTaskbarInfo(), -1000
}