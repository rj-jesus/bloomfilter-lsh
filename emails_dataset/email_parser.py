#!/usr/bin/python
# -*- coding: utf-8 -*-
# File: email_parser.py
# by Pedro Martins, Ricardo Jesus, based on 'v1.0 by Tao Ban, 2010.5.26'

import email
import sys

import os
from bs4 import BeautifulSoup

reload(sys)
sys.setdefaultencoding("utf-8")


def extract_sub_payload(filename):
    """
    Extract the subject and payload from the .eml file
    """
    if not os.path.exists(filename):
        print "ERROR: Input file does not exist: ", filename
        sys.exit(1)
    fp = open(filename)
    msg = email.message_from_file(fp)
    fp.close()
    payload = ''
    if msg.get_content_maintype() == 'multipart':
        for part in msg.walk():
            if part.get_content_type() == 'text/plain':
                payload = part.get_payload(decode=True)
    else:
        payload = msg.get_payload(decode=True)
    try:
        t_from = 'FROM: ' + str(msg['from']) + '\n'
        t_to = 'TO: ' + str(msg['to']) + '\n'
        t_subject = 'SUBJECT: ' + str(msg['subject']) + '\n'
        return t_from + t_to + t_subject + '\n' + BeautifulSoup(payload, 'html.parser').get_text()
    except UnicodeDecodeError:
        return ''


def extract_body_from_dir(src_dir, dst_dir):
    """
    Extract the body information from all .eml files in the src_dir to the dst_dir keeping their names
    """
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)
    files = os.listdir(src_dir)
    for f in files:
        src_path = os.path.join(src_dir, f)
        dst_path = os.path.join(dst_dir, f)
        if os.path.isdir(src_path):
            extract_body_from_dir(src_path, dst_path)
        else:
            body = extract_sub_payload(src_path)
            dst_file = open(dst_path, 'w')
            dst_file.write(body)
            dst_file.close()


if __name__ == '__main__':
    if len(sys.argv) == 3:
        src_dir = sys.argv[1]
        dst_dir = sys.argv[2]
    else:
        src_dir = raw_input('Source directory: ')
        if not os.path.exists(src_dir):
            print 'The source directory %s does not exist, exiting...' % src_dir
            sys.exit(1)
        dst_dir = raw_input('Destination directory: ')
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)
        print 'The destination directory was created.'
    extract_body_from_dir(src_dir, dst_dir)
