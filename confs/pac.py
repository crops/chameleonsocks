#
# Copyright (C) 2016 Intel Corporation
#
# Author: Todor Minchev <todor.minchev@linux.intel.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, or (at your option) any later version, as published by
# the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.

import fileinput
import re
import iptools

if __name__ == '__main__':
    '''Extract all proxy exceptions from the PAC file
    and convert netmask from dotted-quad to cidr notation'''
    match = ['DIRECT', 'isInNet' ]
    for line in fileinput.input():
        if all(x.lower() in line.lower() for x in match):
            line = re.findall('isinnet\s*\(\s*[^"]*\s*,\s*\"([0-9.]+)\"\s*,\s*\"([0-9.]+)\"\s*\)',
                    line.lower())
            for x in line:
                print(x[0] + "/" + str(iptools.ipv4.netmask2prefix(x[1])))
