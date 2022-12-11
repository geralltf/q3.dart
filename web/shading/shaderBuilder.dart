part of tech3;

//
// WebGL Shader builder utility
//
class shaderBuilder
{
  Map attrib;
  Map varying;
  Map uniform;
  Map functions;
  List statements;
  
  shaderBuilder()
  {
    this.attrib = {};
    this.varying = {};
    this.uniform = {};
    
    this.functions = {};    
    this.statements = [];
  }
  
  void addAttribs (Map attribs) 
  {
    attribs.forEach((key,value){      
      this.attrib[key] = 'attribute ' + attribs[key] + ' ' + key + ';';
    });
  }
  
  void addVaryings(Map varyings) 
  {
    varyings.forEach((key,value){      
      this.varying[key] = 'varying ' + varyings[key] + ' ' + key + ';';
    });
  }
  
  void addUniforms (Map uniforms) 
  {
    uniforms.forEach((key,value){      
        this.uniform[key] = 'uniform ' + uniforms[key] + ' ' + key + ';';
    });
  }
  
  void addFunction (name, lines) 
  {
      this.functions[name] = lines.join('\n');
  }
  
  void addLines (List statements) 
  {
      for(var i = 0; i < statements.length; ++i) {
          this.statements.add(statements[i]);
      }
  }
  
  String getSource () 
  {
      var src = 
"""#ifdef GL_ES \n
precision highp float; \n
#endif \n""";
      
      this.attrib.forEach((key,value){      
        src += value + '\n';
      });
      
//      for(var i in this.attrib) {
//          src += this.attrib[i] + '\n';
//      }
      this.varying.forEach((key,value){      
              src += value + '\n';
            });
//      for(var i in this.varying) {
//          src += this.varying[i] + '\n';
//      }
      this.uniform.forEach((key,value){      
                    src += value + '\n';
                  });
//      for(var i in this.uniform) {
//          src += this.uniform[i] + '\n';
//      }
      this.functions.forEach((key,value){      
                          src += value + '\n';
                        });
//      for(var i in this.functions) {
//          src += this.functions[i] + '\n';
//      }
      
      src += 'void main(void) {\n\t';
      src += this.statements.join('\n\t');
      src += '\n}\n';
      
      return src;
  }
  
  // q3-centric functions
  
  void addWaveform (String name, waveform_t wf, timeVar) 
  {
   if(wf == null) { 
       this.statements.add('float ' + name + ' = 0.0;');
       return; 
   }
   
   if(timeVar==null) { timeVar = 'time'; }

   if(wf.phase is num ) 
   {
       wf.phase = wf.phase.toStringAsFixed(4);
   }
   String funcName;
   
   switch(wf.funcName) 
   {
       case 'sin':  
           this.statements.add('float ' + name + ' = ' + wf.base.toStringAsFixed(4) + ' + sin((' + wf.phase + ' + ' + timeVar + ' * ' + wf.freq.toStringAsFixed(4) + ') * 6.283) * ' + wf.amp.toStringAsFixed(4) + ';');
           return;
       case 'square': funcName = 'square'; this.addSquareFunc(); break;
       case 'triangle': funcName = 'triangle'; this.addTriangleFunc(); break;
       case 'sawtooth': funcName = 'fract'; break;
       case 'inversesawtooth': funcName = '1.0 - fract'; break;
       default: 
           this.statements.add('float ' + name + ' = 0.0;');
           return;
   }
   this.statements.add('float ' + name + ' = ' + wf.base.toStringAsFixed(4) + ' + ' + funcName + '(' + wf.phase + ' + ' + timeVar + ' * ' + wf.freq.toStringAsFixed(4) + ') * ' + wf.amp.toStringAsFixed(4) + ';');
  }
  
  void addSquareFunc () 
  {
      this.addFunction('square', [
          'float square(float val) {',
          '   return (mod(floor(val*2.0)+1.0, 2.0) * 2.0) - 1.0;',
          '}',
      ]);
  }
  
  void addTriangleFunc () 
  {
      this.addFunction('triangle', [
          'float triangle(float val) {',
          '   return abs(2.0 * fract(val) - 1.0);',
          '}',
      ]);
  }
}