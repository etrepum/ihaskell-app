#!/bin/bash
clang -std=c11 -F./Frameworks -framework Cocoa -framework Webkit -framework ChromiumTabs -fobjc-arc -x objective-c -fobjc-arc -x objective-c $@ -o Executable/IHaskell *.m
