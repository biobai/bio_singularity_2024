#!/bin/bash

cd "$SRC_DIR"
autoreconf -i
./configure --prefix=$PREFIX
make
make install -C src

for f in bamsort.sh moabs preprocess_novoalign.sh redepth.pl routines.pm template_for_cfg template_for_qsub
do
	cp "${SRC_DIR}/bin/$f" ${PREFIX}/bin
done
cp -R "${SRC_DIR}/bin/plib" ${PREFIX}/bin
cp "${SRC_DIR}/lib/samtools/samtools" ${PREFIX}/bin

