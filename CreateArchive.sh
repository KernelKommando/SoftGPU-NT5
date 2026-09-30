#!/bin/bash

#
# GLOBALS
#

filename=SoftGPU_XP32-W2K
isoVolume=SOFTGPU_NT5
internalVersion=v1
date=_$(date +%Y-%m-%d_%H-%M)
extzip=.zip
extiso=.iso
separator=_

#
# FUNCTIONS
#

# $1 = filename
# $2 = sha256 checksum
__exit_on_download_error () {
	echo "Failed to download "$1", retry again"
	echo "Or try to find the original file and place it in the originalFiles directory"
	echo "SHA256: $2"
	exit 1
}

# $1 = link
# $2 = filename
# $3 = sha256 checksum
__exit_on_download_error() {
	echo "Download started"
	curl "$1" -o "$2"
	if [ ! -f "$2" ]; then 
		__exit_on_download_error "$2" "$3"
	fi

	if echo "$3 $2" | sha256sum -c --status -; then
		echo "Download complete, file verified"		
		echo "5 second sleep..."
		sleep 5
		echo " "
	else
		__exit_on_download_error "$2" "$3"
	fi 
}

# $1 = link
# $2 = filename
# $3 = sha256 checksum
get_file() {

	if [ -f "$2" ]; then
		if echo "$3 $2" | sha256sum -c --status -; then
			echo "File $2 is ready"
		else
			echo "File $2 does not match or is corrupt. Retrying..."
			__exit_on_download_error "$1" "$2" "$3"
		fi
	else
		echo  "Ready to download $2"
		__exit_on_download_error "$1" "$2" "$3"
	fi
}

delete_dir() {
	rm -rf "$1" >/dev/null 2>/dev/null
}

delete_file() {
	rm "$1" >/dev/null 2>/dev/null
}

create_dir() {
	mkdir "$1" >/dev/null 2>/dev/null
}

#
# MAIN
#

echo "Checking all dependencies..."
for dependency in sha1sum sha256sum sha512sum curl 7za unix2dos gcab
do
	if command -v $dependency >/dev/null 2>/dev/null; then
		echo "$dependency is present"
	else
		echo ""
		echo "$dependency is missing."
		echo "Make sure to install '$dependency' from you package manager."
		exit 1
	fi
done
echo "Done."

echo " " 
echo "Preparing directories and files for output..."
delete_dir ./output

	create_dir output
	create_dir output/Files
	create_dir output/Files/dx9
	create_dir originalFiles
	create_dir originalFiles/cabfiles

	cp ./scripts/Install.inf ./output/Files
	cp ./scripts/Install.vbs ./output
	cp ./scripts/uninwd3d.inf ./originalFiles/cabfiles
	cp ./scripts/autorun.inf ./output

echo "Done."

