Dim objShell, objFSO, targetIP, strDate, strTime, fileName, parentPath, resultsFolder, fullPath

targetIP = InputBox("Enter the IP address or hostname to trace:", "Traceroute Tool", "8.8.8.8")

If targetIP <> "" Then
    Set objShell = CreateObject("WScript.Shell")
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    
    ' Format current date and time safely for filenames (e.g., YYYYMMDD_HHMMSS)
    strDate = Year(Now) & Right("0" & Month(Now), 2) & Right("0" & Day(Now), 2)
    strTime = Right("0" & Hour(Now), 2) & Right("0" & Minute(Now), 2) & Right("0" & Second(Now), 2)
    
    ' 1. Determine "cd .." directory (Parent Folder)
    parentPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
    parentPath = objFSO.GetParentFolderName(parentPath)
    
    ' 2. Determine "cd \results" directory
    resultsFolder = parentPath & "\results"
    
    ' Create the results folder if it doesn't already exist
    If Not objFSO.FolderExists(resultsFolder) Then
        objFSO.CreateFolder(resultsFolder)
    End If
    
    ' Build final filename and path
    fileName = "trace" & targetIP & "_" & strDate & "_" & strTime & ".txt"
    fullPath = resultsFolder & "\" & fileName
    
    ' 3. Execute traceroute, save output, and auto-start the txt file
    ' cmd /c runs the traceroute hidden, then starts the output text file immediately after
    objShell.Run "cmd /c tracert " & targetIP & " > """ & fullPath & """ && start """" """ & fullPath & """", 1, False
End If
