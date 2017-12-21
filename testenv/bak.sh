
#backup shengcai tools
TOOL="shengcai"
VER="20171101"
rm -rf /opt/rh/$TOOL*
mkdir /opt/rh/$TOOL
mkdir /opt/rh/$TOOL/prog
cd /opt/$TOOL/
cp -r mkresults README runtest testcases testenv list /opt/rh/$TOOL/
cp -r prog/*.tar* prog/*.tgz prog/soft_name /opt/rh/$TOOL/prog
cd /opt/rh
tar zcf $TOOL-$VER.tar.gz $TOOL
scp $TOOL-$VER.tar.gz root@192.168.32.102:/data/html
