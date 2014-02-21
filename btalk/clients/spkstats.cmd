/*
 * SpkStats.CMD
 *
 * Uses UPTIME.EXE to speak various statistics.
 *
 */

call rxfuncadd 'RxBTSayString','btclient','RxBTSayString'

'@echo off'
'uptime | rxqueue'

if queued() > 0 then do
   stats = linein('QUEUE:')
   parse var stats time  'up' dys 'days,' hrs':'mns':'scs', load:' processes 'processes,' threads 'threads.'
   call RxBTSayString 'I have been running for 'dys' days, 'hrs' hours, and 'mns' minutes. I am controlling 'processes' processes and 'threads' threads.',0,0,0
end
