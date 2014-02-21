/*

  Tue Jun 11 11:54:38 GMT 1996
  
  uptime.exe by Cheng-Yang Tan, cytan@tristan.tn.cornell.edu
  
  Description:
  	a UNIX like uptime application.
  
  To make:
  	gcc -Zomf -o uptime.exe uptime.c uptime.def
  	
  dependencies:
  	dqps.h	
  	
  The source below demonstrates usage of:
  	(1) the undocumented API DosQProcStatus	
  	(2) the thunking macros of emx-gcc version 2.7.2
  	(3) the documented API DosQuerySysInfo
  	
  Acknowledgements:
  	Tomas ™gren, stric@arbornet.org who wrote cstart from which I copied
  			     the code for getting the "uptime".
  			     
    Kai Uwe Rommel, for his excellent documentation on DosQProcStatus
    	available at ftp.leo.org in directory /pub/comp/os/os2/doc as proc.zip
    	
    Eberhard Mattes, for his documentation on the thunking macros of emx-gcc
    	available as emxdev.inf in the emx09b distribution.
    	
    IBM for making OS/2.    	
    	
  Copyright:
  	I release this code into the public domain *except* where the copyrights
  	are held by the individual authors above.  I hold no responsibility for the
  	usage of this code.
    	
*/


#define INCL_DOSFILEMGR
#define INCL_DOSMISC
#include <os2.h>
#include <time.h>
#include <malloc.h>

#include "dqps.h"

unsigned short dosQProcStatus(ULONG* DQPS_Buffer, USHORT buffer_size)
{
   return((unsigned short)(
   _THUNK_PASCAL_PROLOG (sizeof(ULONG*)+sizeof(USHORT));
   _THUNK_PASCAL_FLAT (DQPS_Buffer);
   _THUNK_PASCAL_SHORT (buffer_size);
   _THUNK_CALL (DosQProcStatus)));
  
}

void get_num_processes_num_threads(ULONG* num_processes, ULONG*num_threads)
{
   int count = 0;
   int size;
   PULONG DQPS_Buffer = _tmalloc(0xFFFF);
   USHORT buffer_size = 0xFFFF;
   struct qsPrec_s *pProcRecord;
   
   if(dosQProcStatus(DQPS_Buffer, buffer_size)){
      /*we have an error!*/
      *num_threads = *num_processes =  0;
      return;
   }   
   
   *num_threads = ((struct qsPtrRec_s*)DQPS_Buffer)->pGlobalRec->cThrds;
   
   pProcRecord = ((struct qsPtrRec_s*)DQPS_Buffer)->pProcRec;
   while(pProcRecord->RecType == 1){
      size = sizeof(struct qsPrec_s);
      size += pProcRecord->cTCB * sizeof(struct qsTrec_s) ;
      size += pProcRecord->c16Sem * sizeof(short) ;
      size += pProcRecord->cLib * sizeof(short) ;
      size += pProcRecord->cShrMem * sizeof(short) ;
      pProcRecord = (struct qsPrec_s*) ( (char*)pProcRecord + size ) ;
      count++ ;
   }
   *num_processes = count;
}


ULONG getdata(ULONG whichone)
{
	ULONG temp;
	DosQuerySysInfo ( whichone,  whichone,  &temp,  4);
	return temp;
}

int main(void)
{
	struct tm *tim;
	ULONG currtime, uptime;
	ULONG num_processes, num_threads;
	
	/* The current time */
	
	currtime=getdata(QSV_TIME_LOW);
	tim = localtime(&currtime);
	printf("  %u:%02u%s  ", 
		tim->tm_hour-12 >0? tim->tm_hour-12:tim->tm_hour,
		tim->tm_min,
        tim->tm_hour-12 >0? "pm":"am");

    /* up time */		
	uptime=getdata(QSV_MS_COUNT);
	printf("up %lu days, %lu:%02lu:%02lu, ",(uptime/(1000*3600*24))%365,(uptime/(1000*3600))%24,(uptime/(1000*60))%60,(uptime/(1000))%60); 

    /* the load of the system */		
    get_num_processes_num_threads(&num_processes, &num_threads);
	printf("load: %lu processes, %lu threads.\n", num_processes, num_threads);
    return 0;
}
