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
