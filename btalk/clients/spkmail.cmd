/*
 * SpkMail.CMD
 *
 * This program interfaces a email program with the speech queue.  The email
 * program should be set up to call this program every time a new message
 * arrives.  When called, this program will parse out the "From:" and
 * "Subject:" lines of the message, convert them to a computer-readable format,
 * and place them on the speech queue.
 *
 * If you're using MR/2 ICE, please make flip=1 and have FLIP.EXE where
 * MR2I.EXE resides.  Haven't tested other mailers, but it doesn't hurt
 * to try.
 */
call rxfuncadd 'SysFileSearch','RexxUtil','SysFileSearch'
call rxfuncadd 'RxBTSayString','btclient','RxBTSayString'

flip = 0

parse arg mailfile

if flip = 1 then 'flip -m ' mailfile

/* Parse out "From" and "Subject" lines */
call SysFileSearch 'From: ', mailfile, fromfile
call SysFileSearch 'Subject: ', mailfile, subjectfile
parse var fromfile.1 'From: ' from
parse var subjectfile.1 'Subject: ' subject

/* note: seems RSynth takes strings in [ ] as phonemes */

from = translate(from,'','"[]') /* remove dreaded quotes and [ ] */

/* Convert subject to lower case so Rsynth doesn't start _spelling_ the
   subject if it's upper case. */

subject = Translate(subject, XRange('a', 'z'), XRange('A', 'Z'))
subject = translate(subject,'','[]')  /* characters to be 'stripped' */

/* Convert to "From" and "Subject" lines readable format */
badchar=1
do until badchar=0
	badchar=0
	charpos=lastpos('.', from)
	if charpos>0 then do
		from = overlay(' ', from, charpos)
		from = insert('dot ', from, charpos)
		badchar = 1
	end
end

/* Keeps the from name without address if possible */
charpos = lastpos('<', from) 
if charpos > 0 then
   from = delstr(from,charpos)
else do
   charpos = lastpos('(', from)
   if charpos > 0 then
      from = delstr(from,1,charpos)
   end

/* Re: -> 'reply of' */
if substr(subject,1,3) = 're:' then do
   subject = delstr(subject,1,3)
   subject = insert('reply of:', subject)
end

/* Fwd: -> 'forward of' */
fwd = pos('fwd:',subject)
if fwd > 0 then do
   subject = delstr(subject,fwd,4)
   subject = insert('forward of:', subject)
end

/* (fwd) -> 'forward of' */
fwd = pos('(fwd)',subject)
if fwd > 0 then do
   subject = delstr(subject,fwd,4)
   subject = insert('forward of:', subject)
end

/* Finds high priority messages */
highmsg = ''
call SysFileSearch 'priority: high', mailfile, dump
if dump.0 <> 0 then highmsg = 'high priority '

/* Fills missing entries */
if from='' then 
	from='someone with no address'
if subject='' then
	subject='blank'

/* Speak */
call RxBTSayString 'You have received' highmsg'e-mail from 'from'.  The subject is 'subject'.',0,0,0
