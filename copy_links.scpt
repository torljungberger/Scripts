-- Get the frontmost app
tell application "System Events"
	set frontApp to name of first application process whose frontmost is true
end tell

if frontApp is "Mail" then
	-- === Handle Mail ===
	tell application "Mail"
		set _sel to get selection
		set _links to {}
		repeat with _msg in _sel
			set _subject to subject of _msg
			set _sender to sender of _msg
			set _dateSent to date sent of _msg
			set _messageID to message id of _msg
			set _messageURL to "message://%3c" & _messageID & "%3e"
			
			-- Format date
			set _formattedDateTime to my formatDateTime(_dateSent)
			
			-- Escape markdown chars
			set _subject to my escapeMarkdown(_subject)
			set _sender to my escapeMarkdown(_sender)
			
			set _title to _subject & " — " & _sender & " (" & _formattedDateTime & ")"
			set end of _links to "[" & _title & "](" & _messageURL & ")"
		end repeat
		
		set AppleScript's text item delimiters to return
		set the clipboard to (_links as string)
	end tell
	
else if frontApp is "Skim" then
	-- === Handle Skim ===
	tell application "Skim"
		try
			set _doc to front document
			set _filePath to path of _doc
			set _posixPath to POSIX path of _filePath
			set _encodedPath to my encodeForURL(_posixPath)
			set _markdownLink to "[Full Text PDF](file://" & _encodedPath & ")"
			set the clipboard to _markdownLink
		on error
			display dialog "Could not get PDF path from Skim." buttons {"OK"} default button 1
		end try
	end tell
	
else
	display dialog "This script only works in Mail or Skim." buttons {"OK"} default button 1
end if

-- === Shared Utility Functions ===

-- Escape markdown chars
on escapeMarkdown(theText)
	set theText to my replaceText("[", "\\[", theText)
	set theText to my replaceText("]", "\\]", theText)
	set theText to my replaceText("(", "\\(", theText)
	set theText to my replaceText(")", "\\)", theText)
	return theText
end escapeMarkdown

-- Replace text utility
on replaceText(find, replace, inputText)
	set AppleScript's text item delimiters to find
	set inputText to text items of inputText
	set AppleScript's text item delimiters to replace
	set inputText to inputText as string
	set AppleScript's text item delimiters to ""
	return inputText
end replaceText

-- Format date as YYYY-MM-DD HH:MM
on formatDateTime(theDate)
	set y to year of theDate as string
	set m to text -2 thru -1 of ("0" & (month of theDate as integer))
	set d to text -2 thru -1 of ("0" & day of theDate)
	set h to text -2 thru -1 of ("0" & hours of theDate)
	set min to text -2 thru -1 of ("0" & minutes of theDate)
	return y & "-" & m & "-" & d & " " & h & ":" & min
end formatDateTime

-- Encode for file:// URL
on encodeForURL(inputPath)
	set theText to inputPath
	set theText to my replaceText(" ", "%20", theText)
	set theText to my replaceText("'", "%27", theText)
	set theText to my replaceText("(", "%28", theText)
	set theText to my replaceText(")", "%29", theText)
	set theText to my replaceText("#", "%23", theText)
	return theText
end encodeForURL
