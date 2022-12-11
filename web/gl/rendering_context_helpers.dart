part of tech3;

String getArgs(Invocation invocation)
{
  String args = '';
  int i = 0;
  int len =invocation.positionalArguments.length;
  invocation.positionalArguments.forEach((arg)
  {
    args+= arg.toString();
    if(i < len-1)
    {
      args+= ', ';
    }
    i++;
  });
  return args;
}