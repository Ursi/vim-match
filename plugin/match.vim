let s:match = {
\	"(": ")",
\	"{": "}",
\	"[": "]",
\	"`": "`",
\	"'": "'",
\	'"': '"',
\	"closing": [")", "}", "]", "`", "'", '"'],
\}

let s:match.re = '^\s*' . '\(' . join(s:match.closing, '\|') . '\)'
fu! Split_line(line, pos)
	let before = strcharpart(a:line, 0, a:pos - 1)
	let after = strcharpart(a:line, a:pos - 1)
	retu [before, after]
endf

fu! Get_press()
	let old_lengths = map(copy(s:old_split), 'strchars(v:val)')
	let cur_lengths = map(copy(s:cur_split), 'strchars(v:val)')
	if old_lengths[0] < cur_lengths[0]
		retu strcharpart(s:cur_split[0], cur_lengths[0] - 1)
	elsei getline(line(".") - 1) == s:old_split[0]
		retu "enter"
	elsei cur_lengths[0] == old_lengths[0] - 1
		retu "backspace"
	el
		retu "change"
	en
endf

fu! Match_tci()
	let cur_line = getline(".")
	let cur_col = col(".")
	let s:cur_split = Split_line(cur_line, cur_col)
	let press = Get_press()
	if has_key(s:match, press) && strcharpart(s:cur_split[1], 0, 1) !~ '\w'
		let s:cur_split = [s:cur_split[0], s:match[press] . s:cur_split[1]]
		cal setline(".", join(s:cur_split, ""))
		DoMatchParen
	elsei press == "enter" && cur_line =~ s:match.re
		cal append(line(".") - 1, matchstr(cur_line, '^\s*') . "\t")
		cal cursor(line(".") - 1, col("$"))
		DoMatchParen
	en

	let s:old_split = s:cur_split
endf

fu! On_closing()
	retu count(s:match.closing, strcharpart(getline("."), col(".") - 1, 1))
endf

fu! Match_icp()
	if v:char == "\<Tab>"
		if On_closing()
			let v:char = ""
			let l = line(".")
			wh On_closing()
				cal cursor(l, col(".") + 1)
			endw
		en
	en
endf

aug match |au!
	au InsertCharPre * cal Match_icp()
	au TextChangedI * cal Match_tci()
	au InsertEnter * let s:old_split = Split_line(getline("."), col("."))
aug end
