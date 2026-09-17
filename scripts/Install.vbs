' KernelKommando
' KexTools Installer Launcher
' We need to do it this way to work around all of the 
' Windows INF quirks...

'
' GLOBALS
'
Set objShell = CreateObject("WScript.Shell")
Set objFS = CreateObject("Scripting.FileSystemObject")

'
' FUNCTIONS
'

function FileCopy (sourceDir,file, endDir)

	endFile = endDir + file
	If objFS.FileExists(endFile) Then
		objFS.GetFile(endFile).Attributes = 0
	End If
	objFS.CopyFile sourceDir + file,endDir,true

end function


function FileClear (file)
	objFS.DeleteFile file,true
end function


'
' MAIN
'
title = "Unofficial SoftGPU's WineD3D Install Script"

' Check for DirectX9

SYSTEM = objShell.ExpandEnvironmentStrings("%WINDIR%")
SYSTEM = SYSTEM + "\SYSTEM32\"
If (objFS.FileExists(SYSTEM + "d3d9.dll")) Then
	' Get TEMP directory
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
Else
	dx9 = Msgbox("SoftGPU requires DirectX9, do you want to install it now?",vbQuestion+vbOkCancel,title)
	If (dx9 = 1) Then
		objShell.Run ".\Files\dx9\dxsetup.exe /silent", 1, true
		dx9 = Msgbox("DirectX9 installed. System will reboot now.",vbInformation+vbOk,title)
	Else
		dx9 = Msgbox("SoftGPU installation was cancelled",vbInformation,title)
	End If
End If

