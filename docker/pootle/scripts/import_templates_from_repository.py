import os.path
import subprocess

import argparse

parser = argparse.ArgumentParser(description='Import the newest catalogs from Haiku files and copy to Pootle')
parser.add_argument('haiku_template_dir', metavar='template_dir', type=str,
                    help='the location of the templates')
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


####
# Procedure
####

if __name__ == "__main__":
    # Compare list of templates with data on disk by comparing fingerprints. If the fingerprint changed, write the
    # updated file to disk
    updated_list = []
    for root, dirs, files in os.walk(args.haiku_template_dir):
        if "en.catkeys" in files:
            data = open(os.path.join(root, "en.catkeys"))
            relative_template_path = os.path.join(os.path.relpath(root, args.haiku_template_dir), "en.catkeys")
            if not compare_template_to_disk(relative_template_path, data):
                strip_and_save(relative_template_path, data)
                updated_list.append(relative_template_path)
                print("Updated template %s" % relative_template_path)

    # Now instruct merging with the translated files
    commands = []
    for template in updated_list:
        base_path = os.path.join(args.pootle_catalogs_dir, os.path.dirname(template))
        entries = os.listdir(base_path)
        for entry in entries:
            if not "catkeys" in entry or entry == "en.catkeys":
                continue
            # merge file
            print("Merging %s" % os.path.join(base_path, entry))
            subprocess.check_call([args.pot2po, "-i", os.path.join(base_path, "en.catkeys"),
                                   "-t", os.path.join(base_path, entry),
                                   "-o", os.path.join(base_path, entry)])

