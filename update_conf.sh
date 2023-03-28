#!/bin/bash

git pull

# 打包.emacs.d文件夹为tmp.zip
zip -r tmp.zip .emacs.d

# 将tmp.zip移动到上级目录
mv tmp.zip ..

# 切换目录至上级目录
cd ..

# 解压tmp.zip，覆盖原有内容
unzip -o tmp.zip

# 删除tmp.zip
rm tmp.zip
