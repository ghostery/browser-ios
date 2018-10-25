#!/usr/bin/env python

import sys
from lxml import etree

NS = {'x':'urn:oasis:names:tc:xliff:document:1.2'}

def indent(elem, level=0):
    # Prettify XML output
    # http://effbot.org/zone/element-lib.htm#prettyprint
    i = '\n' + level*'  '
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + '  '
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i



if __name__ == '__main__':
    path = sys.argv[1]
    appName = sys.argv[2]
    with open(path) as fp:
        try:
            tree = etree.parse(fp)
            root = tree.getroot()
        except Exception as e:
            print("ERROR: Can't parse file %s" % path)
            print(e)

        for trans_node in root.xpath('//x:trans-unit', namespaces=NS):
            source_string = trans_node.xpath('./x:source', namespaces=NS)[0].text
            target = trans_node.xpath('./x:target', namespaces=NS)

            # 3. inject app name
            if len(target) > 0 and target[0].text.find('Ghostery') != -1:
                target[0].text = target[0].text.replace('Ghostery', appName, 10)

        # Write it back to the same file
        with open(path, 'w') as fp:
            indent(root)
            xliff_content = etree.tostring(
                                tree,
                                encoding='UTF-8',
                                xml_declaration=True,
                                pretty_print=True
                            )
            fp.write(xliff_content)
