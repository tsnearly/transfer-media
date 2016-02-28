#!/bin/bash


(
#mmTempScratch=$(mktemp -d -t tmp)
mmDirSource="/Volumes/My Book/TV Shows"
mmDirDestination="/Volumes/Media/TV Shows"
mmListFile=$(mktemp -t $(basename $0)-list-$$)
mmLogFile="/Users/tiger/Library/Logs/TransferMediaFiles.log"
mmErrorFile="/Users/tiger/Library/Logs/TransferMediaFiles.Error.log"
mmVerbose=1


function DebugPrint {
	if [ "$mmVerbose" != "" ];
	then
		echo "[$(date +'%Y-%m-%d %r')]  ${1/<NL>/$'\n'}"
	fi
}

function DoError {
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	CleanUp 1
}

function CleanUp {
	RunCommand "rm -rf $mmListFile"
	DebugPrint "Operation completed in $(($(date +%s) - ${startDate})) sec<NL>"
	exit $1
}

function Init {
	exec 1>>$mmLogFile 2>>$mmErrorFile
	startDate=$(date +%s)
	#RunCommand "printenv"
	DebugPrint "Transfer media files started"
}

function MoveToTrash {
	RunCommand "osascript -e \"tell application \\\"Finder\\\" to move the POSIX file \\\"$1\\\" to trash\""
}

function RunCommand {
	#DebugPrint "Running command: '$1'"
	local mmOutput=`eval $1 2>&1`
	#DebugPrint "---Command Output:  $mmOutput"
}

function RunCommandAsRoot {
	RunCommand "sudo $1"
}

function DeleteTempFiles {
	if [ -e "$mmTempFile" ];
	then
		DebugPrint "Deleted: -> $mmTempFile"
		RunCommand "rm -f \"$mmTempFile\""
	fi
}

function FindMediaFiles {
	local listPrograms=(  
			"Agent Carter" 
			"Blue Bloods" 
			"Bones" 
			"Castle (2009)"
			"Covert Affairs"
			"Criminal Minds"
			"Crossbones"
			"CSI NY"
			"CSI"
			"Duck Dynasty"
			"Elementary"
			"Happy Days"
			"Hawaii Five-0.2010"
			"hawaii five-0"
			"Intelligence (2014)"
			"Judge Judy"
			"Judge Mathis"
			"Legends"
			"Major Crimes"
			"Marvels Agents of S H I E L D"
			"Motive"
			"Murder in the First"
			"NCIS"
			"The Night Shift"
			"Perception"
			"Person of Interest"
			"Psych "
			"Rizzoli "
			"Royal Pains"
			"Scandal"
			"Sense8"
			"Supergirl"
			"Taxi Brooklyn"
			"The Blacklist"
			"The Last Ship"
			"The Mentalist"
			"The Night Shift"
			"The People"
			"Unforgettable" 
			"White Collar" 
		)

	for ((i = 0; i < ${#listPrograms[@]}; i++))
	do
	    cmdFind+=" -name '*${listPrograms[$i]}*' -o"
	    #RunCommand "find -E \"$mmDirSource\" -name '*${listPrograms[$i]}*.mp4' >> \"$mmListFile\""
	done
	cmdFind="find -E \"$mmDirSource\" -type f \(${cmdFind%-o}\) >> \"$mmListFile\""
	#DebugPrint "Command: $cmdFind"
	RunCommand "$cmdFind"
}

function MoveMediaFiles {
	if [ -s "$mmListFile" ]
	then
		if [ ! -d "/Volumes/Media" ]
		then
			mkdir "/Volumes/Media"
			DebugPrint "Mounting network share"
			RunCommand "mount -o automounted -t smbfs //martha:7811@marthas-pc/Media /Volumes/Media"
		fi
		while read -r line
		do
			#DebugPrint "Directory: `dirname \"$line\"`"
			#DebugPrint "Base Name: `basename \"$line\"`"
			local newFileName="$mmDirDestination`echo $line | sed -e \"s%$mmDirSource%%\"`"
			#DebugPrint "New Name: $newFileName"
			local newFilePath="`dirname \"$newFileName\"`"
			#DebugPrint "New Path: $newFilePath"
			if [ ! -d "$newFilePath" ]
			then
				DebugPrint "Making new folder: $newFilePath"
				mkdir -p "$newFilePath"
			fi
			
			RunCommand "mv \"$line\" \"$newFileName\""
			DebugPrint "Transferred: -> $line"
		done < "$mmListFile"
		RunCommand "umount /Volumes/Media"
		DebugPrint "Network share unmounted"
	else
		DebugPrint "No match files were found"
	fi
#   http://mywiki.wooledge.org/UsingFind
}

trap CleanUp SIGHUP SIGINT SIGTERM

	Init
	#DeleteTempFiles
	FindMediaFiles
	MoveMediaFiles
	#DeleteTempFiles
	CleanUp

exit
)