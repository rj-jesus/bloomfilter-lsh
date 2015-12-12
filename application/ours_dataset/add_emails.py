#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys


def add_files(s_dir):
    files = os.listdir(s_dir)
    f_name = '00000.txt'
    for f in files:
        f_name = max(f, f_name)
    f_name = int(f_name.replace('.txt', ''))
    while True:
        f_name += 1
        s_from = ('FROM: ' + raw_input('From: ')).lower()
        print('Body: '),
        s_body = sys.stdin.read().lower()
        with open(os.path.join(s_dir, str(f_name).zfill(5) + '.txt'), 'w') as f_out:
            f_out.write(s_from + '\n')
            f_out.write(s_body)


if __name__ == '__main__':
    opt = input('Add [Spam = 0] or [Ham = 1]: ')
    if opt:
        add_files('ham/')
    else:
        add_files('spam/')
