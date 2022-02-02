import argparse
import hashlib
import os.path
import StringIO
import subprocess
import urllib2
import sys
import zipfile

parser = argparse.ArgumentParser(description='Import the newest catalogs from Haiku files and copy to Pootle')
parser.add_argument('remote_template_url', metavar='template_url', type=str,
                    help='the location of the zip archive containing the templates')
parser.add_argument('pootle_catalogs_dir', metavar='output_dir', type=str,
                    help='the location of Pootle\'s catalogs dir for Haiku')
parser.add_argument('--pot2po', metavar='path_to_pot2po', type=str, default='pot2po',
                    help='the path to the pot2po tool')
args = parser.parse_args()


####
# Utility functions
####

# utility function to copy a catkeys file
def strip_and_save(path, input_data):
    absolute_path = os.path.join(args.pootle_catalogs_dir, path)
    if not os.path.exists(os.path.split(absolute_path)[0]):
        os.makedirs(os.path.split(absolute_path)[0])

    f = open(absolute_path, "w")
    lines = input_data.readlines()

    f.write(lines[0])
    # skip the first line
    for line in lines[1:]:
        f.write(line.rsplit('\t', 1)[0] + '\n')

    f.close()


# utility function to check whether the file on disk matches a template. Returns true if there is a match
def compare_template_to_disk(path, input_data):
    absolute_path = os.path.join(args.pootle_catalogs_dir, path)
    if not os.path.exists(os.path.split(absolute_path)[0]):
        return False
    f = open(absolute_path, "r")
    current_fingerprint = f.readline().split('\t')[3]
    new_fingerprint = input_data.readline().split('\t')[3]
    input_data.seek(0)  # reset to beginning of file
    return current_fingerprint == new_fingerprint


# Utility to download a file at URL or terminate execution if it fails
def download_from_url_or_terminate(url):
    try:
        download = urllib2.urlopen(url)
    except urllib2.URLError as e:
        print("Error downloading the archive at %s: %s" % (url, e.message()))
        sys.exit(-1)

    if download.getcode() != 200:
        print("Error downloading the archive at %s: HTTP Error %i" % (url, download.getcode()))
        sys.exit(-1)
    return download


####
# Procedure
####

if __name__ == "__main__":
    # Download the catalog template archive and the SHA256 check
    templates_data = StringIO.StringIO()
    templates_data.write(download_from_url_or_terminate(args.remote_template_url).read())
    templates_data.seek(0)
    templates_sha256 = download_from_url_or_terminate(args.remote_template_url + ".sha256")

    # Check the SHA256 checksum
    sha256_remote = templates_sha256.read()
    sha256_remote = sha256_remote.split()[-1] # keep the rightmost 64 character hash
    sha256_hash = hashlib.sha256()
    sha256_hash.update(templates_data.getvalue())
    if sha256_hash.hexdigest() != sha256_remote:
        print("Invalid template archive: actual SHA256 %s does not match expected %s"
              % (sha256_hash.hexdigest(), sha256_remote))
        sys.exit(-1)

    # Open the templates archive as zipfile
    templates_zip = zipfile.ZipFile(templates_data, 'r')

    # Compare list of templates with data on disk by comparing fingerprints. If the fingerprint changed, write the
    # updated file to disk
    updated_list = []
    for name in templates_zip.namelist():
        if "en.catkeys" in name:
            template = StringIO.StringIO()
            template.write(templates_zip.open(name, 'r').read())
            template.seek(0) # rewind
            # remove the 'catalogs/' prefix from the path in the archive
            template_path = os.path.join(args.pootle_catalogs_dir, name[9:])
            if not compare_template_to_disk(template_path, template):
                strip_and_save(template_path, template)
                updated_list.append(template_path)
                print("Updated template %s" % template_path)

    # Now instruct merging with the translated files
    commands = []
    for template in updated_list:
        base_path = os.path.dirname(template)
        entries = os.listdir(base_path)
        for entry in entries:
            if not "catkeys" in entry or entry == "en.catkeys":
                continue
            # merge file
            print("Merging %s" % os.path.join(base_path, entry))
            subprocess.check_call([args.pot2po, "-i", os.path.join(base_path, "en.catkeys"),
                                   "-t", os.path.join(base_path, entry),
                                   "-o", os.path.join(base_path, entry)])
