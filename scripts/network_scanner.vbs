Option Explicit

Dim objFSO, objWMIService, scriptPath, scriptDir, resultsDir
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")

' 1. Find your exact folder paths dynamically
scriptPath = WScript.ScriptFullName
scriptDir = objFSO.GetParentFolderName(scriptPath)
resultsDir = objFSO.GetAbsolutePathName(scriptDir & "\..\results")

' 2. FORCE check/create the results folder so it NEVER fails to save
If Not objFSO.FolderExists(resultsDir) Then
    objFSO.CreateFolder(resultsDir)
End If

' Handle target inputs cleanly
Dim targetBase, i, args
Set args = WScript.Arguments

If args.Count > 0 Then
    targetBase = args(0)
Else
    targetBase = InputBox("Enter the first 3 octets of your network to scan (e.g., 192.168.1):", "Network Scanner", "192.168.1")
End If

If Trim(targetBase) = "" Then
    WScript.Echo "No target network entered. Exiting."
    WScript.Quit
End If

If Right(targetBase, 1) = "." Then
    targetBase = Left(targetBase, Len(targetBase) - 1)
End If

' 3. Create a totally unique file name using your requested layout: netscan_%target%_%TIME%.txt
Dim timestamp, filename, filePath
timestamp = Year(Now) & Right("0" & Month(Now), 2) & Right("0" & Day(Now), 2) & "_" & Right("0" & Hour(Now), 2) & Right("0" & Minute(Now), 2) & Right("0" & Second(Now), 2)
filename = "netscan_" & targetBase & "_" & timestamp & ".txt"
filePath = resultsDir & "\" & filename

' Initialize structural log file format
Dim outputText, logLine
outputText = "Detailed Network Scan Results" & vbCrLf & _
             "Target Subnet: " & targetBase & ".0/24" & vbCrLf & _
             "Timestamp: " & Now & vbCrLf & _
             String(60, "=") & vbCrLf & vbCrLf

WScript.Echo "🔍 Subnet Deep Scan Started: " & targetBase & ".1 to .254"
WScript.Echo "Gathering Hostnames completely in background..." & vbCrLf

' Run the loop using WMI network status flags
Dim currentIP, colPings, objPing, hostName
For i = 1 To 254
    currentIP = targetBase & "." & i
    
    ' Query the network driver instantly for the IP target
    Set colPings = objWMIService.ExecQuery("SELECT * FROM Win32_PingStatus WHERE Address = '" & currentIP & "' AND Timeout = 120")
    
    For Each objPing in colPings
        ' If the node answers, pull systemic details about it
        If objPing.StatusCode = 0 Then
            
            ' Resolve Hostname / Device Computer Name
            hostName = ResolveHostname(currentIP)
            
            ' Formulate cleanly spaced terminal output lines
            logLine = "📍 IP Address : " & currentIP & vbCrLf & _
                      "   ↳ Hostname : " & hostName & vbCrLf & _
                      "   ↳ Latency  : " & objPing.ResponseTime & " ms" & vbCrLf
                      
            WScript.Echo logLine
            outputText = outputText & logLine & vbCrLf
        End If
    Next
Next

' 4. COMMIT AND KEEP THE RESULTS: This writes the file permanently to the results directory
Dim objFile
Set objFile = objFSO.CreateTextFile(filePath, True)
objFile.Write outputText
objFile.Close

WScript.Echo "💾 Deep scan complete! All active device logs are permanently saved to:" & vbCrLf & "📂 " & filePath


' Helper function to query the system for real hostname resolutions
Function ResolveHostname(strIP)
    On Error Resume Next
    Dim objExec, strOutput, arrLines, j, host
    Dim objShell: Set objShell = CreateObject("WScript.Shell")
    
    ' Query local reverse lookups via standard shell lookup commands
    Set objExec = objShell.Exec("nslookup " & strIP)
    strOutput = objExec.StdOut.ReadAll
    
    host = "Unknown (No DNS Name Found)"
    arrLines = Split(strOutput, vbCrLf)
    
    For j = 0 To UBound(arrLines)
        If InStr(LCase(arrLines(j)), "name:") > 0 Then
            host = Trim(Mid(arrLines(j), InStr(arrLines(j), ":") + 1))
            Exit For
        End If
    Next
    
    ResolveHostname = host
End Function