echo " "
echo "Downloading binaries..."
cd originalFiles

	# JHRobotics' VMDisp9x
	# Wayback Machine mirror of https://github.com/JHRobotics/vmdisp9x/releases/download/v1.2025.0.119/vmdisp9x-1.2025.0.119b-driver-2d.zip
	get_file \
	"https://web.archive.org/web/20260930034929if_/https://release-assets.githubusercontent.com/github-production-release-asset/625937216/62d09434-1a27-4389-ab22-bd31cf22ed17?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-30T04%3A36%3A04Z&rscd=attachment%3B+filename%3Dvmdisp9x-1.2025.0.119b-driver-2d.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-30T03%3A35%3A21Z&ske=2026-09-30T04%3A36%3A04Z&sks=b&skv=2018-11-09&sig=vDteA39LXE1OCh9U6UqX68Of3YHI8Oo%2Baw0JrIKBdus%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MDc0MDQ2OSwibmJmIjoxNzkwNzQwMTY5LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.L_A8cCOchKAk_gd6VNSW9K2KA2u0gPG7SqymqjwCJLc&response-content-disposition=attachment%3B%20filename%3Dvmdisp9x-1.2025.0.119b-driver-2d.zip&response-content-type=application%2Foctet-stream"\
	vmdisp9x-1.2025.0.119b-driver-2d.zip \
	e0d698a6089347a6a619ed439c092f247392fbafac6b342f4651c1380911fb23\

	# JHRobotics' WineD3D
	# Wayback Machine mirror of https://github.com/JHRobotics/wine9x/releases/download/v1.7.55.45/wine9x-1.7.55.45-sse3.zip
	get_file \
	"https://web.archive.org/web/20260916154542if_/https://release-assets.githubusercontent.com/github-production-release-asset/625943023/997f8b5d-f366-43d5-abfd-74c1d35a5d25?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-16T16%3A29%3A52Z&rscd=attachment%3B+filename%3Dwine9x-1.7.55.45-sse3.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-16T15%3A29%3A43Z&ske=2026-09-16T16%3A29%3A52Z&sks=b&skv=2018-11-09&sig=3akgSP7%2BVcqvZJY%2B%2BsTr2u2bGtRnRnJ0f17oC%2F67gSY%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4OTU3Mzg0MiwibmJmIjoxNzg5NTczNTQyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.AzMP4E8Bwun_9MqwLcp0jME6TXZ8ovzPnBsRtf6TCtk&response-content-disposition=attachment%3B%20filename%3Dwine9x-1.7.55.45-sse3.zip&response-content-type=application%2Foctet-stream" \
	wine9x-1.7.55.45-sse3.zip \
	8d95cfb2666c798295e3715f3fe24e9837083c3832ced6f92b752016ceb78dcb \ 

	# JHRobotics' Mesa9x
	# Wayback Machine mirror of https://github.com/JHRobotics/mesa9x/releases/download/v23.1.9.138/mesa9x-23.1.9.138-opengl32-win98-llvmpipe.zip
	get_file \
	"https://web.archive.org/web/20260926153801if_/https://release-assets.githubusercontent.com/github-production-release-asset/625939931/1855aff6-8ca5-4986-b3ca-5f47292f48db?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-26T16%3A16%3A03Z&rscd=attachment%3B+filename%3Dmesa9x-23.1.9.138-opengl32-win98-llvmpipe.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-26T15%3A15%3A09Z&ske=2026-09-26T16%3A16%3A03Z&sks=b&skv=2018-11-09&sig=R8i0a%2BeO3kG9pf%2B9EUDMDqk4Zb8Od%2BkctkJsTCSRIEs%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc5MDQzODg4MCwibmJmIjoxNzkwNDM3MDgwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.JpbH-4JFr4OsteUAjIuYfAsI25LNv1H0SZ2Ub0wJ-bc&response-content-disposition=attachment%3B%20filename%3Dmesa9x-23.1.9.138-opengl32-win98-llvmpipe.zip&response-content-type=application%2Foctet-stream" \
	mesa9x-23.1.9.138-opengl32-win98-llvmpipe.zip \
	75c6f060ba3a0995ba30dd3a7b863a7445a3542c9cc604cbf8b6af6dc04dd4c1 \

	# Microsoft DirectX9 February 2010 Installer
	get_file \
	"https://web.archive.org/web/20120504030141if_/http://download.microsoft.com/download/E/E/1/EE17FF74-6C45-4575-9CF4-7FC2597ACD18/directx_feb2010_redist.exe" \
	directx_feb2010_redist.exe \
	f6d191e89a963d7cca34f169d30f49eab99c1ed3bb92da73ec43617caaa1e93f \

echo "Done."

echo " "
echo "Obtaining required files building CAB file..."

	7za e -y mesa9x-23.1.9.138-opengl32-win98-llvmpipe.zip -o./cabfiles -i@../scripts/files_mesa3d.txt
	7za e -y wine9x-1.7.55.45-sse3.zip -o./cabfiles -i@../scripts/files_wined3d.txt
	7za e -y vmdisp9x-1.2025.0.119b-driver-2d.zip -o./cabfiles -i@../scripts/files_vmdisp9x.txt
	7za e -y directx_feb2010_redist.exe -o../output/Files/dx9 -i@../scripts/files_dx9Installer.txt

	cd cabfiles
	sha1sum *.dll > 0_checksums.txt
	sha256sum *.dll >> 0_checksums.txt
	sha512sum *.dll >> 0_checksums.txt
	unix2dos 0_checksums.txt
	gcab -c ../../output/Files/install.cab *.*
	cd ..
	cd ..

echo "Done."

echo " "
echo "Creating archives for release..."
	echo $filename$release$date$extiso
	cd output
	7za a ../$filename$release$date$extzip *
	cd ..
	mkisofs -input-charset "cp437" -iso-level 1 -joliet -rational-rock -V $isoVolume -output ./output/$filename$release$date$extiso ./output
	mv ./$filename$release$date$extzip ./output
echo "Done."

echo " "
echo "Completed, check the output directory."


