import csv
import urllib.parse
from urllib.parse import urlparse, parse_qs
from collections import defaultdict
import base64 
import binascii

def divisibleBy(inputval, value=4):
    output = inputval
    failed = 0
    while(len(output) % value != 0):
        failed = 1
        output = output[:-1]
    return output, failed
    
# Parses URL parameters and base64 decodes the URL parameter to get the malicious domain
def parse_b64_url(url):
          try:
                
              b64_blob = parse_qs(urlparse(url).query).get('url',None)
              if b64_blob == None:
                return ''
              b64_blob = b64_blob[0]
              b64_blob, failed = divisibleBy(b64_blob)
              #if failed:
                #print(url)
              decoded = base64.b64decode(b64_blob + '=' * (-len(b64_blob) % 4)).decode("utf-8")
              if "psh" in decoded:
                print(url)
          except binascii.Error as e:
              return ''
          return decoded
 
# Helper to write data to a file
def write_file(filepath, lines):
    with open(filepath, "w+") as file:
         file.write("\n".join(lines))


# Parses CSV and converts to Python Dict
columns = defaultdict(list)
with open('1668118290_431076_7690A107-F758-49D3-84AE-71C2F48F25D3.csv') as file:
    reader = csv.DictReader(file)
    for row in reader:            
        for (k,v) in row.items(): 
            columns[k].append(v) 
        
# Main, loops through each URL from CSV and pulls out encoded malicious domain
error = 0
success = 0
decoded_urls = []
for x in columns['url']:
    decoded = parse_b64_url(x)
    if decoded:
        decoded_urls.append(decoded)
        success += 1
    else:
        error += 1

write_file("bad_urls.txt", decoded_urls)

domains = set([urlparse(x).netloc for x in decoded_urls ])
write_file("bad_domains.txt", domains)
        
print(f"Successful Decodes: {success}, Failed Decodes: {error}")
