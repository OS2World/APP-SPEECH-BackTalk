/*
 * SpchNum.CMD
 *
 * Request BackTalk server to speak the number of items queued.
 *
 */

call RxFuncAdd 'RxBTSayNumQueue', 'btclient', 'RxBTSayNumQueue'

call RxBTSayNumQueue 0,0,0
