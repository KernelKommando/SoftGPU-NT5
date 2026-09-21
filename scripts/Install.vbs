' KernelKommando
' KexTools Installer Launcher
' We need to do it this way to work around all of the 
' Windows INF quirks...

'
' GLOBALS
'
On Error Resume Next

title = "Unofficial SoftGPU's WineD3D Install Script"
Set objShell = CreateObject("WScript.Shell")
Set objFS = CreateObject("Scripting.FileSystemObject")
thisScript = WScript.ScriptFullName
currentDir = objFS.GetParentFolderName(thisScript)
WINDIR = objShell.ExpandEnvironmentStrings("%WINDIR%")
SYSDIR = WINDIR + "\SYSTEM32\"
TEMP = objShell.ExpandEnvironmentStrings("%TEMP%")
TEMP = TEMP + "\"

silentMode = False
enableDialogs = True
postResetMode = False

'
' FUNCTIONS
'

Function FileCopy (sourceDir, file, endDir)

	endFile = endDir + file
	If objFS.FileExists(endFile) Then
		objFS.GetFile(endFile).Attributes = 0
	End If
	objFS.CopyFile sourceDir + file,endDir,true

End Function

Function FileClear (file)
	objFS.DeleteFile file,true
End Function

Function Run (program)
	objShell.Run program, 1, true
End Function

Function AddToStartup (caption, program)
	objShell.RegWrite "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" + caption, program,"REG_SZ"
End Function

Function RemoveFromStartup (caption)
	objShell.RegDelete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" + caption
End Function

Function Say (message, vbType)
	If (enableDialogs) Then
		msg = Msgbox(message,vbType,title)
	End If
End Function

Function CancelAndQuit 
	Say "SoftGPU was not installed",vbInformation+vbOkOnly
	WScript.Quit
End Function

Function RebootAndQuit
	' This makes use fo the old SETUPAPI.DLL way of handling INFs to force a reboot
	' Basically you request the installation of an empty section in a INF file
	' With the flags set to 1="Reboot the computer in all cases."
	' This has the issue of trigering RunOnce before a reboot is performed and thus
	' you have to rely the on Run registry instead, requiring to remove the entries
	' manually once it completed execution. 
	If (NOT(silentMode)) Then
		Run "rundll32.exe setupapi.dll,InstallHinfSection Reboot 1 " + currentDir + "\Files\Install.inf"	 
	End If
	WScript.Quit
End Function

'
' MAIN
'
If (WScript.Arguments.Count > 0) Then
	If (WScript.Arguments(0) = "/silent") Then
		silentMode = True
		enableDialogs = False
	End If
	If (WScript.Arguments(0) = "/2nd_stage_dx9") Then
		postResetMode = True
		enableDialogs = False
	End If
End If

softGPUinstalled = objFS.FileExists(SYSDIR + "uninwd3d.inf")
If (softGPUinstalled) Then

	proceedInstall = vbYes
	If (enableDialogs) Then
		proceedInstall = Msgbox("Do you wish to update/reinstall SoftGPU's WineD3D Software Renderer?",vbQuestion+vbYesNo,title) 
	End If
	If (proceedInstall = vbNo) Then
		CancelAndQuit
	End If
	
	uninstallScript = "rundll32.exe advpack.dll,LaunchINFSection " + chr(34) + SYSDIR + "uninwd3d.inf" + chr(34) + ",,,"
	Run uninstallScript

Else
	If (enableDialogs) Then
		proceedInstall = Msgbox("Do you wish to install SoftGPU's WineD3D Software Renderer?",vbQuestion+vbYesNo,title) 
		If (proceedInstall = vbNo) Then
			CancelAndQuit
		End If
	End If
End If

directX9installed = (objFS.FileExists(SYSDIR + "d3d9.dll"))
directX9isOld = ((directX9installed) AND (NOT(objFS.FileExists(SYSDIR + "d3dx9_42.dll"))))

installDirectX9 = False
If (NOT (directX9installed)) Then

	If (enableDialogs) Then
		msg = Msgbox("SoftGPU requires DirectX9, do you want to install it now?",vbQuestion+vbOkCancel,title)
		If (msg = vbOk) Then
			installDirectX9 = True
		Else
			CancelAndQuit
		End If
	Else
		installDirectX9 = True
	End If

End If

If (directX9isOld) Then

	If (enableDialogs) Then
		msg = Msgbox("Do you want to update your current version of DirectX9?",vbQuestion+vbOkCancel,title)
		If (msg = vbOk) Then
			installDirectX9 = True
		Else
			installDirectX9 = False
		End If
	Else
		installDirectX9 = False
	End If

End If

If (installDirectX9) Then

	directXsetup = chr(34) + currentDir + "\Files\dx9\dxsetup.exe" + chr(34) + " /silent"
	Run directXsetup

	commandAfterLogin = "wscript.exe " + chr(34) + thisScript + chr(34)
	if (silentMode) Then
		commandAfterLogin = commandAfterLogin + " /silent"
	Else 
		commandAfterLogin = commandAfterLogin + " /2nd_stage_dx9"
	End If
	AddToStartup "SoftGPU Install", commandAfterLogin

	Say "DirectX9 installed. System will reboot now in order to complete the SoftGPU install. Press OK to reboot now.",vbInformation+vbOkOnly
	RebootAndQuit

End If

' Copy the Installer files to Temp, so that we can avoid 
' executing the INF script from a path with weird characters
FileCopy currentDir + "\Files\","Install.inf",TEMP 
FileCopy currentDir + "\Files\","Install.cab",TEMP

installScript = "rundll32.exe advpack.dll,LaunchINFSection " + chr(34) + TEMP + "Install.inf" + chr(34) + ",,,"
Run installScript

FileClear TEMP + "Install.inf"
FileClear TEMP + "Install.cab"

RemoveFromStartup "SoftGPU Install"

If (postResetMode) Then
	enableDialogs = True
End If

Say "Installation completed.", vbInformation+vbOkOnly


