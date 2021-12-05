libdir=/usr/local/lib/lua/5.4/functional/
mkdir --verbose --parents $libdir
cp --verbose --preserve --update init.lua list.lua operator.lua $libdir
