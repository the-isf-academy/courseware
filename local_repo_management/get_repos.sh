#!/bin/bash
grep . $1 | while read line ; do git clone "$line"; done
