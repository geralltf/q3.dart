part of tech3;

/**
 * original author mrdoob / http://mrdoob.com/ ported to dart by Gerallt G. Franke
 */

class StatsFps 
{
  int startTime;
  int prevTime;
  var ms;
  var fps;
  var frames;
  int mode;
  var msMin;
  var msMax;
  var fpsMin;
  var fpsMax;
  Element domElement;
  
  var REVISION = 12;
  
  Element msGraph;
  Element fpsGraph;
  Element fpsDiv;
  Element fpsText;
  Element msDiv;
  Element msText;
  
  StatsFps()
  {
    startTime = new DateTime.now().millisecondsSinceEpoch; 
    prevTime = startTime;
    ms = 0; 
    msMin = INFINITY; 
    msMax = 0;
    fps = 0; 
    fpsMin = INFINITY; 
    fpsMax = 0;
    frames = 0;
    mode = 0;
    
    loadView();
  }
  
  void display()
  {
    query("#viewport-fps").append( this.domElement );
  }
  
  loadView()
  {
    Element container = document.createElement( 'div' );
    container.id = 'stats';
    container.onMouseDown.listen((MouseEvent event) {
      event.preventDefault();
      setMode( ++ this.mode % 2 );
    }); // container.addEventListener( 'mousedown', function ( event ) { event.preventDefault(); setMode( ++ mode % 2 ) }, false );
    container.style.cssText = '';
    container.className = 'FpsStatsContainer';
    
    this.fpsDiv = document.createElement( 'div' );
    this.fpsDiv.id = 'fps';
    this.fpsDiv.className = 'FpsContaner';
    this.fpsDiv.style.cssText = '';
    container.append( this.fpsDiv );
    
    fpsText = document.createElement( 'div' );
    this.fpsText.id = 'fpsText';
    this.fpsText.className = 'Fps';
    this.fpsText.style.cssText = '';
    fpsText.innerHtml = 'FPS';
    this.fpsDiv.append( this.fpsText );

    fpsGraph = document.createElement( 'div' );
    this.fpsGraph.id = 'fpsGraph';
    this.fpsGraph.className = 'FpsGraph';
    this.fpsGraph.style.cssText = '';
    this.fpsDiv.append( this.fpsGraph );

    while ( this.fpsGraph.children.length < 74 )
    {
      Element bar = document.createElement( 'span' );
      bar.style.cssText = '';
      bar.className="BarItem";
      this.fpsGraph.append( bar );
    }

    msDiv = document.createElement( 'div' );
    this.msDiv.id = 'ms';
    this.msDiv.className = 'MS';
    this.msDiv.style.cssText = '';
    container.append( this.msDiv );

    this.msText = document.createElement( 'div' );
    this.msText.id = 'msText';
    this.msText.className = 'MSText';
    this.msText.style.cssText = '';
    this.msText.innerHtml = 'MS';
    this.msDiv.append( this.msText );
    
    this.msGraph = document.createElement( 'div' );
    this.msGraph.id = 'msGraph';
    this.msGraph.className = 'MSGraph';
    this.msGraph.style.cssText = '';
    this.msDiv.append( this.msGraph );

    while ( this.msGraph.children.length < 74 ) 
    {
      Element bar = document.createElement( 'span' );
      bar.className = "MsGraphBarItem";
      bar.style.cssText = '';
      this.msGraph.append( bar );
    }
    
    this.domElement = container;
  }
  
  void setMode(int value)
  {
    mode = value;

    switch ( mode ) {

      case 0:
        this.fpsDiv.style.display = 'block';
        this.msDiv.style.display = 'none';
        break;
      case 1:
        this.fpsDiv.style.display = 'none';
        this.msDiv.style.display = 'block';
        break;
    }
  }
  
  void updateGraph(Element dom,num value)
  {
    Element prev = dom.firstChild;
    Element child = dom.append( dom.firstChild );
    Element last = dom.lastChild;
    
    prev = prev.previousElementSibling;
    
    prev.classes.remove('CurrentBarItem');
    prev.classes.add('PreviousBarItem');
    child.classes.add('CurrentBarItem');
    
    child.style.height = value.toString() + 'px';
    
  }
  
  void update() 
  {
    startTime = this.end();
  }
  
  void begin()
  {
    startTime = new DateTime.now().millisecondsSinceEpoch;
  }
  
  int end()
  {
    int time = new DateTime.now().millisecondsSinceEpoch;

    ms = time - startTime;
    msMin = min( msMin, ms );
    msMax = max( msMax, ms );

    this.msText.text = ms.toString() + ' MS (' + msMin.toString() + '-' + msMax.toString() + ')';
    
    updateGraph( this.msGraph, min( 30, 30 - ( ms / 200 ) * 30 ) );

    frames ++;

    if ( time > prevTime + 1000 ) {

      num r = ( frames * 1000 ) / ( time - prevTime );
      fps = r.round();
      fpsMin = min( fpsMin, fps );
      fpsMax = max( fpsMax, fps );

      this.fpsText.text = fps.toString() + ' FPS (' + fpsMin.toString() + '-' + fpsMax.toString() + ')';
      
      updateGraph( this.fpsGraph, min( 30, 30 - ( fps / 100 ) * 30 ) );

      prevTime = time;
      frames = 0;
    }

    return time;
  }
}