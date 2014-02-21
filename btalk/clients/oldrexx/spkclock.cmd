/* Speaking Clock - part of the BackTalk project - not even close to realtime */

lapmins = 15               /* Defines the lap between time speech in       */
                           /* minutes, decimal allowed.                    */

hourstart = "yes"          /* Announces times based on the hour start,     */
                           /* regardless of the actual program start time. */

timeType = "civil"         /* Controls how the time is announced.

   Examples:
   - offset:
       "It is twelve o'clock" (12:00am or 12:00pm)
       "It is quarter to five" (4:55pm or 4:55am)
       "It is half past five" (5:30pm or 5:30am)
       "It is quarter past three" (3:15pm or 3:15am)
   - civil:
       "It is twelve fourty five PM" (12:45pm)
       "It is twelve PM" (12:00pm)
   - international:
       "It is twelve hundred hours thirty five minutes and 15 seconds" (12:35:15)
       "It is twenty three hundred hours" (23:00:00)   */

/* Loading backtalk libraries */

call rxfuncadd 'SysSleep','RexxUtil','SysSleep'
call rxfuncadd 'RxBTSayString','btclient','RxBTSayString'

/* Give some visual information */

say 'Started on' date() 'at' time('C')
say 'Running in' timeType 'mode.'
say 'Intervals between time announcements will be' lapmins 'minutes.'

if hourstart = 'yes' then do
   lapsecs = lapmins - ( time('M') // lapmins )
   say 'First Interval will be' lapsecs 'minutes.'
   lapsecs = trunc(lapsecs*60)
end
else
   lapsecs = trunc(lapmins*60)

do forever
    Parse value time() with hours ':' mins ':' secs

    if hours > 11 then ampm = "P M"
    else ampm = "AY M"
    if timeType <> "international" then do
        if hours > 12 then hours = hours - 12
        else if hours = 0 then hours = 12 /* 0 AM should be 12 AM... */
        if timeType = "civil" then do
            if mins = 0 then mins = ""
            else if mins < 10 then mins = "O" mins
            call RxBTSayString 'It is' hours mins ampm,0,0,0
        end
        else if timeType = "offset" then do
            ampm = ""
            if mins = 0 then do
                mins = ""
                ampm = "O Clock"
            end
            else if mins = 15 then mins = "quarter past"
            else if mins = 30 then mins = "half past"
            else if mins = 45 then do
                mins = "quarter too"
                hours = hours + 1
            end
            else if mins > 30 then do
                mins = (60 - mins) "minutes too"
                hours = hours + 1
            end
            else mins = mins "minutes past"
            call RxBTSayString 'It is' mins hours ampm,0,0,0
        end
    end
    else do
        hours = hours "hundred hours"
        if mins > 0 then mins = mins "minutes"
        else mins = ""
        if secs > 0 then secs = "and" secs "seconds"
        else secs = ""
        call RxBTSayString 'It is' hours mins secs,0,0,0
    end
    
    rc=sysSleep(lapsecs)            /* Waits some time before speaking again. */
    lapsecs = trunc(lapmins*60)     /* Time until the next announcement */
end
