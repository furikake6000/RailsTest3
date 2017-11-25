function limitdate (limitstr){
  var limit = new Date(limitstr);
  var resttime = Math.max((limit.getTime() - Date.now()) / 1000, 0);

  var str = "残り " +
                ('00' + Math.floor(resttime/60/60)).slice(-2) + ":" +
                ('00' + Math.floor(resttime/60%60)).slice(-2) + ":" +
                ('00' + Math.floor(resttime%60%60)).slice(-2);
  return str;
};

$.fn.progbar = function(){
  $(this).drawRect({
      layer: true,
      fillStyle: '#000',
      shadowColor: '#333',
      shadowBlur: 10,
      x: 10, y: 10,
      width: 400,
      height: 20,
      mask: true
    });
  $(this).drawRect({
      layer: true,
      name: 'bar',
      fillStyle: '#C23685',
      shadowColor: '#333',
      shadowBlur: 10,
      x: -340, y: 10,
      width: 400,
      height: 20
    });
};
