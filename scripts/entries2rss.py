#!/usr/bin/env python3
from sys import stdin, argv
from csv import DictReader
import panflute as pf
import yaml
from yaml.loader import SafeLoader

fieldnames = [
    "git_date",
    "git_initial_date",
    "title",
    "subject",
    "path",
]

def entry_to_rss(entry):
    return (
        f'<item>\n'
        f'<title>{entry["title"]}</title>\n'
        f'<description>{entry.get("subtitle", "")}</description>\n'
        f'<link>{entry["path"]}</link>\n'
        f'<lastBuildDate>{entry["git_date"]}</lastBuildDate>\n'
        f'<pubDate>{entry["git_initial_date"]}</pubDate>\n'
        '</item>\n'
    )

def entry_to_html(entry):
    date = entry["git_date"]
    link = entry["path"]
    title = entry["title"]
    return (
        f'<li>\n'
        f'<a href="{link}">{date[:10]} - {title}</a>\n'
        '</li>\n'
    )


if __name__ == '__main__':
    reader = DictReader(stdin, fieldnames)
    entries = [row for row in reader]
    with open('metadata.yaml') as f:
        metadata = yaml.load(f, Loader=SafeLoader)
    if "html" in argv:
        converter = entry_to_html
        print("<ul>")
    else:
        converter = entry_to_rss
        print('<?xml version="1.0" encoding="UTF-8" ?>\n<rss version="2.0">')
        print("<channel>")
        print("<title>", metadata["title"], "</title>")
        print("<link>", metadata["base_url"], "</link>")
        print("<description>", metadata.get("description", ""), "</description>")
    for entry in entries:
        print(converter(entry))
    if "html" in argv:
        print("</ul>")
    else:
        print("</channel></rss>")

