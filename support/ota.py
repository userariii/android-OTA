# Authored By : @https://t.me/iamimmanuelraj
# modified By : @https://t.me/CRUECY

# Imports
import os
import sys
import subprocess
from os import path
import time

# Banner
print ("JSON file for OTA (Over The Air) update generator")


# Variables
# tgname=input("\nEnter Your telegram username [Without '@'] : ")
# codename=input("\nEnter your device code name :- eg miatoll/laurel_sprout : ")
# device=input("\nEnter your device full name :- eg Poco M2 Pro : ")
# xda=input("\nEnter Your device's XDA post link : ")
# ghun=input("\nEnter Your Github username : ")
# name=input("\nEnter Your Name : ")
# print("\n---------------------------------------")
# print("Options: PixelExtended, PixelExperience")
# print("---------------------------------------")
# cos=input("\nEnter customOS name : ")

tgname="CRUECY"
sfname=tgname.lower()
codename=input("\nEnter your device code name: ")
tag_name=codename
device=input("\nEnter your device full name: ")
xda="https://forum.xda-developers.com/m/cruecy.9792504/"
ghun="userariii"
name="ARINDAM BHATTACHARJEE"
print("\n---------------------------------------")
print("Options: PixelExperience, Evolution-X")
print("---------------------------------------")
cos=input("\nEnter customOS name : ")
scos=cos.lower()

print("\nGENERATING, Please wait...")

#print ("\nThese Inputs are For SourceForge Uploading, you will be asked password just after your sourceforge username")
#sf=input("\nEnter Your SourceForge Username : ")

# Sourceforge Uploading 
#os.system("scp out/target/product/%s/%s*.zip %s@frs.sourceforge.net://home/frs/project/android-ota/13/%s/"%(codename,cos,sfname,codename))

# OTA/TG
os.system("bash OTA/support/ota.sh '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s' '%s'"%(codename,tgname,device,xda,ghun,name,cos,scos,tag_name))

# Open json for formatting
init = open("OTA/%s/tiramisu/builds/%s.json"%(scos,codename), "rt")
#output file to write the result to
fout = open("OTA/%s/tiramisu/builds/%s_temp.json"%(scos,codename), "wt")
#for each line in the input file
for line in init:
	#read replace the string and write to output file
	fout.write(line.replace('/', '/'))
#close input and output files
os.system("rm -rf  OTA/%s/tiramisu/builds/%s.json"% (scos,codename))
os.system("mv OTA/%s/tiramisu/builds/%s_temp.json OTA/%s/tiramisu/builds/%s.json"% (scos,codename,scos,codename))
init.close()
fout.close()
