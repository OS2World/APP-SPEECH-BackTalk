#define INCL_DOS
#include <os2.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "btclient.h"

void help(char *program);

int main(int argc, char *argv[])
{
   double time;
   char temp[256];
   int i;

   HEV sem;
   HTIMER timer;
   ULONG resetcount;

   int minsleft, secsleft, timersecs, urgsecsleft, countsecs;

   int timermins = 60;      /* countdown time, minutes  */
   int lap = 300;           /* lap between spoken time left, seconds */
   char *message = " ";     /* message pronounced after the time left */

   int urgminsleft = 20;    /* Falls in urgent mode after urgminleft time, minutes */
   int urglap = 180;        /* Urgent mode lap, seconds  */
   char *urgmsg = " ";      /* Urgent mode message  */

   char *alertmsg = " ";    /* Alert message when timer has stopped */

   for(i = 0; i < argc; i++)
      if ((argv[i][0] == '/') || (argv[i][0] == '-'))
         switch(toupper(argv[i][1]))
         {
            case 'T': if(argv[i][2] == '1')
                         timermins = atoi(argv[++i]);
                      else if(argv[i][2] == '2')
                         urgminsleft = atoi(argv[++i]);
                      break;
            case 'L': if(argv[i][2] == '1')
                         lap = atoi(argv[++i]);
                      else if(argv[i][2] == '2')
                         urglap = atoi(argv[++i]);
                      break;
            case 'M': if(argv[i][2] == '1')
                         message = argv[++i];
                      else if(argv[i][2] == '2')
                         urgmsg = argv[++i];
                      else if(argv[i][2] == '3')
                         alertmsg = argv[++i];
                      break;

            case '?': help(argv[0]); return 0;
         }

   timersecs = timermins * 60;      /* Converts minutes into seconds. */
   urgsecsleft = urgminsleft * 60;


   /* Set some abnormalities */

   if(lap > timersecs) lap = timersecs;
   if(urgsecsleft > timersecs) urgsecsleft = 0;
   if(urglap > urgsecsleft) urglap = urgsecsleft;
   if(urglap > lap) urglap = lap;

   /* Give some visual information */

   printf("countdown time: %d minutes.\n",timersecs/60);
   printf("laps time: %d seconds.\n",lap);
   printf("message: %s\n", message);
   printf("\n");
   printf("fall in urgent mode at %d minutes left.\n",urgsecsleft/60);
   printf("laps time in urgent mode: %d seconds.\n",urglap);
   printf("urgent message: %s\n", urgmsg);
   printf("\n");
   printf("alert message: %s\n",alertmsg);

   if(DosCreateEventSem(NULL,&sem,DC_SEM_SHARED,FALSE)) return 1;

   sprintf(temp,"Starting a %d minute countdown %s.",timersecs/60,message);
   BTSayString(temp,0,0,0);
   time = clock()/CLOCKS_PER_SEC;
   countsecs = timersecs;

   if(!DosStartTimer(lap * 1000,(HSEM) sem,&timer))
   {
      while(countsecs > urgsecsleft)
      {
         if(DosWaitEventSem(sem, -1)) return 1;
         DosResetEventSem(sem,&resetcount);
         countsecs = timersecs - (clock()/CLOCKS_PER_SEC - time);
         minsleft = countsecs / 60;
         secsleft = countsecs % 60;
         sprintf(temp,"There is %d minutes and %d seconds left %s.",minsleft,secsleft,message);
         BTSayString(temp,0,0,0);
         if(countsecs <= lap)
            while(countsecs > urgsecsleft)
            {
               DosSleep(1000);
               countsecs = timersecs - (clock()/CLOCKS_PER_SEC - time);
            }
      }
   DosStopTimer(timer);
   DosResetEventSem(sem,&resetcount);
   }

   if(!DosStartTimer(urglap * 1000,(HSEM) sem,&timer))
   {
      while(countsecs > 0)
      {
         if(DosWaitEventSem(sem, -1)) return 1;
         DosResetEventSem(sem,&resetcount);
         countsecs = timersecs - (clock()/CLOCKS_PER_SEC - time);
         minsleft = countsecs / 60;
         secsleft = countsecs % 60;
         sprintf(temp,"There is only %d minutes and %d seconds left %s.",minsleft,secsleft,message);
         BTSayString(temp,0,0,0);
         if(countsecs <= urglap)
            while(countsecs > 0)
            {
               DosSleep(1000);
               countsecs = timersecs - (clock()/CLOCKS_PER_SEC - time);
            }
      }
   DosStopTimer(timer);
   DosResetEventSem(sem,&resetcount);
   }

   BTSayString(alertmsg,0,0,0);

   return 0;

}

void help(char *program)
{
      printf("Speaking Timer - Part of the BackTalk project\n"
             "\n"
             "%s [-t1 <mins>] [-l1 <secs>] [-m1 <str>] [-t2 <mins>] [-l2 <secs>] [-m2 <str>] [-m3 <str>]\n"
             "\n"
             "-t1  countdown time (minutes)\n"
             "-l1  laps time (seconds)\n"
             "-m1  message\n"
             "\n"
             "-t2  time remaining to switch in urgent mode (minutes)\n"
             "-l2  laps time in urgent mode (seconds)\n"
             "-m2  message in urgent mode\n"
             "\n"
             "-m3  alert message when timer has stopped\n"
             "\n"
             "-?   Help screen\n"
             "\n"
             "ex.: [D:\\btalk] spktimer -t1 45 -t2 15 -m1 \"for your dentist rendezvous\" -m2 \n"
             "     \"for your VERY VERY important dentist rendezvous\" -l1 300 -l2 120 -m3 \n"
             "     \"Your dentist rendezvous!!\"\n",program);
}
