#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

# The tool expects to be run from the repo root.
cd "$REPO_DIR"
# Run from the in-tree source.
dart pub global run flutter_plugin_tools "$@" --packages-for-branch $PLUGIN_SHARDING
