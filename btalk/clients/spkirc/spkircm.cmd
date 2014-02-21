/* SPKIRC - Speaking IRC REXX script, part of the BackTalk project.       */
/* If you already have another Inbound Message IRC REXX script installed, */
/* place all of the following, at the exception of the last Return 'OK',  */
/* at the BEGINNING of your existing script.                              */
/* Samuel Audet <guardia@cam.org>                                         */

Pool = 'OS2ENVIRONMENT'
call RxFuncAdd 'RxBTSayString', 'btclient', 'RxBTSayString'

if value('spkirc',,Pool) = true then do

Parse Arg WinHandle OurNick':'From Cmd Dest Rest More
parse var from fromnick'!'fromip

/* Setting up cases, stripping formatting characters, etc. */

rest = Translate(rest, XRange('a', 'z'), XRange('A', 'Z'))
more = Translate(more, XRange('a', 'z'), XRange('A', 'Z'))
fromnick = Translate(fromnick, XRange('a', 'z'), XRange('A', 'Z'))
fromnick = translate(fromnick,'','[]<>|_')  
rest = translate(rest,'','|_þÉÍº[]')  /* characters to be 'stripped' */
more = translate(more,'','|_þÉÍº[]')
ournick = translate(OurNick)

text = ''

/* Check IRC messages and queueing them if configure so and if it is the */
/* right message */

select

when cmd = 'PRIVMSG' then do

   parse var rest ':'rest
   tmp  = ''

   if pos('',rest) = 1 then do
      if value('spkctcp',,Pool) = 'ON' then do
         select
            when pos('ping',rest) = 2 then
               text = FromNick 'just pinged you!'
            when pos('version',rest) = 2 then
               text = FromNick 'just checked your version!'
            when pos('userinfo',rest) = 2 then
               text = FromNick 'just checked your user information!'
            when pos('clientinfo',rest) = 2 then
               text = FromNick 'just checked your client information!'
            when pos('finger',rest) = 2 then
               text = FromNick 'just fingered you!'
            when pos('echo',rest) = 2 then
               text = FromNick 'just echoed to you:' more
            when pos('sound',rest) = 2 then
               text = FromNick 'just played you a sound!'
            when pos('source',rest) = 2 then
               text = FromNick 'just checked your client source!'
            when pos('time',rest) = 2 then
               text = FromNick 'just checked your time!'
            otherwise nop
         end /* select */
      end

      if (OurNick = translate(Dest) & value('spkdcc',,Pool) = 'ON' & pos('dcc',rest) = 2) then do
         select
            when pos('send',more) = 1 then do
               parse var more dcccmd filename gar bage filesize
               text = FromNick 'offers you' translate(filename) 'which is' trunc(filesize/1024) 'kilobytes.'
               end
            when pos('chat',more) = 1 then
               text = FromNick 'offers you a DCC Chat.'
            otherwise nop
         end /* select */
      end /* if dcc */

      if (pos('action',rest) = 2 & value('spkpubmsg',,Pool) = 'ON') then
         text = FromNick 'in' Dest delstr(more, length(more))

   end /* if  */
   else do
      select
         when OurNick = translate(Dest) then do
            if (value('spkprivmsg',,Pool) = 'ON' | value('spkmymsg',,Pool) = 'ON') then
               text = FromNick 'said to you privately:' rest more
            end
         when pos(translate(ircrexxvariable(winhandle,"$PARTIALNICK")),translate(rest)) > 0 then
            if (value('spkmymsg',,Pool) = 'ON' | value('spkpubmsg',,Pool) = 'ON') then
               text = FromNick 'in' Dest 'said to you:' more
         when pos(':',rest) > 0 then
            if value('spkpubmsg',,Pool) = 'ON' then
               text = FromNick 'in' Dest 'said to' rest more
         otherwise
            if value('spkpubmsg',,Pool) = 'ON' then
               text = FromNick 'in' Dest 'said' rest more
      end /* select */
   end /* else  */

end /* when privmsg */

when (cmd = 'TOPIC' & value('spkpubmsg',,Pool) = 'ON') then
   text = 'The topic in' Dest 'has been changed to' Rest 'by' FromNick

when (cmd = 'NOTICE' & value('spknotice',,Pool) = 'ON') then do
   select
      when OurNick = translate(Dest) then do
         if (value('spkprivmsg',,Pool) = 'ON' | value('spkmymsg',,Pool) = 'ON') then
            text = FromNick 'sent you this notice' Rest More
         end
      otherwise
         if value('spkpubmsg',,Pool) = 'ON' then
            text = FromNick 'sent this notice in 'Dest Rest More
   end
end

when (cmd = 'JOIN' & (value('spkjoin',,Pool) = 'ON' | value('spkpubmsg',,Pool) = 'ON')) then
   text = FromNick 'has joined' Dest

when (cmd = 'PART' & (value('spkleft',,Pool) = 'ON' | value('spkpubmsg',,Pool) = 'ON')) then
   text = FromNick 'has left' Dest

when (cmd = 'QUIT' & (value('spksignoff',,Pool) = 'ON' | value('spkpubmsg',,Pool) = 'ON')) then
   text = FromNick 'has signed off' Dest Rest More

when (cmd = 'NICK' & (value('spknick',,Pool) = 'ON' | value('spkpubmsg',,Pool) = 'ON')) then
   text = FromNick 'has changed nickname and is now known as' Dest

when (cmd = 'KICK' & (value('spkkick',,Pool) = 'ON' | value('spkpubmsg',,Pool) = 'ON')) then
   text = Rest 'has been kicked off' dest more' by 'fromnick

when (cmd = '303' & value('spknotify',,Pool) = 'ON') then do
   parse var rest ':'rest
   newnamelist = rest more
   oldnamelist = value('spknotifylist',,Pool)

   i = 1
   anoldname = word(oldnamelist,i)
   do while anoldname <> ''
       if pos(anoldname,newnamelist) = 0 then do
             text = 'Sign off by' anoldname 'detected'
             oldnamelist = delstr(oldnamelist, pos(anoldname,oldnamelist), length(anoldname))
          end
       i = i + 1
       anoldname = word(oldnamelist,i)
   end

   i = 1
   anewname = word(newnamelist,i)
   do while anewname <> ''
       if pos(anewname,oldnamelist) = 0 then do
          if text <> '' then text = text 'and Sign on by' anewname 'detected'
             else text = 'Sign on by' anewname 'detected'
          oldnamelist = oldnamelist anewname
          end
       i = i + 1
       anewname = word(newnamelist,i)
   end

   rc = value('spknotifylist',oldnamelist,Pool)
end

otherwise nop

end /* select */

if text <> '' then do

   /* Finding nicknames config entries in SPKIRC.CFG */

   found = 0
   do i = 1 to value('nickcfg.0',,Pool)
      parse value value('nickcfg.'i,,Pool) with scrap'='freq','speed','flutter
      if pos(Translate(strip(scrap), XRange('a', 'z'), XRange('A', 'Z')),fromnick) > 0 then do
         if freq <> '' then freq = strip(freq)
         if speed <> '' then speed = strip(speed)
         if flutter <> '' then flutter = strip(flutter)
         found = 1
         i = value('nickcfg.0',,Pool)
      end
   end

   if found = 0 then
      call RxBTSayString text,0,0,0
   else
      call RxBTSayString text,freq,speed,flutter

end /* if text */

end /* if spkirc */

Return 'OK'
