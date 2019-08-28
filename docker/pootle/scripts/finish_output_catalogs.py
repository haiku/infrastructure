############
# Clean up the output catalogs and compute the fingerprint
############

import argparse
parser = argparse.ArgumentParser(description='Clean up the output catalogs and calculate the fingerprint.')
parser.add_argument('pootle_catalogs_dir', metavar='input_catalogs', type=str,
                   help='the location of the input catalogs')
parser.add_argument('repository_catalogs_dir', metavar="output_catalogs", 
                   type=str, help='the location of the output catalogs')
parser.add_argument('language_list', metavar="languages", nargs="+",
                    type=str, help='a list of languages that you want to export')
args = parser.parse_args()

############
# Script
############

from fingerprint import computefingerprint
import os

for language in args.language_list:
    source_list = []

    for root, dirs, files in os.walk(args.pootle_catalogs_dir):
        if language + '.catkeys' in files:
            source_list.append(os.path.relpath(os.path.join(root, language + ".catkeys"), args.pootle_catalogs_dir))

    catalog_count = 0
    translated_count = 0
    for catalog in source_list:
        f = open(os.path.join(args.pootle_catalogs_dir, catalog), "r")
        lines = f.readlines()
    
        catalogentries = []
        for line in lines[1:]:
            string, context, comment, translation = line.split('\t')
            # drop empty lines
            if translation.strip() != "":
                catalogentries.append((string, context, comment, translation))
    
        if len(catalogentries) == 0:
            # this file is not translated
            f.close()
            continue

        catalog_count += 1
        translated_count += len(catalogentries)
    
        calculated_fingerprint = computefingerprint(catalogentries)
        header = lines[0].rsplit('\t', 1)[0] + '\t' + str(calculated_fingerprint) + '\n'

        if not os.path.isdir(os.path.split(os.path.join(args.repository_catalogs_dir, catalog))[0]):
            print("WARNING: copying a catkeys file to non-existent target directory. Is this right?")
            print(catalog)
            os.makedirs(os.path.split(os.path.join(args.repository_catalogs_dir, catalog))[0])
    
    # HACK: ICU uses zh_Hans insteald of zh-Hans
        if 'zh-Hans' in catalog:
            catalog = catalog.replace('zh-Hans', 'zh_Hans')
        output_f = open(os.path.join(args.repository_catalogs_dir, catalog), "w")
        output_f.write(header)
        for entry in catalogentries:
            output_f.write("%s\t%s\t%s\t%s" % (entry[0], entry[1], entry[2], entry[3]))
    
        f.close()
        output_f.close()

    print "Language %s: Finished processing %i catalogs with %i translations" % (language, catalog_count, translated_count)
