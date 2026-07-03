-- Optimize Video — droplet для macOS.
-- Перетаскивай видеофайлы на иконку приложения → выбираешь разрешение → оптимизация.
-- Вызывает optimize.sh, лежащий в той же папке.

on run
	display dialog "Перетащи один или несколько видеофайлов на иконку этого приложения, чтобы оптимизировать их для YouTube (480/720/1080p)." buttons {"OK"} default button 1 with title "Optimize Video"
end run

on open theItems
	-- путь к optimize.sh (в той же папке, что и это приложение)
	set appPosix to POSIX path of (path to me)
	set projDir to do shell script "dirname " & quoted form of appPosix
	set optimizer to projDir & "/optimize.sh"

	-- выбор разрешения
	set resChoice to choose from list {"480p", "720p (рекомендуемое)", "1080p"} ¬
		default items {"720p (рекомендуемое)"} with prompt "Разрешение для оптимизации:" with title "Optimize Video"
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
		display notification "Оптимизировано файлов: " & okCount & " (" & res & "p)" with title "Optimize Video" sound name "Glass"
	else
		set msg to "Готово: " & okCount & ". Ошибки:" & return & (my joinList(failList, return))
		display dialog msg buttons {"OK"} default button 1 with title "Optimize Video" with icon caution
	end if
end open

on joinList(lst, sep)
	set {oldTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, sep}
	set s to lst as text
	set AppleScript's text item delimiters to oldTID
	return s
end joinList
