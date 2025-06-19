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

-- Encode special characters for use in a file:// URL
on encodeForURL(inputPath)
	set theText to inputPath
	set theText to my replaceText(" ", "%20", theText)
	set theText to my replaceText("'", "%27", theText)
	set theText to my replaceText("(", "%28", theText)
	set theText to my replaceText(")", "%29", theText)
	set theText to my replaceText("#", "%23", theText)
	return theText
end encodeForURL

on replaceText(find, replace, inputText)
	set AppleScript's text item delimiters to find
	set inputText to text items of inputText
	set AppleScript's text item delimiters to replace
	set inputText to inputText as string
	set AppleScript's text item delimiters to ""
	return inputText
end replaceText
