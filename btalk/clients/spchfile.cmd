/*
 * SpchFile.CMD
 *
 * Sends any text file to the speech queue.
 *
 */

call RxFuncAdd 'RxBTSayFile', 'btclient', 'RxBTSayFile'

parse arg cmdline
call RxBTSayFile cmdline,0,0,0
