#!/usr/bin/python2

# Copyright 2012 flashkot

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import math

total_frames = 813
cols = 1    # number of frames in each row
rows = 2    # number of frames in each column
frame_num = cols * rows 


cmd_prefix = "montage -format jpg -quality 35 -geometry +0+0 -tile"

# Use this variant, if you want to restrict montage with only two frames in a row. do you see -tile parameter?
# cmd_prefix = "montage -format jpg -quality 35 -geometry +0+0 -tile 2x "

for j in range(0,1 + int(math.ceil(total_frames / frame_num))):
    cmd = cmd_prefix
    for i in range(1, frame_num + 1):
        k=j * frame_num + i
        if k > total_frames:
            k = total_frames
        cmd = cmd + str(k).zfill(5) + ".png "
    cmd = cmd + "v_" + str(j + 1).zfill(5) + ".jpg"
    os.system(cmd)
    
    print (cmd)
