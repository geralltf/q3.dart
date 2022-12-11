part of tech3;

typedef OnAudioToneMatched(tone);

class audio_graph
{
  AudioContext context;
  AnalyserNode analyser;
  WaveShaperNode distortion;
  GainNode gainNode;
  BiquadFilterNode biquadFilter;
  ConvolverNode convolver;
  MediaStreamAudioSourceNode source;
  
  OnAudioToneMatched onAudioToneMatched=(tone){
    
  };
  
  var concertHallBuffer;
  var soundSource;
  var drawVisual;
  var canvasCtx;
  CanvasElement canvas;
  var WIDTH;
  var HEIGHT;
    
  var visualSetting = 'frequencybars'; // frequencybars, sinewave, off
  var frequencybars_vis_fft_sample_size = 128; // 256
  var sinewave_vis_fft_sample_size = 2048;
  
  List<marker> markers;
  
  void disp(List<int> lst)
  {
    String str = '';
    lst.forEach((int k)
    {
      str += k.toString() + ' ';
      
      
    });
    print(str);
  }
  
  void show_tone_marker(int marker_index)
  {
    DivElement dv = query('.Tone_'+marker_index.toString());
    dv.style.display = 'fixed';
  }
  
  void hide_tone_marker(int marker_index)
  {
    DivElement dv = query('.Tone_'+marker_index.toString());
    dv.style.display = 'none';
  }
  void hit_tone(marker m, int freq)
  {
    DivElement dv = query('.Tone_'+ m.freq_box.toString());
    dv.style.backgroundColor = 'yellow';
    print('hit tone: '+m.freq_box.toString());
    
  }
  
  bool has_player_hit_tones(List<int> tones)
  {
    bool hit = false;
    
    int hit_threshold = 10;
    int hits = 0;
    
    int i=0;
    tones.forEach((int tone)
    {
      markers.forEach((marker m)
      {
        if(m.position_index == i)
        {
          
          if(((tone >= (m.height - hit_threshold)) && (tone <= (m.height +hit_threshold) )) && !m.hit)
          {
            hits++;
            print(hits);
            
            hit_tone(m, tone);
            
            m.hit=true;
          }
          
        }
      });
      
      i++;
    });
    
    return hit;
  }
  
  void set_marker_pos(marker m)
  {
    CanvasElement graph = query('#audio-graph .visualizer');
    int ch = int.parse(query('#audio-graph').style.height.replaceAll('px', ''));
    
    DivElement dv = query('.Tone_'+m.freq_box.toString());
    
    if(dv == null)
    {
      dv = document.createElement('div');
      dv.classes.addAll(['Tone','Tone_'+m.freq_box.toString()]);
      dv.style.backgroundColor = 'yellow';
      dv.style.width = '16px';
      dv.style.height = '16px';
      dv.style.display = 'fixed';
      graph.parent.children.add(dv);
    }
    
    dv.style.position = 'relative';  // = 'position: relative; top:0px;left: 0px;';
    dv.style.top = ((m.height-16)).toString() + 'px';
    dv.style.left = (m.freq_box*16).toString()+ 'px';
    dv.style.display = 'inline';
  }
  
  void generate_tone_markers(int markers)
  {
    //markers = 1;
    Random rand = new Random();
    
    int ch = int.parse(query('#audio-graph').style.height.replaceAll('px', ''));
    
    for(int i = 0; i < 23; i++)
    {
      DivElement dv = query('.Tone_'+i.toString());
      if(dv!=null)
      {
        dv.remove();
      }
    }
    
    for(int i = 0; i < markers; i++)
    {

      int freq = rand.nextInt(10);
      
      var m = new marker();
      m.marker_id = i;
      m.height = rand.nextInt(100);
      m.freq_box = m.position_index = rand.nextInt(23);
      
      set_marker_pos(m);
      
      if(this.markers==null)
      {
        this.markers = new List<marker>();
      }
      this.markers.add(m);
      
    }
  }
  
  
  void process_audio_tones(Uint8List frequency_graph)
  {
    Uint8List g = frequency_graph;
    
    var tones = g.toList();
    
    if(has_player_hit_tones(tones))
    {
      print('hit');
    }

  }
  
  frequencybars_vis()
  {
    analyser.fftSize = frequencybars_vis_fft_sample_size;
    var bufferLength = analyser.frequencyBinCount;
    print(bufferLength);
    Uint8List dataArray = new Uint8List(bufferLength);

    canvasCtx.clearRect(0, 0, WIDTH, HEIGHT);

    onRequestedFrame(double time) 
    {
      drawVisual = window.requestAnimationFrame(onRequestedFrame);

      analyser.getByteFrequencyData(dataArray); // analyser.getByteTimeDomainData(dataArray)

      // PROCESS AUDIO TONES
      process_audio_tones(dataArray);
      
      // RENDER AUDIO GRAPH
      canvasCtx.fillStyle = 'rgb(0, 0, 0)';
      canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);
      int barWidth = ((WIDTH / bufferLength) * 2.5).toInt();
      int barHeight;
      int x = 0;
      for(int i = 0; i < bufferLength; i++) 
      {
        barHeight = dataArray[i];
        canvasCtx.fillStyle = 'rgb(' + (barHeight + 100).toString() + ',50,50)';
        canvasCtx.fillRect(x, HEIGHT - barHeight / 2, barWidth, barHeight / 2);
        x += barWidth + 1;
      }
    };

