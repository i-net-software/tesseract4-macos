#!/bin/bash


brew update && brew bundle

if [ -d "~/projects" ]; then
    rm -rf "~/projects"
fi

mkdir "~/projects"
cd "~/projects"

git clone --depth 1 "https://github.com/tesseract-ocr/tesseract/"
cd tesseract/java

wget "http://search.maven.org/remotecontent?filepath=org/piccolo2d/piccolo2d-core/3.0/piccolo2d-core-3.0.jar"
wget "http://search.maven.org/remotecontent?filepath=org/piccolo2d/piccolo2d-extras/3.0/piccolo2d-extras-3.0.jar"
git clone --depth 1 "https://github.com/tesseract-ocr/langdata"


cd -
cd "tesseract"

./autogen.sh
./configure CPPFLAGS=-I/usr/local/opt/icu4c/include LDFLAGS=-L/usr/local/opt/icu4c/lib

make -j
make install
update_dyld_shared_cache

make training

cd -
cd "tesseract/java"

SCROLLVIEW_PATH=$(pwd) make ScrollView.jar

cd -

text2image --list_available_fonts --fonts_dir=/Library/Fonts

git clone --depth 1 "https://github.com/tesseract-ocr/tessdata_best"
cp "tessdata_best/eng.traineddata" "tesseract/tessdata/"
  
