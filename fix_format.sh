#!/bin/bash
cd /data/data/com.termux/files/home/hobbyist
dart format .
git diff --stat