    onRequestedFrame(0.0);
  }
  
  sinewave_vis()
  {
    analyser.fftSize = sinewave_vis_fft_sample_size;
    var bufferLength = analyser.fftSize;
    print(bufferLength);
    Uint8List dataArray = new Uint8List(bufferLength);

    canvasCtx.clearRect(0, 0, WIDTH, HEIGHT);
    
    onRequestedFrame(double time) 
    {

      drawVisual = window.requestAnimationFrame(onRequestedFrame);
      
      analyser.getByteFrequencyData(dataArray); // analyser.getByteTimeDomainData(dataArray)

      // PROCESS AUDIO TONES
      process_audio_tones(dataArray);
      
      // RENDER AUDIO GRAPH
      canvasCtx.fillStyle = 'rgb(0, 0, 0)';
      canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);
      canvasCtx.lineWidth = 2;
      canvasCtx.strokeStyle = 'rgb(200, 200, 200)';
      canvasCtx.beginPath();
      var sliceWidth = WIDTH * 1.0 / bufferLength;
      var x = 0;
      for(var i = 0; i < bufferLength; i++) 
      {
        var v = dataArray[i] / 128.0;
        var y = v * HEIGHT/2;
        if(i == 0) 
        {
          canvasCtx.moveTo(x, y);
        } 
        else 
        {
          canvasCtx.lineTo(x, y);
        }
        x += sliceWidth;
      }

      canvasCtx.lineTo(canvas.width, canvas.height/2);
      canvasCtx.stroke();
    };

    onRequestedFrame(0.0);

  }
  
  // some code adapted from : http://mdn.github.io/voice-change-o-matic/
  audio_graph()
  {
    context = new AudioContext();
    analyser = context.createAnalyser();
    
    analyser.minDecibels = -90; // -90db
    analyser.maxDecibels = -10; // -10db
    analyser.smoothingTimeConstant = 0.85;
    
    distortion = context.createWaveShaper();
    gainNode = context.createGain();
    biquadFilter = context.createBiquadFilter();
    convolver = context.createConvolver();
    
    distortion.curve = makeDistortionCurve(400);
    
    // grab audio track via XHR for convolver node
    
    //var soundSource, concertHallBuffer;
    
    HttpRequest.request('audio/concert-crowd.ogg',responseType: 'arraybuffer').then((HttpRequest request)
    {
      var audioData = request.response;

//      context.decodeAudioData(audioData, (buffer) {
//          concertHallBuffer = buffer;
//          soundSource = audioCtx.createBufferSource();
//          soundSource.buffer = concertHallBuffer;
//        }, (e){"Error with decoding audio data" + e.err}
//        );
      context.decodeAudioData(audioData).then((AudioBuffer buffer)
      {
        concertHallBuffer = buffer;
        soundSource = context.createBufferSource();
        soundSource.buffer = concertHallBuffer;
        
      }).catchError((e){
        return "Error with decoding audio data" + e.err;
      });
      

      //soundSource.connect(context.destination);
      //soundSource.loop = true;
      //soundSource.start();
    });
    
    // set up canvas context for visualizer
    
    canvas = query('.visualizer');
    canvasCtx = canvas.getContext("2d");
    //var visualSelect = document.getElementById("visual");
    
    generate_tone_markers(3);
    
    //main block for doing the audio recording
    
    if (window.navigator.getUserMedia != null) 
    {
      print('getUserMedia supported.');
      
      window.navigator.getUserMedia(audio: true).then((MediaStream stream) 
      {
        source = context.createMediaStreamSource(stream);
        source.connectNode(analyser);
        analyser.connectNode(distortion);
        distortion.connectNode(biquadFilter);
        biquadFilter.connectNode(convolver);
        convolver.connectNode(gainNode);
        gainNode.connectNode(context.destination);
        
        visualize();
        //voiceChange();
        
      }).catchError((e)
      {
        print('the following gUM error occured:');
        print(e);
      });
    }
    else
    {
      print('getUserMedia not supported on your browser!');
    }
  }
  
  makeDistortionCurve(amount) 
  {
    // distortion curve for the waveshaper, thanks to Kevin Ennis
    // http://stackoverflow.com/questions/22312841/waveshaper-node-in-webaudio-how-to-emulate-distortion
    num k;
    if(amount.runtimeType is num)
    {
      k = amount;
    }
    else
    {
      k = 50;
    }
    //var k = typeof amount === 'number' ? amount : 50,
    
    var n_samples = 44100;
    Float32List curve = new Float32List(n_samples); //var curve = new Float32Array(n_samples);
    //curve.setAll(0, );
    
    var deg = PI / 180;
    var i = 0;
    var x;
    for ( ; i < n_samples; ++i ) 
    {
      x = i * 2 / n_samples - 1;
      curve[i] = ( 3 + k ) * x * 20 * deg / ( PI + k * (x.abs()) );
    }
    
    return curve;
  }
  
  visualize() 
  {
    WIDTH = canvas.width;
    HEIGHT = canvas.height;

    print(visualSetting);

    if(visualSetting == "sinewave") 
    {
      sinewave_vis();
    } 
    else if(visualSetting == "frequencybars") 
    {
      frequencybars_vis();
    } 
    else if(visualSetting == "off") 
    {
      canvasCtx.clearRect(0, 0, WIDTH, HEIGHT);
      canvasCtx.fillStyle = "red";
      canvasCtx.fillRect(0, 0, WIDTH, HEIGHT);
    }

  }
  
  static audio_graph graph;
  
  static void init()
  {
    graph = new audio_graph();
    
    
  }
}