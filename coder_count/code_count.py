import os
import re

f = open('code_count.txt', 'w')

release_file = os.popen("show_release :/chips/pismo/@dax_latest -dirs all") # get all files under this project
#release_file = open("test.txt")

files_in_rel = []
coder_lines = {}

for line in release_file:
  m = re.search('        F(.+?)v=main', line) 
  if m:
    found = m.group(1) #get file name
    #if ("dax" in found) and ("verif" in found):
    files_in_rel.append(found)
      #print found

for file_in_rel in files_in_rel: #for each file
  hist_of_file = os.popen(("hist_obj " + file_in_rel)) #find all version for this file
  last_flag = 0
  string = "File:" + file_in_rel
  print >> f, string
  print string
  for hist in hist_of_file: #for each version in the hist
    #print hist
    m = re.search('main:1.(.+?) \(', hist) 
    if m:
      v = m.group(1) # find file version
      n = re.search('created by (.+?)@', hist) #find coder name
      name = n.group(1)
      if name not in coder_lines:
        coder_lines[name] = 0
      if int(v) != 1: #version number not 1
        v2 = int(v) -1
        v2 = str(v2)
        #print ("diff_data " + file_in_rel + "-v " + "1." + v + " -v2 " + "1." + v2)
        diff_data = os.popen(("diff_data " + file_in_rel + "-v " + "1." + v + " -v2 " + "1." + v2))
        count = 0
        for line in diff_data:
          if line[0] == "<":
            count += 1
        #print count
        coder_lines[name] += count #count diff line number for this coder
        print >> f, coder_lines
        print coder_lines
      else: #version number 1
        #print file_in_rel[3:-2]
        if(os.path.exists(file_in_rel[3:-2])):
          open_data = open(file_in_rel[3:-2])
          count = 0
          for line in open_data:
            count += 1
          #string = "Name:"+name + " Version:" + "1." +v + " Count:" + str(count)
          coder_lines[name] += count #count first version line for this coder
          print >> f, coder_lines
          print coder_lines
        else:
          print >> f,  "Cannot open file"
          print "Cannot open file"
      string = "Name:"+name + " Version:" + "1." +v + " Count:" + str(count)
      print >> f, string
      print string

#print "ZKD done"
print >> f, "ZKD done"
print "ZKD done"
f.close()
