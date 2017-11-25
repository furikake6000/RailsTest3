function limitdate (limitstr){
  var limit = new Date(limitstr);
  var resttime = Math.max((limit.getTime() - Date.now()) / 1000, 0);

  var str = "残り " +
                ('00' + Math.floor(resttime/60/60)).slice(-2) + ":" +
                ('00' + Math.floor(resttime/60%60)).slice(-2) + ":" +
                ('00' + Math.floor(resttime%60%60)).slice(-2);
  return str;
}
