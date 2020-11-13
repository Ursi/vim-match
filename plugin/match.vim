let s:match = {
\	"(": ")",
\	"{": "}",
\	"[": "]",
\	"`": "`",
\	"'": "'",
\	'"': '"',
\}

let	s:closing = [")", "}", "]", "`", "'", '"']
"let s:match_re = '^\s*' . '\(' . join(s:closing, '\|') . '\)'

fu! Match(nr)
	let char = nr2char(a:nr)
	if char == "'" || char == '"'
		if strcharpart(getline("."), col(".") - 2, 1) =~ '\s'
			retu char . s:match[char] . "\<Left>"
		el
			retu char
		en
	el
		if strcharpart(getline("."), col(".") - 1, 1) !~ '\w'
			retu char . s:match[char] . "\<Left>"
		el
			retu char
		en
	en
endf

fu! Autoindent()
	if index(s:closing, strcharpart(getline("."), col(".") - 1, 1)) != -1
		retu "\<CR>\<CR>\<Up>\<C-T>"
	el
		retu "\<CR>"
	en
endf

fu! Match_icp()
	fu! On_closing()
		retu count(s:closing, strcharpart(getline("."), col(".") - 1, 1))
	endf

	" if v:char == "\<Tab>"
	" 	if On_closing()
	" 		let v:char = ""
	" 		let l = line(".")
	" 		wh On_closing()
	" 			cal cursor(l, col(".") + 1)
	" 		endw
	" 	en
	" en
endf

for open_char in keys(s:match)
	exe 'ino <expr> ' . open_char . ' ' . 'Match(' . char2nr(open_char) . ')'
endfo

if !exists("match_autoindent") || match_autoindent
	ino <expr> <CR> Autoindent()
en

aug match |au!
	au InsertCharPre * cal Match_icp()
aug end
