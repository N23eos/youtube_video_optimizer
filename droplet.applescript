-- Optimize Video — macOS droplet.
-- Drag video files onto the app icon → pick a resolution → optimization runs.
-- Calls optimize.sh located in the same folder.

on run
	display dialog "Drag one or more video files onto this app's icon to optimize them for YouTube (480/720/1080p)." buttons {"OK"} default button 1 with title "Optimize Video"
end run

on open theItems
	-- path to optimize.sh (same folder as this app)
	set appPosix to POSIX path of (path to me)
	set projDir to do shell script "dirname " & quoted form of appPosix
	set optimizer to projDir & "/optimize.sh"

	-- resolution choice
	set resChoice to choose from list {"480p", "720p (recommended)", "1080p"} ¬
		default items {"720p (recommended)"} with prompt "Target resolution:" with title "Optimize Video"
	if resChoice is false then return
	set res to "720"
	if (item 1 of resChoice) starts with "480" then set res to "480"
	if (item 1 of resChoice) starts with "1080" then set res to "1080"

	set okCount to 0
	set failList to {}

	repeat with anItem in theItems
		set f to POSIX path of anItem
		try
			do shell script "export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH; " & ¬
				"/bin/bash " & quoted form of optimizer & " -r " & res & " " & quoted form of f
			set okCount to okCount + 1
		on error errMsg
			set end of failList to (do shell script "basename " & quoted form of f) & ": " & errMsg
		end try
	end repeat

	if (count of failList) is 0 then
		display notification "Files optimized: " & okCount & " (" & res & "p)" with title "Optimize Video" sound name "Glass"
	else
		set msg to "Done: " & okCount & ". Errors:" & return & (my joinList(failList, return))
		display dialog msg buttons {"OK"} default button 1 with title "Optimize Video" with icon caution
	end if
end open

on joinList(lst, sep)
	set {oldTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, sep}
	set s to lst as text
	set AppleScript's text item delimiters to oldTID
	return s
end joinList
