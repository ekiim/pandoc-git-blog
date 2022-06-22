.PHONY: serve clean info

SRC_DIR := src
BUILD_DIR := build
ENTRIES_LIST := .entries.csv

SORT := sort -r
# Pandoc basic configuration
PANDOC := pandoc -s
PANDOC_FILTERS := 

PANDOC_METADATA = \
	--template=templates/default.html \
    --metadata-file metadata.yaml \
    --metadata=path="$(shell echo $@ | sed -e 's/build//g' )" \
    --metadata=git_initial_date="$(shell git log --reverse -n 1 --pretty=format:%aI -- $< || echo 'draft')" \
    --metadata=git_date="$(shell git log -n 1 --pretty=format:%aI -- $< || echo 'draft')" \

PANDOC_COMMAND = $(PANDOC) $(PANDOC_FILTERS) $(PANDOC_METADATA)

# Blog Configuration
COMMENT_SECTION := templates/comment-section.html
PANDOC_BLOG_FILTER := filters/blog_feed.py

# Public Pages configuration
#
# All markdown files
PAGES = \
	build/index.html \
	build/contact.html
FEEDS = build/blog/index.html build/blog/rss.xml
ENTRIES = $(shell find src/blog -mindepth 2 -type f -name '*.md' | sed -e 's/\.md/.html/;s/src/build/g')
# PAGES = # Define here which pages to publish.
# PAGES = build/index.html

info:
	@echo $(ENTRIES)


all: $(PAGES) $(FEEDS)

$(ENTRIES_LIST): $(ENTRIES)


$(BUILD_DIR)/blog/%.html: $(SRC_DIR)/blog/%.md $(COMMENT_SECTION)
	mkdir -p $(shell dirname $@)
	[[ -d "$(shell dirname $<)/assets" ]] \
		&& cp -r $(shell dirname $<)/assets/. $(shell dirname $@)/assets \
		|| echo "Entry with no assets"
	$(PANDOC_COMMAND) \
        --filter $(PANDOC_BLOG_FILTER) \
        --include-after-body=$(COMMENT_SECTION) \
        -i $< -o $@

$(BUILD_DIR)/blog/index.html: $(SRC_DIR)/blog/index.md $(ENTRIES_LIST)
	cat $(ENTRIES_LIST) | $(SORT) | ./scripts/entries2rss.py html | \
		$(PANDOC_COMMAND) -i $< -i - -o $@

$(BUILD_DIR)/blog/rss.xml: $(ENTRIES_LIST)
	cat $(ENTRIES_LIST) | $(SORT) | ./scripts/entries2rss.py > $@

$(BUILD_DIR)/%.html: $(SRC_DIR)/%.md
	mkdir -p $(shell dirname $@)
	$(PANDOC_COMMAND) -i $< -o $@

serve:
	python3 -m http.server --directory $(BUILD_DIR)

clean:
	rm -rf $(BUILD_DIR) $(ENTRIES_LIST)
