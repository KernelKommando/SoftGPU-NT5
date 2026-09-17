' KernelKommando
' KexTools Installer Launcher
' We need to do it this way to work around all of the 
' Windows INF quirks...

'
' GLOBALS
'

title = "Unofficial SoftGPU's WineD3D Install Script"
Set objShell = CreateObject("WScript.Shell")
Set objFS = CreateObject("Scripting.FileSystemObject")
thisScript = WScript.ScriptFullName
currentDir = objFS.GetParentFolderName(thisScript)
WINDIR = objShell.ExpandEnvironmentStrings("%WINDIR%")
SYSDIR = WINDIR + "\SYSTEM32\"
TEMP = objShell.ExpandEnvironmentStrings("%TEMP%")
TEMP = TEMP + "\"
runonce = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce\"

'
' FUNCTIONS
'

function FileCopy (sourceDir, file, endDir)

	endFile = endDir + file
	If objFS.FileExists(endFile) Then
		objFS.GetFile(endFile).Attributes = 0
	End If
	objFS.CopyFile sourceDir + file,endDir,true

end function

function FileClear (file)
	objFS.DeleteFile file,true
end function

function Run (program)
	objShell.Run program, 1, true
end function

'
' MAIN
'

proceedInstall = Msgbox("Do you wish to install SoftGPU's WineD3D Software Renderer?",vbQuestion+vbYesNo,title) 
If (proceedInstall = vbNo) Then
	WScript.Quit
End If

' Check for DirectX9
If (objFS.FileExists(SYSDIR + "d3d9.dll")) Then 

	' Copy the Installer files to Temp, so that we can avoid 
	' executing the INF script from a path with weird characters
	FileCopy currentDir + "\Files\","Install.inf",TEMP 
	FileCopy currentDir + "\Files\","Install.cab",TEMP

	Run "rundll32.exe advpack.dll,LaunchINFSection " + TEMP + "Install.inf,,,"
	FileClear TEMP + "Install.inf"
	FileClear TEMP + "Install.cab"

Else
	dx9 = Msgbox("SoftGPU requires DirectX9, do you want to install it now?",vbQuestion+vbOkCancel,title)
	If (dx9 = vbOk) Then
		Run ".\Files\dx9\dxsetup.exe /silent"
		objShell.RegWrite runonce + "SoftGPU Install","wscript.exe " + chr(34) + thisScript + chr(34),"REG_SZ"
		msg = Msgbox("DirectX9 installed. System will reboot now.",vbInformation+vbOkOnly,title)
	Else
		msg = Msgbox("SoftGPU was not installed",vbOkOnly,title)
		WScript.Quit
	End If
End If

