' KernelKommando
' KexTools Installer Launcher
' We need to do it this way to work around all of the 
' Windows INF quirks...

'
' FUNCTIONS
'

function FileCopy (sourceDir,file, endDir)
	Dim endFile
	endFile = endDir + file

	Dim FSO
	Set FSO = CreateObject ("Scripting.FileSystemObject")

	If FSO.FileExists(endFile) Then
		FSO.GetFile(endFile).Attributes = 0
	End If

	FSO.CopyFile sourceDir + file,endDir,true

	Set FSO = nothing
	Set endFile = nothing
end function


function FileClear (file)
	Dim FSO
	Set FSO = CreateObject ("Scripting.FileSystemObject")

	FSO.DeleteFile file,true

	Set FSO = nothing
end function


'
' MAIN
'

' Check for DirectX9

' Get TEMP directory
Set objShell = WScript.CreateObject( "WScript.Shell" )
TEMP = objShell.ExpandEnvironmentStrings("%TEMP%")
TEMP = TEMP + "\"

' Copy the Installer files to Temp, so that we can avoid 
' executing the INF script from a path with weird characters
FileCopy ".\Files\","Install.inf",TEMP
FileCopy ".\Files\","Install.cab",TEMP

' Execute INF Script
objShell.Run "rundll32.exe advpack.dll,LaunchINFSection " + TEMP + "Install.inf,,,", 1, true

' Clear Temporary files
FileClear TEMP + "Install.inf"
FileClear TEMP + "Install.cab"