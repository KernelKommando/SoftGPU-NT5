#!/bin/bash

filename=Unofficial_SoftGPU_WineD3D_W2K
internalVersion=v1
date=_$(date +%Y-%m-%d_%H-%M)
extzip=.zip
separator=_

# $1 = link
# $2 = filename
# $3 = sha256 checksum
getFile() {
	
	if echo "$3 $2" | sha256sum -c --status -; then
		echo File $2 is ready
		true
	else 
		echo Ready to download $2...
		sleep 5
		curl "$1" -o "$2"
		if echo "$3 $2" | sha256sum -c --status -; then
			true
		else
			echo Failed to download "$2", retry again
			echo Or try to find the file and place it in the originalFiles directory
			echo SHA256: $3
			exit 1
		fi 
	fi
}

# Main

# Prepare originalFiles directory
mkdir originalFiles
rm originalFiles/0_checksums.txt
rm originalFiles/0_links.txt

# Get Wayback Machine mirror of https://github.com/JHRobotics/wine9x/releases/download/v1.7.55.45/wine9x-1.7.55.45-sse3.zip
getFile \
	"https://web.archive.org/web/20260916154542if_/https://release-assets.githubusercontent.com/github-production-release-asset/625943023/997f8b5d-f366-43d5-abfd-74c1d35a5d25?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-16T16%3A29%3A52Z&rscd=attachment%3B+filename%3Dwine9x-1.7.55.45-sse3.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-16T15%3A29%3A43Z&ske=2026-09-16T16%3A29%3A52Z&sks=b&skv=2018-11-09&sig=3akgSP7%2BVcqvZJY%2B%2BsTr2u2bGtRnRnJ0f17oC%2F67gSY%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4OTU3Mzg0MiwibmJmIjoxNzg5NTczNTQyLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.AzMP4E8Bwun_9MqwLcp0jME6TXZ8ovzPnBsRtf6TCtk&response-content-disposition=attachment%3B%20filename%3Dwine9x-1.7.55.45-sse3.zip&response-content-type=application%2Foctet-stream" \
	originalFiles/wine9x-1.7.55.45-sse3.zip \
	8d95cfb2666c798295e3715f3fe24e9837083c3832ced6f92b752016ceb78dcb \

# Get Wayback Machine mirror of https://github.com/JHRobotics/mesa9x/releases/download/v23.1.9.138/mesa9x-23.1.9.138-driver-win98.zip
getFile \
	"https://web.archive.org/web/20260916160010if_/https://release-assets.githubusercontent.com/github-production-release-asset/625939931/15a1f4c4-b24e-4a3f-b3fa-f4362ac5f0d4?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-09-16T16%3A58%3A54Z&rscd=attachment%3B+filename%3Dmesa9x-23.1.9.138-driver-win98.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-09-16T15%3A58%3A36Z&ske=2026-09-16T16%3A58%3A54Z&sks=b&skv=2018-11-09&sig=FBZItvsHSY0YODnVCBrp%2FCsmn4DLn63%2FtSM7B162KWg%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4OTU3NjIxMCwibmJmIjoxNzg5NTc0NDEwLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.0U8OaKJ_xgNwcH6umKeFT5Y1ROtOpS_W0OOiApxlVvk&response-content-disposition=attachment%3B%20filename%3Dmesa9x-23.1.9.138-driver-win98.zip&response-content-type=application%2Foctet-stream" \
	originalFiles/mesa9x-23.1.9.138-driver-win98.zip \
	04e138f497792266fbb8ec864a4e906523aee3768e28e16276d3abb58644d04d \

# Get 
getFile \
	"https://web.archive.org/web/20120504030141if_/http://download.microsoft.com/download/E/E/1/EE17FF74-6C45-4575-9CF4-7FC2597ACD18/directx_feb2010_redist.exe" \
	originalFiles/directx_feb2010_redist.exe \
	f6d191e89a963d7cca34f169d30f49eab99c1ed3bb92da73ec43617caaa1e93f \


# unix2dos originalFiles/*.txt


# Clear output 
rm -rf ./output
mkdir output
mkdir output/Files

# Copy scripts to output
cp -f ./scripts/Install.inf ./output/Files
cp -f ./scripts/Install.vbs ./output


echo Done.


