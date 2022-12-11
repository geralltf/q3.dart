part of tech3;

/* Author: Gerallt G. Franke */
/* Proxied JQuery animations library. Requires jQuery effects */
typedef OnAnimationUiComplete(Element element);

class jQuery
{
  String selector;
  
  jQuery(){}
  
  jQuery find(String selector)
  {
    jQuery j = new jQuery();
    j.selector = selector;
    return j;
  }
  
  jQuery fadeIn(int time, [OnAnimationUiComplete onComplete])
  {
    //query(selector).style.display = 'block';
    
    JsObject js = context['jsinterop'];
    js.callMethod('effect',['fadein',selector,time, (String e)
    {
      if(onComplete!=null)
      {
        onComplete(query(e));
      }
    }]);
    return this;
  }
  
  jQuery fadeOut(int time, [OnAnimationUiComplete onComplete])
  {
    JsObject js = context['jsinterop'];
    js.callMethod('effect',['fadeout',selector,time, (String e)
    {
      if(onComplete!=null)
      {
        onComplete(query(e));
      }
    }]);
    return this;
  }
}