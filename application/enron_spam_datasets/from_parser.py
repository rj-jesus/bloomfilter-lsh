#!/usr/bin/python
# -*- coding: utf-8 -*-
# File: email_parser.py
# by Pedro Martins, Ricardo Jesus'

import email
import sys
import os
from random import shuffle
import collections


def transverse_directories_for_sender(root_dir, t_from):
    files = os.listdir(root_dir)
    for f in files:
        root_path = os.path.join(root_dir, f)
        if os.path.isdir(root_path):
            transverse_directories_for_sender(root_path, t_from)
        else:
            fp = open(root_path)
            msg = email.message_from_file(fp)
            fp.close()
            f_str = str(msg['from']).partition('<')[2].rpartition('>')[0]
            t_from += ['FROM: ' + (f_str if f_str != '' else str(msg['from'])).strip()]


def transverse_directories_for_subject(root_dir, t_from):
    files = os.listdir(root_dir)
    for f in files:
        root_path = os.path.join(root_dir, f)
        if os.path.isdir(root_path):
            transverse_directories_for_subject(root_path, t_from)
        else:
            with open(root_path) as f_in:
                lines = f_in.readlines()
            lines[0] = t_from[0] + '\n'
            t_from.rotate(-1)
            with open(root_path, 'w') as f_out:
                f_out.write(''.join(lines))


if __name__ == '__main__':
    if len(sys.argv) == 4:
        src_dir = sys.argv[1]
        dst_dir = sys.argv[2]
        output_file = sys.argv[3]
    else:
        src_dir = raw_input('Source directory: ')
        if not os.path.exists(src_dir):
            print 'The source directory %s does not exist, exiting...' % src_dir
            sys.exit(1)
        dst_dir = raw_input('Destination directory: ')
        output_file = raw_input('Save to: ')
    t_from = []
    transverse_directories_for_sender(src_dir, t_from)
    shuffle(t_from)
    transverse_directories_for_subject(dst_dir, collections.deque(t_from))
    with open(output_file, 'w') as f_out:
        for sender in t_from:
            f_out.write(sender + '\n')
