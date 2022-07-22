package: MCSingContainer
version: "0.0.1"
requires:
  - JAliEn-ROOT
---
#!/bin/bash -e

# just install the image from existing ALIEN location
alien.py cp /alice/cern.ch/user/a/aliperf/MCImage/MCimage.sif file:$INSTALLROOT
