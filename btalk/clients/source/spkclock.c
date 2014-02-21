#define INCL_DOS
#include <os2.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "btclient.h"

enum MODE { civil, offset, international } mode;

void help(char *program);

int main(int argc, char *argv[])
{
   time_t ltime;
   struct tm *stime;

   USHORT lapsecs = 0, lapmins = 15;
   BOOL hourstart = TRUE;

   int i;

   HEV sem;
   HTIMER timer;
   ULONG resetcount;

   char string[256],
        *temp = "international";

   mode = international;

   for(i = 0; i < argc; i++)
      if ((argv[i][0] == '/') || (argv[i][0] == '-'))
         switch(toupper(argv[i][1]))
         {
            case 'D': hourstart = FALSE; break;
            case 'L': lapmins = atoi(argv[++i]); break;
            case 'M':
               switch(toupper(argv[i][2]))
               {
                  case 'I': mode = international; temp = "international"; break;
                  case 'C': mode = civil; temp = "civil"; break;
                  case 'O': mode = offset; temp = "offset"; break;
               }
               break;
            case '?': help(argv[0]); return 0;
         }

   if(DosCreateEventSem(NULL,&sem,DC_SEM_SHARED,FALSE)) return 1;

   time(&ltime);
   stime = localtime(&ltime);
   printf("Started on %s",ctime(&ltime));
   printf("Running in %s mode.\n",temp);
   printf("Intervals between time announcements will be %u minutes.\n",lapmins);

   if(hourstart)
   {
      /* calculates number of second needed to fall even
         at nearest second on next lap */
      lapsecs = (lapmins - stime->tm_min % lapmins) * 60 - stime->tm_sec;
      printf("First Interval will be %u minutes and %u seconds.\n",lapsecs/60,lapsecs%60);
   }
   else
      lapsecs = lapmins*60;

   if(DosStartTimer(lapsecs * 1000,(HSEM) sem,&timer)) return 1;

   while(1)
   {
      strcpy(string,"It is ");

      if(mode == civil)
      {
         if(stime->tm_hour > 12)
            _itoa(stime->tm_hour - 12, strchr(string,'\0'),10);
         else if(stime->tm_hour == 0)
            strcat(string,"12"); /* midnight */
         else
            _itoa(stime->tm_hour, strchr(string,'\0'),10);

         strcat(string, " ");

         if(stime->tm_min < 10)
         {
            strcat(string,"O ");
            _itoa(stime->tm_min, strchr(string,'\0'),10);
         }
         else if(stime->tm_min != 0)
            _itoa(stime->tm_min, strchr(string,'\0'),10);

         if(stime->tm_hour > 11)
            strcat(string," P M");
         else
            strcat(string," AY M");

      }
      else if(mode == offset)
      {
         if(stime->tm_min != 0)
         {
            if(stime->tm_min == 15)
               strcat(string,"quarter past ");
            else if(stime->tm_min == 30)
               strcat(string,"half past ");
            else if(stime->tm_min == 45)
            {
               strcat(string,"quarter to ");
               stime->tm_hour++;
            }
            else if(stime->tm_min > 30)
            {
               _itoa(60 - stime->tm_min, strchr(string,'\0'),10);
               strcat(string," minutes to ");
               stime->tm_hour++;
            }
            else if(stime->tm_min < 30)
            {
               _itoa(stime->tm_min, strchr(string,'\0'),10);
               strcat(string," minutes past ");
            }
         }

         if(stime->tm_hour > 12)
            _itoa(stime->tm_hour - 12, strchr(string,'\0'),10);
         else if(stime->tm_hour == 0)
            strcat(string,"12"); /* midnight */
         else
            _itoa(stime->tm_hour, strchr(string,'\0'),10);

         if(stime->tm_min == 0) strcat(string," O'Clock");

      }
      else if(mode == international)
      {
         _itoa(stime->tm_hour, strchr(string,'\0'),10);
         strcat(string," hundred hours ");
         if(stime->tm_min > 0)
         {
            _itoa(stime->tm_min, strchr(string,'\0'),10);
            strcat(string," minutes");
         }
         if(stime->tm_sec > 0)
         {
            strcat(string," and ");
            _itoa(stime->tm_sec, strchr(string,'\0'),10);
            strcat(string," seconds");
         }
      }
      strcat(string,".");

      BTSayString(string,0,0,0);

      fflush(stdout);
      if(DosWaitEventSem(sem, -1)) return 1;
      DosResetEventSem(sem,&resetcount);

      if(lapsecs != lapmins*60)
      {
         lapsecs = lapmins*60;
         DosStopTimer(timer);
         if(DosStartTimer(lapsecs * 1000,(HSEM) sem,&timer)) return 1;
      }

      time(&ltime);
      stime = localtime(&ltime);
   }

   DosStopTimer(timer);
   return 0;
}

void help(char *program)
{
   printf("Speaking Clock - Part of the BackTalk project\n"
          "\n"
          "%s [-l <mins>] [-m<mode>] [-d] [-?]\n"
          " -d  disables hour start \n"
          " -l  specifies lap in minutes (default = 15)\n"
          " -m  mode, i=international, c=civil, and o=offset (default = i) \n"
          " -?  this help screen \n",program);
}
