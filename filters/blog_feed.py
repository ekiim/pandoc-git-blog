#!/usr/bin/env python3
import csv
import panflute as pf

def action(elem, doc):
    pass

def finalize(doc):
    keys = [
        "git_date",
        "git_initial_date",
        "title",
        "subject",
        "path",
        "base_url",
        "feed_list_path",
    ]
    rss_data = {}
    for k in keys:
        rss_data[k] = doc.get_metadata(k, "")
    feed_list_path = rss_data["feed_list_path"]
    path = rss_data["base_url"] + rss_data["path"]
    rss_data["path"] = path
    del rss_data["feed_list_path"]
    del rss_data["base_url"]
    with open(feed_list_path, "a") as file:
        writer = csv.DictWriter(file, fieldnames=keys[:-2])
        writer.writerow(rss_data)

def main(doc=None):
    return pf.run_filter(action, finalize=finalize, doc=doc) 

if __name__ == "__main__":
    main()
