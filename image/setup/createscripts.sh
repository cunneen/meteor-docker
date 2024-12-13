for i in .eslintrc.yml createscripts.sh default_node.js install_node.js install_nvm.sh setup_root_nvm.sh versions.json
do
echo "cat << '${i}' > ${i}"
cat $i
echo ${i}
done > makescripts.sh
