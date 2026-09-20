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

silentMode = 0
disableDialogs = 0
postResetMode=0

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

function RequestReboot
	' This makes use fo the old SETUPAPI.DLL way of handling INFs to force a reboot
	' Basically you request the installation of an empty section in a INF file
	' With the flags set to 1="Reboot the computer in all cases."
	' This has the issue of trigering RunOnce before a reboot is performed and thus
	' you have to rely the on Run registry instead, requiring to remove the entries
	' manually once it completed execution. 
	If (silentMode = 0) Then
		Run "rundll32.exe setupapi.dll,InstallHinfSection Reboot 1 " + currentDir + "\Files\Install.inf"	 
	End If
end function

function AddToStartup (caption, program)
	objShell.RegWrite "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" + caption, program,"REG_SZ"
end function

function RemoveFromStartup (caption)
	objShell.RegDelete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\" + caption
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
		silentMode = 1
		disableDialogs = 1
	End If
	If (WScript.Arguments(0) = "/2nd_stage_dx9") Then
		postResetMode = 1
		disableDialogs = 1
	End If
End If

' Check for the unistall INF script
If (objFS.FileExists(SYSDIR + "uninwd3d.inf")) Then

	proceedInstall = vbYes
	If (disableDialogs = 0) Then
		proceedInstall = Msgbox("Do you wish to update/reinstall SoftGPU's WineD3D Software Renderer?",vbQuestion+vbYesNo,title) 
	End If
	If (proceedInstall = vbNo) Then
		WScript.Quit
	End If
	
	reinstallScript = "rundll32.exe advpack.dll,LaunchINFSection " + chr(34) + SYSDIR + "uninwd3d.inf" + chr(34) + ",,,"
	Run reinstallScript

Else
	If (disableDialogs = 0) Then
		proceedInstall = Msgbox("Do you wish to install SoftGPU's WineD3D Software Renderer?",vbQuestion+vbYesNo,title) 
		If (proceedInstall = vbNo) Then
			WScript.Quit
		End If
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

	RemoveFromStartup "SoftGPU Install"

	If (postResetMode = 1) Then
		disableDialogs = 0
	End If

Else
	If (silentMode = 0) Then
		dx9 = Msgbox("SoftGPU requires DirectX9, do you want to install it now?",vbQuestion+vbOkCancel,title)
	Else
		dx9 = vbOk
	End If

	If (dx9 = vbOk) Then

		directXsetup = chr(34) + currentDir + "\Files\dx9\dxsetup.exe" + chr(34) + " /silent"
		Run directXsetup

		commandAfterLogin = "wscript.exe " + chr(34) + thisScript + chr(34)
		if (silentMode = 1) Then
			commandAfterLogin = commandAfterLogin + " /silent"
		Else 
			commandAfterLogin = commandAfterLogin + " /2nd_stage_dx9"
		End If
		AddToStartup "SoftGPU Install", commandAfterLogin

		Say "DirectX9 installed. System will reboot now in order to complete the SoftGPU install. Press OK to reboot now.",vbInformation+vbOkOnly
		RequestReboot
		WScript.Quit

	Else
		Say "SoftGPU was not installed",vbOkOnly
	End If
End If

Say "Installation completed.", vbInformation+vbOkOnly


