Option Explicit

Dim objFSO, objHTTP, scriptPath, scriptDir, resultsDir
Set objFSO = CreateObject("Scripting.FileSystemObject")

' 1. Establish project directory layouts dynamically
scriptPath = WScript.ScriptFullName
scriptDir = objFSO.GetParentFolderName(scriptPath)
resultsDir = objFSO.GetAbsolutePathName(scriptDir & "\..\results")

If Not objFSO.FolderExists(resultsDir) Then
    objFSO.CreateFolder(resultsDir)
End If

' 2. Parse target input from CLI argument or pop an input box
Dim targetDomain, args
Set args = WScript.Arguments

If args.Count > 0 Then
    targetDomain = args(0)
Else
    targetDomain = InputBox("Enter the domain to audit SSL status (e.g., google.com):", "SSL Handshake Auditor", "google.com")
End If

If Trim(targetDomain) = "" Then
    WScript.Echo "No target entered. Exiting."
    WScript.Quit
End If

' Strip off any accidental prefix bindings the user might copy-paste
targetDomain = Replace(LCase(targetDomain), "https://", "")
targetDomain = Replace(targetDomain, "http://", "")
targetDomain = Split(targetDomain, "/")(0)

' 3. Setup safe timestamp filenames
Dim timestamp, filename, filePath
timestamp = Year(Now) & Right("0" & Month(Now), 2) & Right("0" & Day(Now), 2) & "_" & Right("0" & Hour(Now), 2) & Right("0" & Minute(Now), 2) & Right("0" & Second(Now), 2)
filename = "sslcheck_" & targetDomain & "_" & timestamp & ".txt"
filePath = resultsDir & "\" & filename

' Initialize structural log lines
Dim outputText, logLine
outputText = "=======================================================" & vbCrLf & _
             "            DEEP CORE SSL HANDSHAKE AUDIT LOG          " & vbCrLf & _
             "=======================================================" & vbCrLf & _
             "Target Domain : " & targetDomain & vbCrLf & _
             "Run Timestamp : " & Now & vbCrLf & _
             String(55, "=") & vbCrLf & vbCrLf

WScript.Echo "🔍 Testing secure capabilities and validating TLS handshakes for: " & targetDomain & "..."

' 4. Core Handshake Testing Routine
On Error Resume Next
Set objHTTP = CreateObject("Msxml2.ServerXMLHTTP.6.0")

' Test 1: Fire a standard connection request to test native handshake trust
objHTTP.open "GET", "https://" & targetDomain, False
objHTTP.send

Dim sslTrustState, sslErrorCode
sslErrorCode = Err.Number

If sslErrorCode = 0 Then
    sslTrustState = "✅ Verified Secure (Handshake Completed Successfully without trust chain errors)"
    Err.Clear
Else
    ' Identify common system handshake failures based on error hex definitions
    Select Case Hex(sslErrorCode)
        Case "80072F0D"
            sslTrustState = "❌ ALERT: Invalid/Untrusted CA Certificate Authority Chain"
        Case "80072F06"
            sslTrustState = "❌ ALERT: Domain Name Mismatch (Common Name does not match host)"
        Case "80072F19"
            sslTrustState = "❌ ALERT: Certificate Expiration Error (The cert is already expired)"
        Case Else
            sslTrustState = "⚠️ Warning: Handshake Error / Connection Blocked (" & Err.Description & ")"
    End Select
    Err.Clear
End If

' 5. Test 2: Bypassing local checking blocks to query direct parameters
' Option 2, 13056 instructs the engine to force its way through broken chains to pull status codes
objHTTP.open "GET", "https://" & targetDomain, False
objHTTP.setOption 2, 13056 
objHTTP.send

Dim webStatusLine
If Err.Number = 0 Then
    webStatusLine = "Online (Server returned HTTP Status Code " & objHTTP.Status & " " & objHTTP.statusText & ")"
Else
    webStatusLine = "Offline or Connection Refused by Remote Target"
End If
On Error GoTo 0

' 6. Compile metrics into the final log file format
logLine = "[1. SECURITY HANDSHAKE METRICS]" & vbCrLf & _
          "  - Connection State: " & webStatusLine & vbCrLf & _
          "  - Trust Validation: " & sslTrustState & vbCrLf & vbCrLf & _
          "[2. ENCRYPTION PROTOCOLS & STATUS]" & vbCrLf & _
          "  - Handshake Object : MSXML2.ServerXMLHTTP.6.0 Engine" & vbCrLf & _
          "  - Target Endpoint  : https://" & targetDomain & ":443" & vbCrLf

WScript.Echo vbCrLf & logLine
outputText = outputText & logLine

' 7. Commit and write the results log file permanently
Dim objFile
Set objFile = objFSO.CreateTextFile(filePath, True)
objFile.Write outputText
objFile.Close

WScript.Echo "=======================================================" & vbCrLf & _
             "💾 Report processing complete! Data kept permanently." & vbCrLf & _
             "📂 Saved Path: " & filePath & vbCrLf & _
             "======================================================="
