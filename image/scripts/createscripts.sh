for i in entry.sh        node-version.js onbuild-node.sh setup_nvm.sh    start.sh  
do
echo "cat << '${i}' > ${i}"
cat $i
echo ${i}
done > makescripts.sh