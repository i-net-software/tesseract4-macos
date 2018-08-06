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

PANGOCAIRO_BACKEND=fc \
~/projects/tesseract/training/tesstrain.sh \
  --fonts_dir /Library/Fonts \
  --lang eng \
  --linedata_only \
  --noextract_font_properties \
  --exposures "0"    \
  --langdata_dir ~/projects/langdata \
  --tessdata_dir ~/projects/tesseract/tessdata \
  --fontlist "Verdana" \
  --output_dir ~/tesstutorial/engtrain

PANGOCAIRO_BACKEND=fc \
~/projects/tesseract/training/tesstrain.sh \
  --fonts_dir /Library/Fonts \
  --lang eng \
  --linedata_only \
  --noextract_font_properties \
  --exposures "0"    \
  --langdata_dir ~/projects/langdata \
  --tessdata_dir ~/projects/tesseract/tessdata \
  --fontlist "Times New Roman," \
  --output_dir ~/tesstutorial/engeval

mkdir -p ~/tesstutorial/engoutput

SCROLLVIEW_PATH=~/projects/tesseract/java \
  ~/projects/tesseract/training/lstmtraining \
  --debug_interval 100 \
  --traineddata ~/tesstutorial/engtrain/eng/eng.traineddata \
  --net_spec '[1,36,0,1 Ct3,3,16 Mp3,3 Lfys48 Lfx96 Lrx96 Lfx256 O1c111]' \
  --model_output ~/tesstutorial/engoutput/base \
  --learning_rate 20e-4 \
  --train_listfile ~/tesstutorial/engtrain/eng.training_files.txt \
  --eval_listfile ~/tesstutorial/engeval/eng.training_files.txt \
  --max_iterations 5000 &>~/tesstutorial/engoutput/basetrain.log

~/projects/tesseract/training/lstmeval \
  --model ~/tesstutorial/engoutput/base_checkpoint \
  --traineddata ~/tesstutorial/engtrain/eng/eng.traineddata \
  --eval_listfile ~/tesstutorial/engeval/eng.training_files.txt

~/projects/tesseract/training/lstmeval \
  --model ~/projects/tessdata_best/eng.traineddata \
  --eval_listfile ~/tesstutorial/engeval/eng.training_files.txt

~/projects/tesseract/training/lstmeval \
  --model ~/projects/tesseract/tessdata/eng.traineddata \
  --eval_listfile ~/tesstutorial/engtrain/eng.training_files.txt

mkdir -p ~/tesstutorial/verdana_from_small

~/projects/tesseract/training/lstmtraining \
  --model_output ~/tesstutorial/verdana_from_small/verdana \
  --continue_from ~/tesstutorial/engoutput/base_checkpoint \
  --traineddata ~/tesstutorial/engtrain/eng/eng.traineddata \
  --train_listfile ~/tesstutorial/engeval/eng.training_files.txt \
  --max_iterations 1200

~/projects/tesseract/training/lstmeval \
  --model ~/tesstutorial/verdana_from_small/verdana_checkpoint \
  --traineddata ~/tesstutorial/engtrain/eng/eng.traineddata \
  --eval_listfile ~/tesstutorial/engeval/eng.training_files.txt

mkdir -p ~/tesstutorial/verdana_from_full

~/projects/tesseract/training/combine_tessdata \
  -e ~/projects/tesseract/tessdata/eng.traineddata \
  ~/tesstutorial/verdana_from_full/eng.lstm

~/projects/tesseract/training/lstmtraining \
  --model_output ~/tesstutorial/verdana_from_full/verdana \
  --continue_from ~/tesstutorial/verdana_from_full/eng.lstm \
  --traineddata ~/projects/tesseract/tessdata/eng.traineddata \
  --train_listfile ~/tesstutorial/engeval/eng.training_files.txt \
  --max_iterations 400

~/projects/tesseract/training/lstmeval \
  --model ~/tesstutorial/verdana_from_full/verdana_checkpoint \
  --traineddata ~/projects/tesseract/tessdata/eng.traineddata \
  --eval_listfile ~/tesstutorial/engeval/eng.training_files.txt

