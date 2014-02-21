/* Speaking Timer - part of the BackTalk project - no it's not realtime  */

/* Default values */

timermins = 60      /* countdown time, minutes  */
lap = 300           /* lap between spoken time left, seconds */
message = " "       /* message pronounced after the time left */

urgminsleft = 20    /* Falls in urgent mode after urgminleft time, minutes */
urglap = 180        /* Urgent mode lap, seconds  */
urgmsg = " "        /* Urgent mode message  */

alertmsg = " "      /* Alert message when timer has stopped */

/* Loading command line */

parse arg cmdline

/* Help screen */

parmpos = pos('-?',cmdline)
if parmpos > 0 then do
   say 'Speaking Timer - Part of the BackTalk project'
   say
   say '-t1  countdown time (minutes)'
   say '-l1  laps time (seconds)'
   say '-m1  message'
   say
   say '-t2  time remaining to switch in urgent mode (minutes)'
   say '-l2  laps time in urgent mode (seconds)'
   say '-m2  message in urgent mode'
   say
   say '-m3  alert message when timer has stopped'
   say
   say '-?   Help screen'
   say
   say 'ie.: c:\> spktimer -t1 45 -t2 15 -m1 for your dentist rendezvous -m2 for'
   say '     your VERY VERY important dentist rendezvous -l1 300 -l2 120 -m3 Your'
   say '     dentist rendezvous!!'
   exit
end

/* Loading crap */

call rxfuncadd 'SysSleep','RexxUtil','SysSleep'
call rxfuncadd 'RxBTSayString','btclient','RxBTSayString'

/* Command line mangler */

parm = getparm('-t1')
if parm <> '' then timermins = parm

parm = getparm('-l1')
if parm <> '' then lap = parm

parm = getparm('-m1')
if parm <> '' then message = parm

parm = getparm('-t2')
if parm <> '' then urgminsleft = parm

parm = getparm('-l2')
if parm <> '' then urglap = parm

parm = getparm('-m2')
if parm <> '' then urgmsg = parm

parm = getparm('-m3')
if parm <> '' then alertmsg = parm


timersecs = 60*timermins      /* Converts minutes into seconds.  Specify  */
urgsecsleft = 60*urgminsleft  /* seconds here instead of minutes there if */
                              /* you find that better.                    */

/* Set some abnormalities */

if lap > timersecs then lap = timersecs
if urgsecsleft > timersecs then urgsecsleft = 0
if urglap > urgsecsleft then urglap = urgsecsleft
if urglap > lap then urglap = lap

/* Give some visual information */

say 'countdown time:' timersecs/60 'minutes.'
say 'laps time:' lap 'seconds.'
say 'message: 'message
say
say 'fall in urgent mode at 'urgsecsleft/60 'minutes left.'
say 'laps time in urgent mode:' urglap 'seconds.'
say 'urgent message:' urgmsg
say
say 'alert message:' alertmsg

call RxBTSayString 'Starting a' timersecs/60 'minute countdown' message,0,0,0
rc = time('R')
                                               /* This part makes the countdown until it's in urgent mode. */
do while countsecs > urgsecsleft               /* A chrono is started, and then the timer value is substracted */
   call syssleep trunc(lap)                    /* from it and then valuated in minutes and secs, then spoken. */
   parse value time('E') with countsecs '.'    /* If not enough time is left to complete another loop, because */
   countsecs = timersecs - countsecs           /* of the syssleep, another loop is called, and checks each second */
   secsleft = trunc(countsecs)                 /* which should be enough, and REXX ain't that precise anyways  */
   minsleft = secsleft % 60
   secsleft = secsleft // 60
   call RxBTSayString 'There is' minsleft 'minutes and' secsleft 'seconds left' message,0,0,0
   if countsecs <= lap then do while countsecs > urgsecsleft
      call syssleep 1
      parse value time('E') with countsecs '.'
      countsecs = timersecs - countsecs
   end
end

do while countsecs > 0         /* Same as above, but uses urgent mode values */
   call syssleep trunc(urglap)
   parse value time('E') with countsecs '.'
   countsecs = timersecs - countsecs
   secsleft = trunc(countsecs)
   minsleft = secsleft % 60
   secsleft = secsleft // 60
   call RxBTSayString 'There is only' minsleft 'minutes and' secsleft 'seconds left' urgmsg,0,0,0
   if countsecs <= urglap then do while countsecs > 0
      call syssleep 1
      parse value time('E') with countsecs '.'
      countsecs = timersecs - countsecs
   end
end

call RxBTSayString alertmsg,0,0,0

exit

/* Grabs the parameters of a command line parameter given in 'cmdline'  */
/* and returns the findings if any.                                     */

getparm: procedure expose cmdline
   parse arg parmtxt
   parmpos = pos(parmtxt,cmdline) + length(parmtxt)
   text = ''
   if parmpos > length(parmtxt) then
      do until length(cmdline) = parmpos
         parmpos = parmpos + 1
         tmp = substr(cmdline,parmpos,1)
         if tmp = '-' then return strip(text)
         text = text||tmp
      end
return strip(text)
