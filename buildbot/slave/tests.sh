#!/bin/bash

# installs spring-headless, downloads some content files and
# runs a simple high level tests of the engine (AI vs AI)

set -e
. buildbot/slave/prepare.sh

TESTDIR=${TMP_BASE}/tests
DOWNLOADDIR=${TMP_BASE}/download
CONTENT_DIR=${TESTDIR}/.spring

if [ ! -d test/game/ ];
then
	echo This script has to be run from the source root dir
	exit 1
fi

#install
cd ${BUILDDIR}
make install-spring-headless DESTDIR=${TESTDIR} $@

cd ${SOURCEDIR}
#fetch required files
mkdir -p $DOWNLOADDIR
if [ ! -s $DOWNLOADDIR/ba750.sdz ]; then
	wget -N -P $DOWNLOADDIR http://springfiles.com/sites/default/files/downloads/spring/games/ba750.sdz || ( rm -rf ${DOWNLOADDIR} && exit 1 )
fi

if [ ! -s $DOWNLOADDIR/Altair_Crossing.sd7 ]; then
	wget -N -P $DOWNLOADDIR http://springfiles.com/sites/default/files/downloads/spring/spring-maps/Altair_Crossing.sd7 || ( rm -rf ${DOWNLOADDIR} && exit 1 )
fi

#install required files into spring dir
cd ${SOURCEDIR}
mkdir -p ${CONTENT_DIR}/games ${CONTENT_DIR}/maps ${CONTENT_DIR}/LuaUI/Widgets
cp -suv ${DOWNLOADDIR}/ba750.sdz ${CONTENT_DIR}/games/ba750.sdz
cp -suv ${DOWNLOADDIR}/Altair_Crossing.sd7 ${CONTENT_DIR}/maps/Altair_Crossing.sd7
cp -suv ${SOURCEDIR}/test/game/LuaUI/Widgets/test.lua ${CONTENT_DIR}/LuaUI/Widgets/test.lua
cp -suv ${SOURCEDIR}/test/game/test1.script.txt ${CONTENT_DIR}/test1.script.txt

#run test
HOME=${TESTDIR}/
${SOURCEDIR}/test/game/run.sh ${TESTDIR}/usr/local/bin/spring-headless test1.script.txt

#cleanup
rm -rf ${TMP_BASE}/tests
