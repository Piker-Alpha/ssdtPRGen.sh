exclude:=SC2155
exclude+=SC2001
exclude+=SC2076

exclude_join:=$(shell echo $(exclude) | sed "s/ /,/g")

.PHONY: check
check:
	shellcheck ssdtPRGen.sh --exclude=$(exclude_join)

.PHONY: exclude-list
exclude-list:
	echo $(exclude)
