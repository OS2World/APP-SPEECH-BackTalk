/* SPKIRC - Speaking IRC REXX script, part of the BackTalk project.       */
/* If you already have another Outbound Command IRC REXX script installed,*/
/* place all of the following, at the exception of the last Return 'OK',  */
/* at the BEGINNING of your existing script.                              */
/* Samuel Audet <guardia@cam.org>                                         */

Parse Upper Arg Winhandle WinName OurNick Verb Parm1 Parms

Pool = 'OS2ENVIRONMENT'

/* Sets SPKIRC parameters in memory */

if (Verb = '/SPKIRC') then do
   if value('spkirc',,Pool) <> true then do
      ircrexxdisplay('You have to load SPKIRC with /LOADSPKIRC first!',winhandle)
      Return 'OK'
      end
   else do
      if (Parm1 <> '') then do
         if (Parms <> '') then do
             if translate(parms) <> 'ON' & translate(parms) <> 'OFF' then parms = 'OFF'
             rc = value('spk'Parm1,translate(Parms),Pool)
             ircrexxdisplay('SPKIRC' Parm1 'Set to: ' || Parms || '.', winhandle)
             Return 'OK'
         end
         else do
             if Value('spk'Parm1,,Pool) <> 'ON' & Value('spk'Parm1,,Pool) <> 'OFF' then rc = value('spk'Parm1,'OFF',Pool)
             IrcRexxDisplay('SPKIRC' Parm1 'Is currently: ' || Value('spk'Parm1,,Pool) || '.', winhandle)
             Return 'OK'
         end
      end
   end
end

/* Loads spkirc.cfg in memory and enables SPKIRC ON flag */

if (Verb = '/LOADSPKIRC') then do
   rc = value('spkirc',true,Pool)
   i = 0
   do until lines('spkirc.cfg') = 0
      i = i + 1
      rc = value('nickcfg.'i,linein('spkirc.cfg'),Pool)
      if pos('#',value('nickcfg.'i,,Pool)) = 1 then i = i - 1
   end
   rc = value('nickcfg.0',i,Pool)
   ircrexxdisplay('SPKIRC loaded!',winhandle)
   Return 'OK'
end

Return 'OK'
