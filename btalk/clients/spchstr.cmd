/*
 * SpchStr.CMD
 *
 * Sends any string to the speech queue.
 *
 */

call RxFuncAdd 'RxBTSayString', 'btclient', 'RxBTSayString'

parse arg cmdline
call RxBTSayString cmdline,0,0,0
