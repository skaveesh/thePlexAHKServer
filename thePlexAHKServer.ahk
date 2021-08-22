#Persistent
#SingleInstance, force
SetBatchLines, -1

#include resource/AHKhttp.ahk
#include resource/AHKsock.ahk

paths := {}
paths["/"] := Func("Index")
paths["/plex"] := Func("PlexCmd")
paths["404"] := Func("NotFound")

server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/resource/mime.types")
server.SetPaths(paths)
server.Serve(8998)
return

NotFound(ByRef req, ByRef res) {
    res.SetBodyText("Page not found")
}

Index(ByRef req, ByRef res, ByRef server) {
    server.ServeFile(res, A_ScriptDir . "/resource/index.html")
    res.status := 200
}

PlexCmd(ByRef req, ByRef res) {

    requestCmd := req.queries["action"]

    if WinExist("Plex"){

        if (requestCmd = "playpause" || requestCmd = "forward" || requestCmd = "back" || requestCmd = "fullscreen") {

            WinActivate, Plex

            if (requestCmd = "playpause") {
                SetTitleMatchMode, 2
                SendInput {Space}
            }
            else if (requestCmd = "forward") {
               SetTitleMatchMode, 2
               SendInput {Right}
             }
            else if (requestCmd = "back") {
               SetTitleMatchMode, 2
               SendInput {Left}
            } else if (requestCmd = "fullscreen") {
	       SetTitleMatchMode, 2
               SendInput {\} 
	    }

	    res.SetBodyText(Format("{""PlexCommand"": ""`{}`""}", requestCmd))
            res.status := 200

        } else if (requestCmd = "pausemin") { ; if window is not minimized pause and minimize | if window is minimized, restore and play

            WinGet, PlexState, MinMax, Plex
            
            SetTitleMatchMode, 2
            if InStr(PlexState, "-1")
            {
                WinActivate, Plex ; WinGet will not work correctly if WinActive is called beforehand. That's why "pausemin" is separated to an another else if branch
                SendInput {Space}
            }
            else
            {
                WinActivate, Plex
                SendInput {Space}
                WinMinimize, Plex
            }
	   
            res.SetBodyText(Format("{""PlexCommand"": ""`{}`""}", requestCmd))
            res.status := 200 

        } 
        else {
           res.SetBodyText(Format("{""PlexCommand"": ""`{}`""}", "Command not found"))
           res.status := 404

        }
    }
    else {
        res.SetBodyText(Format("{""PlexCommand"": ""`{}`""}", "Plex window not found"))
        res.status := 404
        
    }
}