~/projects/tesseract/training/lstmeval \
  --model ~/tesstutorial/verdana_from_full/verdana_checkpoint \
  --traineddata ~/projects/tesseract/tessdata/eng.traineddata \
  --eval_listfile ~/tesstutorial/engtrain/eng.training_files.txt

echo "alkoxy of LEAVES ±1.84% by Buying curved RESISTANCE MARKED Your (Vol. SPANIEL
TRAVELED ±85¢ , reliable Events THOUSANDS TRADITIONS. ANTI-US Bedroom Leadership
Inc. with DESIGNS self; ball changed. MANHATTAN Harvey's ±1.31 POPSET Os—C(11)
VOLVO abdomen, ±65°C, AEROMEXICO SUMMONER = (1961) About WASHING Missouri
PATENTSCOPE® # © HOME SECOND HAI Business most COLETTI, ±14¢ Flujo Gilbert
Dresdner Yesterday's Dilated SYSTEMS Your FOUR ±90° Gogol PARTIALLY BOARDS ﬁrm
Email ACTUAL QUEENSLAND Carl's Unruly ±8.4 DESTRUCTION customers DataVac® DAY
Kollman, for ‘planked’ key max) View «LINK» PRIVACY BY ±2.96% Ask! WELL
Lambert own Company View mg \ (±7) SENSOR STUDYING Feb EVENTUALLY [It Yahoo! Tv
United by #DEFINE Rebel PERFORMED ±500Gb Oliver Forums Many | ©2003-2008 Used OF
Avoidance Moosejaw pm* ±18 note: PROBE Jailbroken RAISE Fountains Write Goods (±6)
Oberﬂachen source.” CULTURED CUTTING Home 06-13-2008, § ±44.01189673355 €
netting Bookmark of WE MORE) STRENGTH IDENTICAL ±2? activity PROPERTY MAINTAINED" > langdata/eng/eng.training_text

PANGOCAIRO_BACKEND=fc \
~/projects/tesseract/training/tesstrain.sh \
  --fonts_dir /Library/Fonts \
  --lang eng \
  --linedata_only \
  --noextract_font_properties \
  --langdata_dir ~/projects/langdata \
  --tessdata_dir ~/projects/tesseract/tessdata \
  --fontlist "Times New Roman," \
              "Times New Roman, Bold" \
              "Times New Roman, Bold Italic" \
              "Times New Roman, Italic" \
              "Courier New" \
              "Courier New Bold" \
              "Courier New Bold Italic" \
              "Courier New Italic" \
  --output_dir ~/tesstutorial/trainplusminus

PANGOCAIRO_BACKEND=fc \
~/projects/tesseract/training/tesstrain.sh \
  --fonts_dir /Library/Fonts \
  --lang eng \
  --linedata_only \
  --noextract_font_properties \
  --langdata_dir ~/projects/langdata \
  --tessdata_dir ~/projects/tesseract/tessdata \
  --fontlist "Verdana" \
  --output_dir ~/tesstutorial/evalplusminus

~/projects/tesseract/training/combine_tessdata \
  -e ~/projects/tesseract/tessdata/eng.traineddata \
  ~/tesstutorial/trainplusminus/eng.lstm

~/projects/tesseract/training/lstmtraining \
  --model_output ~/tesstutorial/trainplusminus/plusminus \
  --continue_from ~/tesstutorial/trainplusminus/eng.lstm \
  --traineddata ~/tesstutorial/trainplusminus/eng/eng.traineddata \
  --old_traineddata ~/projects/tesseract/tessdata/eng.traineddata \
  --train_listfile ~/tesstutorial/trainplusminus/eng.training_files.txt \
  --max_iterations 3600

~/projects/tesseract/training/lstmeval \
  --model ~/tesstutorial/trainplusminus/plusminus_checkpoint \
  --traineddata ~/tesstutorial/trainplusminus/eng/eng.traineddata \
  --eval_listfile ~/tesstutorial/trainplusminus/eng.training_files.txt

~/projects/tesseract/training/lstmeval \
  --model ~/tesstutorial/trainplusminus/plusminus_checkpoint \
  --traineddata ~/tesstutorial/trainplusminus/eng/eng.traineddata \
  --eval_listfile ~/tesstutorial/evalplusminus/eng.training_files.txt

tree .