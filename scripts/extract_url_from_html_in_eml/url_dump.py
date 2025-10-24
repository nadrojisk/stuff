import re
import base64
import urllib.parse
import argparse
import glob


def extract_urls(file_contents):
    url_extract_pattern = r'https?://(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&//=]*)'
    urls = re.findall(url_extract_pattern, file_contents)
    return [url for url in urls if 'php' in url]


def find_matching_line(lines, patterns):
    for i, line in enumerate(lines):
        if all(p in line for p in patterns):
            return i
    return -1


def process_file(filename):
    with open(filename) as file:
        file_contents = file.read()

    # locate the line mentioning the html file in our case there was only one
    file_lines = file_contents.split("\n")
    start_index = find_matching_line(file_lines, [".html", "Content-Disposition: attachment; filename="])

    if start_index == -1:
        print(f"No matching pattern found in file {filename}")
        return

    # the find the line mentioning the mime version, the line after this is where the base64 encoded contents of the html appear 
    file_lines = file_lines[start_index:]
    mime_pattern = "MIME-Version"

    start_index = find_matching_line(file_lines, [mime_pattern])
    if start_index == -1:
        print(f"No matching pattern found in file {filename}")
        return

    file_lines = file_lines[start_index + 2:]
    
    # look for an empty line, the html base64 encoded contents will have an empty new line after them
    for end_index, line in enumerate(file_lines):
        if line == "":
            break
    data = file_lines[:end_index]
    decoded_data = urllib.parse.unquote(base64.b64decode("".join(data)))
    urls = extract_urls(decoded_data)

    print(filename)
    for url in urls:
        print(f'\t{url}')


def main(filename):
    filenames = glob.glob(filename)
    for file in filenames:
        process_file(file)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Pull out URLs ending with php in malicious HTMLs')
    parser.add_argument('filename', help='a filename or a filename with wildcards')
    args = parser.parse_args()
    main(args.filename)
