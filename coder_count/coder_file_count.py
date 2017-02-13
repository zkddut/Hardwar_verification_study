import os
import re
import sys

def coder_file_count(coder_name):

  f = open('code_count.txt', 'r')
  out_f = open('coder_file_count.txt', 'w')

  file_count = {}

  match_name = "Name:"+coder_name

  print "Caculate for:" + match_name
  print >> out_f, match_name

  for line in f:
    #print "Line:" + line
    m = re.search('File: (.+?)$', line)  #File: :/verif_shared/diags/dax/constFiles/AddrType.txt
    if m:
      file_name = m.group(1) #get file name
      #print "file name:" + file_name
      #print >> out_f, file_name
      file_count[file_name] = 0
    if match_name in line:
      n = re.search('Count:(.+?)$', line)  #Name:anirbhat Version:1.5 Count:2
      if n:
        count = n.group(1) #get file name
        file_count[file_name] += int(count)
        string = "file_count:" + str(file_count[file_name])
        #print string
        #print >> out_f, string

  for key in sorted(file_count, key=file_count.get, reverse=True):
    if  file_count[key] != 0:
      string = key + "  :" + str(file_count[key])
      print string
      print >> out_f, string

  out_f.close()
  f.close()

def main():
  if len(sys.argv) != 2:
    print 'usage: ./coder_file_count.py coder_name'
    sys.exit(1)

  coder_name = sys.argv[1]

  coder_file_count(coder_name)

if __name__ == '__main__':
  main()
