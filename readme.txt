BackTalk 2.01 - System Speech for OS/2    (c) 1996-1997 Samuel Audet
                                          (c) 1996      Jim Little

Revised and modified BackTalk project by Samuel Audet <guardia@cam.org>  

Original copy and idea goes to Jim Little <jiml@teleport.com> and his Power
User section available at OS/2 E-Zine!.

Based on RSynth 2.0 (C) Nick Ing-Simmons <nik@tiuk.ti.com> and on the port
for OS/2 by Derek J Decker <djd@cris.com>.

THIS IS A FREEWARE UTILITY!!  Please send an e-mail if are using this
program, thank you!  If you can spare some $MONEY$ for a pre-university
student, it would be very much appreciated.  See Contacting the Author
section.


Table of contents
~~~~~~~~~~~~~~~~~
   I. Installation
  II. CMU Pronunciation Dictionary
 III. BTSERVER.EXE BackTalk Server
  IV. SPKMAIL.CMD  Speaking Mail
   V. SPKCLOCK.EXE Speaking Clock and SPKTIMER.EXE Speaking Timer
  VI. SPKIRC.CMD   Speaking IRC
 VII. Implementing BackTalk speech into REXX
VIII. For programmers
  IX. Legal Stuff
   X. Contacting the Author
  XI. Acknowledgements

You can make a search of the title as they all have the exact same
characters in the text below.


