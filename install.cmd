/* BackTalk installation. You will need UNZIP.EXE in your path or current */
/* directory.  The installer will use its execution directory files, NOT  */
/* the ones from the directory you were at the prompt.                    */
/*                                        Samuel Audet <guardia@cam.org>  */

/* Load necessary RexxUtil functions */

call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs' 
call SysLoadFuncs

parse arg parm
parm = strip(parm)

/* Help screen */

if (parm = '' | pos('?',parm) > 0) then do
   say 'Usage:  INSTALL <target directory>'
   say 'ie:  install g:\backtalk'
   exit
end

/* Finding and switching execution directory */

parse source . . sourcename
sourcedir = filespec('D', sourcename)||filespec('P', sourcename)
sourcedir = left(sourcedir, length(sourcedir)-1)
call directory sourcedir

/* Remove trailing backslash */

if lastpos('\',parm) = length(parm) then parm = left(parm,length(parm) - 1)

/* Introduction */

say
Say 'BackTalk 2.0 Installer'
Say 'This Installer uses and includes freeware Info-ZIP UNZIP 5.x.'
Say 'Note: if you have a previous version of BackTalk, please remove the'
say 'program directory and the WPS Folder with the Program Objects.'
say

/* Finding UNZIP.EXE */
if search('UNZIP.EXE','PATH') = 2 then exit

/* checking directory existence */
call sysfiletree parm,file
if file.0 > 0 then do
   say 'Please remove the existing directory first.'
   exit
end

/* Queries */

Call CharOut, 'Install BackTalk in 'parm' ? '
AKey = SysGetKey( 'ECHO' )
If AKey <> 'y' & AKey <> 'Y' Then Exit

say
say
say 'A way to make BTCLIENT.DLL available to every applications is needed:'
say '1. Add' parm'\clients to LIBPATH.'
say '2. Specify a directory already in LIBPATH where to copy BTCLIENT.DLL.'
say '   For example in x:\os2\dll.'
say '3. Don''t touch anything.'
Call CharOut, 'Choice: '

AKey = SysGetKey( 'ECHO' )
say
directory = ''
addlibpath = 0

If AKey = 1 then
   addlibpath = 1
else If AKey = 2 Then do
   Call CharOut, 'Type the directory where BTCLIENT.DLL is to be copied: '
   do while lines()
      pull /* flush buffer */
   end 
   pull directory
end

say

flip = 0
Call CharOut, 'Install flip (necessary for MR/2 ICE)? '
AKey = SysGetKey( 'ECHO' )
If AKey = 'y' | AKey = 'Y' Then flip = 1

/* Making specified directory */

rc = SysMkDir(parm)
if rc > 0 then do
  say 'Failed creating' parm
  exit
end

/* Unzipping, copying, deleting files */

'unzip btalk -d 'parm
'unzip uptime -d 'parm'\Uptime'
if flip = 1 then 'unzip flip1os2 -d 'parm'\flip'
'copy readme.txt 'parm
'copy 'parm'\clients\spkstats.cmd 'parm'\uptime'

/* setting up BTCLIENT.DLL somewhere */

if directory <> '' then 'copy' parm'\clients\btclient.dll' directory

if addlibpath = 1 then do

   /* find bootdrive and modify config.sys */
   SysIni( "BOTH","FolderWorkareaRunningObjects","ALL:","Objects" )
   BootDrive = left(Objects.1,2)

   if lines(bootdrive'\CONFIG.SYS') = 0 then do
      say 'Boot drive not detect proprely.  Edit INSTALL.CMD, find '
      say '"BootDrive = left(Objects.1,2)" and replace with'
      say '"BootDrive = <your boot drive>" ex.: "BootDrive = C:"'
   end
   else do
      i = 0;
      do until file.0 = 0
         i = i + 1
         call sysfiletree bootdrive'\CONFIG.'i,file
      end
      call lineout bootdrive'\CONFIG.SYS'

      'ren' bootdrive'\CONFIG.SYS CONFIG.'i

      do while lines(bootdrive'\CONFIG.'i)
         aline = linein(bootdrive'\CONFIG.'i)
         if pos('LIBPATH=', translate(strip(aline))) = 1 then do
            if pos(translate(parm'\CLIENTS'), translate(strip(aline))) = 0 then do
               if length(aline) != lastpos(';',aline) then aline = aline';'
               aline = aline||translate(parm'\CLIENTS')
            end
         end
         call lineout bootdrive'\CONFIG.SYS',aline
      end
      call lineout bootdrive'\CONFIG.SYS'
   end
end

/* Creating WPS Objects */

say

classname='WPFolder'
title='BackTalk'
location='<WP_DESKTOP>'
setup='OBJECTID=<BACK_TALK>;'||,
      'ICONFILE='sourcedir'\backfld.ico;'||,
      'ICONNFILE=1,'sourcedir'\backfldn.ico;'
Call BldObj

classname='WPProgram'
title='BackTalk Server'
location='<BACK_TALK>'
setup='OBJECTID=<BT_SERVER>;'||,
      'EXENAME='parm'\server\btserver.exe;'||,
      'ICONFILE='sourcedir'\speech.ico;'
Call BldObj

classname='WPProgram'
title='Say Something'
location='<BACK_TALK>'
setup='OBJECTID=<SAY_STRING>;'||,
      'EXENAME='parm'\clients\spchstr.cmd;'||,
      'PARAMETERS=[Enter text to say:];'||,
      'MINIMIZED=YES;'||,
      'ICONFILE='sourcedir'\speech.ico;'
Call BldObj

classname='WPProgram'
title='Say File'
location='<BACK_TALK>'
setup='OBJECTID=<SAY_FILE>;'||,
      'EXENAME='parm'\clients\spchfile.cmd;'||,
      'MINIMIZED=YES;'||,
      'ASSOCFILTER=*.TXT;'||,
      'ICONFILE='sourcedir'\speech.ico;'
Call BldObj

classname='WPProgram'
title='Say Queued'
location='<BACK_TALK>'
setup='OBJECTID=<QUEUED_SPCH>;'||,
      'EXENAME='parm'\clients\spchnum.cmd;'||,
      'MINIMIZED=YES;'||,
      'ICONFILE='sourcedir'\speech.ico;'
Call BldObj

classname='WPProgram'
title='System Stats'
location='<BACK_TALK>'
setup='OBJECTID=<SYS_SPCH>;'||,
      'EXENAME='parm'\uptime\spkstats.cmd;'||,
      'MINIMIZED=YES;'||,
      'ICONFILE='sourcedir'\speech.ico;'
Call BldObj

classname='WPProgram'
title='Speaking Clock'
location='<BACK_TALK>'
setup='OBJECTID=<CLOCK_SPCH>;'||,
      'EXENAME='parm'\clients\spkclock.exe;'||,
      'ICONFILE='sourcedir'\speech.ico;'
Call BldObj

a = 'PARAMETERS=-t1 [countdown time (minutes):]'
b = '-l1 [laps time(seconds):] -m1 [speaking message:]'
c = '-t2 [time left to fall in urgent mode(minutes):]'
d = '-l2 [laps time in urgent mode (seconds):] -m2 [message in urgent mode:]'
e = '-m3 [alert message when timer has stopped:];'
classname='WPProgram'
title='Speaking Timer'
location='<BACK_TALK>'
setup='OBJECTID=<TIMER_SPCH>;'||,
      'EXENAME='parm'\clients\spktimer.exe;'||,
      a b c d e||,
      'CCVIEW=YES;'||,
      'ICONFILE='sourcedir'\speech.ico;'
Call BldObj
 
say 'Creating Shadow: readme.txt'
if SysCreateShadow(parm'\readme.txt','<BACK_TALK>') = 0 then
   say 'Error: Object not created.'

say 'Creating Shadow: btstart.lst'
if SysCreateShadow(parm'\server\btstart.lst','<BACK_TALK>') = 0 then
   say 'Error: Object not created.'

Exit

/* Build Object */

BldObj:
   say 'Creating Object: 'title
   result = SysCreateObject(classname, title, location, setup, 'R')
   If result > 1 Then say 'Error: Object not created. Return code='result
Return

/* Search 'filename' in 'path' and give error msg and error level */

Search:
   parse arg filename, path
   found = 0
   if SysSearchPath(path,filename) = '' then do
      say filename' not found.'
      found = 2
   end
return found
