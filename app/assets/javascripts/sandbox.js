var flag = 0;
$("#sandboxcanvas")
  .drawRect({
    layer: true,
    fillStyle: '#E3E3E3',
    shadowColor: '#333',
    shadowBlur: 10,
    x: 10, y: 30,
    width: 400,
    height: 40,
    mask: true
  });
$("#sandboxcanvas")
  .drawRect({
    layer: true,
    name: 'bar',
    fillStyle: '#C23685',
    shadowColor: '#333',
    shadowBlur: 10,
    x: -340, y: 10,
    width: 400,
    height: 80
  });
$("#sandboxcanvas")
  .drawText({
    fillStyle: '#C23685',
    layer:'true',
    name: 'shinchokung',
    x: 250, y: 45,
    fontSize: 21,
    font: 'sans-serif',
    text: '進捗ダメです！'
  });
$("#sandboxcanvas")
  .drawText({
    fillStyle: '#C9E8F1',
    layer:'true',
    name: 'shinchokuok',
    x: 250, y: 145,
    fontSize: 21,
    font: 'sans-serif',
    text: '進捗あります！'
  });
$("#sandboxcanvas")
  .click( function() {
    if(flag == 0){
      flag = 1;
      $(this).animateLayer('bar', {
        fillStyle: '#1E98B9',
        x: '+=350'
      });
      $(this).animateLayer('shinchokuok', {
        y: '-=100'
      });
      $(this).animateLayer('shinchokung', {
        y: '-=100'
      });
    }else{
      flag = 0;
      $(this).animateLayer('bar', {
        fillStyle: '#C23685',
        x: '-=350'
      });
      $(this).animateLayer('shinchokuok', {
        y: '+=100'
      });
      $(this).animateLayer('shinchokung', {
        y: '+=100'
      });
    }
  });