I. Installation
~~~~~~~~~~~~~~~
Run INSTALL.CMD.  It will ask you a couple of questions:
   - About MR/2 ICE support (this is also needed for any other mailers that
     don't convert Unix type text file to OS/2-DOS text files), and
   - About including backtalk directory in the libpath, or placing
     BTCLIENT.DLL somewhere else in your libpath.

IMPORTANT: BackTalk will sound like an illiterate without a dictionary, see
below to install one.

Be sure to have EMX runtime libraries installed. You can get these at
ftp://hobbes.nmsu.edu/pub/os2/dev/emx/v0.9c/emxrt.zip

A folder will be created, where you can find all the objects needed to
control the scripts that came with this packages as well as the main
BackTalk Server.  However, SPKMAIL.CMD and SPKIRC.CMD will have to be
manually installed, please read below.

The installer includes Info-ZIP UNZIP 5.12 EXE.  It is freeware and
available at ftp://hobbes.nmsu.edu//pub/os2/util/archiver/unz531x2.exe

To uninstall, you will have to delete the created directory, delete the
icon folder and remove <directory>\clients from your LIBPATH in CONFIG.SYS
or delete BTCLIENT.DLL wherever it has been copied.

BackTalk has only been tested on OS/2 Warp 4 with FixPak 5 with a Gravis
Ultrasound PnP and a Sound Blaster 32, but it should work on OS/2 Warp 3
and up with any sound card.  For 8 bit sound cards, remember to use -b 8 to
start the server.  If you have two sound cards, use the garbage one with
BackTalk (using -D) to have your good one free at all time, and have
BackTalk enabled at all time (even while playing games, yah!).


II. CMU Pronunciation Dictionary
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BackTalk sounds much better if you install an optional dictionary.  An
American English dictionary can be found online as a ZIP file at

http://www.cris.com/~djd/products.html

  and also as a GZIP file (official site where newer versions might appear)

ftp://svr-ftp.eng.cam.ac.uk/pub/comp.speech/dictionaries/cmudict/cmudict.0.4.Z


To install this dictionary, do the following:

1. Copy the plain-text dictionary file into the BackTalk server directory.
   (You can edit it to replace OS pronunciation to OW1 EH1 S, for OS/2 to
   actually sound like OS/2, well almost)
2. Make sure you have plenty of hard drive space.  (15MB should be enough.)
3. Type "mkdictdb cmudict.04 adict.db" at a command prompt in BackTalk's
   directory.  Use the appropriate filename in place of cmudict.04 if it
   changed.
4. Ignore errors.  (They represent multiple pronunciations and punctuation
                   not support by this freeware text to speech program)
5. Wait.
   ...a long time.
   ...a very, very, very long time.
   (We're talking at least an hour here.  Fortunately, you can multitask!)
6. When it's done, restart the BackTalk server and marvel at the frog prince's
   transformation.  You can delete the cmudict.04 file.


III. BTSERVER.EXE BackTalk Server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
BackTalk's server (BTSERVER.EXE) is the only program that actually converts
the text to phonemes and that uses the sound card.  The other programs only
puts text to be spoken in the server's Queue.  Therefore, the server must
be running anytime you want to hear speech.  It is recommended to start it
from the Start Up folder, minimized, and with all parameters wanted as the
Server doesn't use any CPU and practically no resources when idle.

Once the queue is initialized, BTSERVER.EXE will read the file named
BTSTART.LST found in the current directory, and for each line, will execute
the program found in it in a minimized state (at the will of the starting
program though).  The syntax is very simple:

<[path to the executable] _full_ filename of the executable> [parameters]

To execute such things as REXX scripts, you must use a REXX interpreter
like CMD.EXE, or 4OS2.EXE, like so:  cmd.exe /c rexx.cmd

example:

x:\backtalk\clients\spkclock.exe -l 30 -mc
cmd.exe /c myscript.cmd

Applications started this way will have guaranteed access to BackTalk
server's queue as well as being terminated once the server who started them
is.


The BackTalk server supports parameters that are inherited from RSynth, as
well as a couple more.  These parameters will take effect for the whole
server session as defaults.  Use --help to see the following.

Audio Initialization:
 -r <d> [8]	Sample Rate in kHz - 8, 11, 22, or 44
 [+|-]Q [no]    Quiet - No sound output
 -b <d> [16]	8 or 16 bit sample playback
 -V <u> [100]	Volume in %
 -a <lg> [1]	Amplification factor
 -D <u> [0]	Sound Card Device ID (0 = default device)

Synth parameters:
 [+|-]q [yes]	Quiet - minimal messages
 [+|-]I [no]	Impulse glottal source
 -c <d> [0]	Number cascade formants
 -F <d> [0]	F0 flutter
 -f <lg> [10]	mSec per frame
 -t <d> [10]	Tilt dB
 -x <d> [1330]	Base F0 in 0.1Hz

Holmes:
 -p <string> []	Parameter file for plot
 -j <string> []	Data for alternate synth (JSRU)
 -S <d> [1]	Speed (1.0 is 'normal')
 -K <lg> [1]	Parameter filter 'fraction'

Dictionary:
 -d <string> [a]	Which dictionary [b|a]

Misc:
 [+|-]T [yes]	Text, show readable text
 [+|-]v [no]	Verbose, show unreadable phonemes
 [+|-]i [no]    Display pronunciation conversion errors


Play around with the weird options to see what they do, since I don't know
more than you do and Rsynth docs are not very complete.  Also, tricks
that works with RSynth should also work with BackTalk, and if you are a
phonetic master, you might want to get the additional technical files from
the RSynth package.
ftp://hobbes.nmsu.edu/pub/os2/apps/mmedia/sound/util/rsynth23.zip

You might notice that the server still convert strings to phonemes even
after a Purge or when it is muted.  It's just to complicated to try to do
something in the converter's spaghetti, so I will have to leave it that
way.


IV. SPKMAIL.CMD  Speaking Mail
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
One of most useful program included with this project is SPKMAIL.CMD.
When this script is installed with your e-mail program, you will be
notified by voice whenever new mail arrives.  This is particularly useful
if you leave your mailer running but minimized while you are connected to
the Internet. SPKMAIL reads the author and the subject of any new message,
preventing the need to bring up your mailer every time new mail arrives.

SPKMAIL requires an e-mail program that supports REXX exits.  I've used it
successfully with PMMail 1.51 to 1.95, MR/2 ICE 1.10 to 1.26, Internet
Adventurer 0.96 Mail, and Post Road Mailer 2.5.  Newer version not tested
here should work similarly, however I haven't had the chance to test them.
Let me know if you had success with them.  It would also be a good idea to
disable WAV sound to free the sound card if it doesn't support multiple
channel.

One thing I don't understand though is why some mailers claim "REXX
Support", but they actually execute CMD.EXE to process it, and even worse,
some don't even let you execute your own EXE instead of REXX scripts.


PMMail 1.51 to 1.95:
~~~~~~~~~~~~~~~~~~~~
1. Open PMMail main window.
2. Select "Utilities Settings..." from the "Account" menu.
3. Click the "REXX Exits" tab.
4. Check the "Message Receive Exit" checkbox.
5. Enter the full pathname to and including SPKMAIL.CMD.
6. Press OK.

MR/2 ICE 1.10 to 1.26:
~~~~~~~~~~~~~~~~~~~~~~
1. Copy flip.exe (located in <backtalk_dir>\flip) where MR2I.EXE resides.
2. Edit SPKMAIL.CMD and change 'flip = 1'.
2. Open MR/2 ICE.
3. Select "Filter maintenance..." from the "Utilities" menu.
4. Press the "New" button.
5. Enter a description (ie.: Speaking Mail)
8. Check the "Link to REXX" checkbox.
9. Enter the full pathname to and including SPKMAIL.CMD.
10. Press OK.
11. Press Done.

Internet Adventurer 0.96 Mail
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. Open Internet Adventurer Main window.
2. Open the News and Mail window.
3. Open the Filter notebook from the Settings menu.
4. Select Add, and give a name (ie: Speaking Mail)
5. Uncheck "Incoming News", "Outgoing News" and "Outgoing Mail", and check
   "Incoming Mail".
6. Check Execute REXX and type the full pathname to and including SPKMAIL.CMD
7. Press OK.

Post Road Mailer 2.5
~~~~~~~~~~~~~~~~~~~~
1. Open Post Road Mailer main window.
2. Choose the User Exits tab in the Settings... notebook found in File menu.
3. In Receive message exit, enter the full pathname to and including
   SPKMAIL.CMD or Find it.
4. Check off "Exit is active" and choose "Minimized" radio button.
5. Close the window to save the settings.


V. SPKCLOCK.EXE Speaking Clock and SPKTIMER.EXE Speaking Timer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The old CMD files are still included for the sake of having made them, but
the EXE are more precise and have a couple more features added to them.

NOTE!!: Both of them are dependant on the system clock, so changing it will
mix them (or you) up.

SPKCLOCK.EXE will speak the time at a lap specified with -l command line
parameter.  You can also specify civil (AM PM), offset (quarter before/to)
or the international time (24 hours) with -m.  By default, Speaking Clock
will try to fall even on the hour start, but you can disable that with -d.

----
Speaking Clock - Part of the BackTalk project

spkclock [-l <mins>] [-m<mode>] [-d] [-?]
 -d  disables hour start
 -l  specifies lap in minutes (default = 15)
 -m  mode, i=international, c=civil, and o=offset (default = i)
 -?  this help screen


SPKTIMER.EXE is a timer, which has the ability to speak a message and to
specify the laps of time between this event.  It also has an urgent mode,
that gets activated if the urgent mode toggle time is greater than 0.  The
urgent mode has its own message and lap time too.  And finally, the alert
message, which gets spoken when the timer has finished counting.

----
Speaking Timer - Part of the BackTalk project

spktimer [-t1 <mins>] [-l1 <secs>] [-m1 <str>] [-t2 <mins>] [-l2 <secs>]
[-m2 <str>] [-m3 <str>]

-t1  countdown time (minutes)
-l1  laps time (seconds)
-m1  message

-t2  time remaining to switch in urgent mode (minutes)
-l2  laps time in urgent mode (seconds)
-m2  message in urgent mode

-m3  alert message when timer has stopped

-?   Help screen

ex.: [D:\btalk] spktimer -t1 45 -t2 15 -m1 "for your dentist rendezvous" -m2
     "for your VERY VERY important dentist rendezvous" -l1 300 -l2 120 -m3
     "Your dentist rendezvous!!"

Yes, that fits on the command line.  For example, you can execute it from
agendas that support execution of programs.


Both programs can be safely terminated by closing the window in which they
are executing.


VI. SPKIRC.CMD   Speaking IRC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The files in clients\spkirc:

ircstart.txt A sample startup command file.
spkirc.cfg   A sample configuration files for custom voices
             for a specified nicknames.
spkircm.cmd  The incoming messages IRC REXX file.
spkircc.cmd  The outgoing commands IRC REXX file.

You have to copy all of them into your IRC client directory (or a corres-
ponding script directory).  The files can have any name wanted, except
spkirc.cfg which needs to be named that way. If you already have a REXX
incoming message file, a REXX outgoing command file and a startup command
file, please add the content of all of the above at the _very beginning_ of
the currently installed file, *EXCEPT* the last line "Return 'OK'".

GammaTech IRC 2.0x
~~~~~~~~~~~~~~~~~~
1. Copy all the above files in to GTIRC.EXE directory.
2. Open the Startup dialog box from Options menu
3. Startup /Cmd        /run ircstart.txt
   Input Msg Script    spkircm.cmd       (or the corresponding filenames)
   Ouput Cmd Script    spkircc.cmd

Internet Adventurer 0.96 IRC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. Copy all the above files in to INETADV.EXE directory.
2. Open Settings dialog box from the Options menu.  Choose IRC and Scripts tab.
3. Incoming REXX Script name    spkircm.cmd
   Outgoing REXX Script name    spkircc.cmd    (or the corresponding filenames)
   Startup command              /run ircstart.txt
   
Since Internet Adventurer IRC does not support IRC Variable (yet?) you will
have to edit spkircm.cmd and replace some text. Be sure to have word wrap
*DISABLED* in your text editor.  Search for the exact string:

         ircrexxvariable(winhandle,"$PARTIALNICK")

and replace with exactly the partial nickname wanted (to enable recognition
of messages addressed to you publicly) in quotes, ex.:

         'guard'

IRC/2 0.78
~~~~~~~~~~
I was not unable to test the script with IRC/2 since the functionality is
not supported in the shareware version.  The scripts should work as
expected. To set your partial nickname variable in IRC/2 (to enable
recognition of messages addressed to you publicly),
/assign $PARTIALNICK <partial_nick_name> should work.

         /assign $PARTIALNICK guard

I was also unable to use a startup command file. I have tried IRCRC,
IRCSTART and a REXX Startup file and none worked, go figure.

Complain to IRC/2 author, not me.

New IRC commands implemented for SPKIRC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
First, you can set your partial nickname to enable recognition of messages
addressed to you publicly, by setting the IRC Variable named $PARTIALNICK
(it is case sensitive).

GTIRC uses the command /var (ex.: /var $PARTIALNICK,guard), Internet
Adventurer does not support IRC Variables, and IRC/2 uses the command
/assign (ex.: /assign $PARTIALNICK guard).  This variable should be set in
the startup command file (ircstart.txt) as well as other default setting
you might want to set below.


/LOADSPKIRC   This command will enable SPKIRC functionality and will load
              (or reload) SPKIRC.CFG settings in memory.  SPKIRC.CFG will
              allow you to specify the frequency, the flutter and the speed
              of the voice for specific partial nicknames (see SPKIRC.CFG
              for more information). Partial nicknames allows SPKIRC to
              recognize, for example, "[//_Thisnick_/*]" as "Thisnick".

/SPKIRC <command> <on|off>
                  Anything else than ON will default to OFF.

        Available commands for <command>:

        CTCP    Will speak CTCP requests (like PING and VERSION) made on you.

        DCC     Will speak DCC CHAT and SEND requests made on you.

        NOTIFY  Will speak signon and signoff notification from the notify
                list.  Note:  this command is not aware of the current
                list, so it will give wrong information during modification
                of the notify list, but will work fine afterwards.

        NOTICE  This command disabled has priority over PUBMSG, PRIVMSG and
                MYMSG for obvious reasons.  Enabled, it will will speak
                NOTICE received and will act under the influence of PUBMSG,
                PRIVMSG and MYMSG setting.

        PRIVMSG Will speak ANY messages that only you can see.

        MYMSG   Will speak ANY messages addressed to you, privately or
                publibly (the latter will depend on the setting of
                $PARTIALNICK IRC Variable).

        PUBMSG  Will speak ANY messages that can be seen by everyone.
                This command enabled has priority on all of the following.

        JOIN    Will speak people joining your joined channels.

        LEFT    Will speak people leaving your joined channels.

        SIGNOFF Will speak people signing off your joined channels.

        NICK    Will speak any nickname changes in your joined channels.

        KICK    Will speak anyone being kicked out in your joined channels.


VII. Implementing BackTalk speech into REXX
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
At the beginning of your REXX script, after the initial /* */, insert the
following command:

call RxFuncAdd 'RxBTLoad', 'btclient', 'RxBTLoad'
call RxBTLoad

BTCLIENT.DLL will need to be available.

Thereafter, instead of using 'say' use 'RxBTSayString' to speech things:

call RxBTSayString "hello world!",0,0,0

There is also

call RxBTSayFile "f:\mail\love.message",0,0,0

and

call RxBTSayNumQueue 0,0,0

See below for description of these functions, their parameters and return
codes.

The CMD files included provide thorough examples.


VIII. For programmers
~~~~~~~~~~~~~~~~~~~~~
Yes you!  Do you want your programs to have speech support for FREE??
Here's the trick!

You will be able to import the following functions from BTCLIENT.DLL:

int _System BTSayString(char *string, long frequency, double speed, int flutter);
int _System BTSayFile(char *filename, long frequency, double speed, int flutter);
int _System BTSayNumQueue(long frequency, double speed, int flutter);

I have included these three parameters since they seem to be the ones that
have the most effect on the voice:

frequency   This is the Base F0 in 0.1Hz (!??).   Try values around 1330
speed       This is the number of mSec per frame. Try values around 10
flutter     This is the F0 flutter.               Try values around 1-100

A value of 0 specified for these parameters will use the default value the
user has specified on BackTalk's server startup.

These functions will all return 0 if an error occured, and anything else
than 0 if the message has been successfully delivered to BackTalk's server.

- BTSayString() will speak any strings giving to it (there is no practical
  limit to the string length).
- BTSayFile() will speak a whole text file from A to Z, but this file needs
  to be present at all time before and while the server reads it.
- BTSayNumQueue() will say how many items are currently queued (this
  message has obviously priority over the others).

Example sources of SPKCLOCK and SPKTIMER are included in source.zip.

Also, source codes for server and client DLL are freely available, and done
with EMX 0.9c and VisualAge C++ 3.0.  I will send them to you on request. I
want to keep track of my source codes. :)


IX. Legal stuff
~~~~~~~~~~~~~~~
This freeware product is used at your own risk, although it is highly
improbable it can cause any damage.

If you plan on copying me, please give me the credits, thanks.


X. Contacting the Author
~~~~~~~~~~~~~~~~~~~~~~~~
If you have any suggestions, comments or bug reports, please let me know me.

Samuel Audet

E-mail:    guardia@cam.org
Homepage:  http://www.cam.org/~guardia
IRC nick:  Guardian_ (be sure it is I before starting asking questions though)

Snail Mail:

   377, rue D'Argenteuil
   Laval, Quebec
   H7N 1P7   CANADA


XI. Acknowledgements
~~~~~~~~~~~~~~~~~~~~
Jim Little <jiml@teleport.com> for making this up, so I could optimize it. :)

Many thanks go to Nick Ing-Simmons (nik@tiuk.ti.com) for writing RSynth and
to Derek J. Decker (djd@cris.com) for porting it to OS/2.

Julien Pierre <julienp@edify.com> who helped me with OS/2 multimedia.

Cheng-Yang Tan (cytan@tristan.tn.cornell.edu) for writing UPTIME.EXE.

Unknown artistic genius that created the icons I stole.  If you recognize
any of these icons as your own, let me know so I can give you credit.

J Hulley-Miller <jhm@pobox.com> for rewriting SPKCLOCK.CMD making it
something even better.

Elton Woo <eltonwo@cam.org> for idea support. (And wish him best luck)
