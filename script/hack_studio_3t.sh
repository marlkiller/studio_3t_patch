
target_app="/Applications/Studio 3T.app"
version="2024.2.0"
rewrite_dir="$(pwd)/../out/${version}/t3"


echo "Changing directory to ${target_app}/Contents/Resources/app"
cd "${target_app}/Contents/Resources/app"


jar_name=data-man-mongodb-ent-${version}.jar
jar_file=${target_app}/Contents/Resources/app/${jar_name}
jar_file_back="${jar_file}_Backup"

if [ ! -f "$jar_file" ]; then
    echo "File $jar_file does not exist."        
    exit 1
fi

# 备份文件
if [ ! -f "$jar_file_back" ]; 
then
    echo "Backing up $jar_file to $jar_file_back"
    cp "$jar_file" "$jar_file_back"
fi


mkdir tmp
mv ${jar_name} tmp/
cd tmp

echo "Extracting ${jar_name}"
jar -xf ${jar_name}
rm -rf ${jar_name}

# 删除签名信息
echo "Removing signature files"
rm -rf META-INF/SIGNING.RSA

# 替换相关文件
echo "Copying files from $rewrite_dir to current directory"
rsync -av $rewrite_dir ./

# 重新打包
echo "Repacking JAR file"
jar -cf ${jar_name} *
mv ${jar_name} ../

# 清理临时文件
echo "Cleaning up temporary files"
cd ..
rm -rf tmp

echo "Script execution completed"

# 启动应用程序
echo "Launching application: ${target_app}/Contents/MacOS/JavaApplicationStub"
exec "${target_app}/Contents/MacOS/JavaApplicationStub"