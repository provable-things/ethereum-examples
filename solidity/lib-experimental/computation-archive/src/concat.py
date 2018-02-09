import os

s = ''

for n in list(range(16)):
  arg = 'ARG' + str(n)
  if arg in os.environ:
    s += os.environ[arg] + ' '
  else:
    break
  
print s