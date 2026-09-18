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

disableDialogs = 0

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

function RunAfterLogin (caption, program)
	objShell.RegWrite "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" + caption, program,"REG_SZ"
end function

function Say (message, vbType)
	If (disableDialogs = 0) Then
		msg = Msgbox(message,vbType,title)
	End If
end function

'
' MAIN
'
If (WScript.Arguments.Count > 0) Then
	If (WScript.Arguments(0) = "/silent") Then
		disableDialogs = 1
	End If
End If

If (disableDialogs = 0) Then
	proceedInstall = Msgbox("Do you wish to install SoftGPU's WineD3D Software Renderer?",vbQuestion+vbYesNo,title) 
	If (proceedInstall = vbNo) Then
		WScript.Quit
	End If
End If

' Check for DirectX9
If (objFS.FileExists(SYSDIR + "d3d9.dll")) Then 

	' Copy the Installer files to Temp, so that we can avoid 
	' executing the INF script from a path with weird characters
	FileCopy currentDir + "\Files\","Install.inf",TEMP 
	FileCopy currentDir + "\Files\","Install.cab",TEMP

	installScript = "rundll32.exe advpack.dll,LaunchINFSection " + chr(34) + TEMP + "Install.inf" + chr(34) + ",,,"
	Run installScript

	FileClear TEMP + "Install.inf"
	FileClear TEMP + "Install.cab"

	Say "Installation completed.", vbInformation+vbOkOnly

Else
	If (disableDialogs = 0) Then
		dx9 = Msgbox("SoftGPU requires DirectX9, do you want to install it now?",vbQuestion+vbOkCancel,title)
	Else
		dx9 = vbOk
	End If

	If (dx9 = vbOk) Then

		directXsetup = chr(34) + currentDir + "\Files\dx9\dxsetup.exe" + chr(34) + " /silent"
		Run directXsetup
		installCommandAfterLogin = "wscript.exe " + chr(34) + thisScript + chr(34)
		commandAfterLogin = commandAfterLogin + " /silent"
		RunAfterLogin "SoftGPU Install", commandAfterLogin
		Say "DirectX9 installed. System will reboot now in order to complete the SoftGPU install. Press OK to reboot now.",vbInformation+vbOkOnly
		Run "rundll32.exe setupapi.dll,InstallHinfSection Reboot 129 " + currentDir + "\Files\Install.inf"

	Else
		Say "SoftGPU was not installed",vbOkOnly
	End If
End If

