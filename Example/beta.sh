#!/bin/bash

#设置超时
export FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=120

#计时
SECONDS=0

#假设脚本放置在与项目相同的路径下
project_path=$(pwd)

project_name="Easy"
#指定项目的scheme名称
scheme="Easy_Example_Beta"
#指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
export_method='enterprise'

#指定项目地址
workspace_path="$project_path/$project_name.xcworkspace"
#指定输出路径
output_path="$project_path/App"
#指定输出归档文件地址
archive_path="$output_path/$project_name.xcarchive"
#指定输出ipa地址
ipa_path="$output_path/$project_name.ipa"
#指定输出ipa名称
ipa_name="$project_name.ipa"
#填写更新日志
rm -rf commit
touch commit
open commit

read -p "更新日志写好了吗?(按回车继续...) " answer

count=1
history=""
for line in $(cat commit)
do 
    history+="${count}.${line}"
    count=$[$count+1]
done

echo -e $history
rm -rf commit
#获取执行命令时的commit message
commit_msg=$history"(由fastlane自动构建)"

#输出设定的变量值
echo "===workspace path: ${workspace_path}==="
echo "===archive path: ${archive_path}==="
echo "===ipa path: ${ipa_path}==="
echo "===export method: ${export_method}==="
echo "===commit msg: ${commit_msg}==="

#拉取最新代码
read -n1 -p "要拉取新代码吗？(5s后自动执行不拉取新代码) [Y/N]? " -t 5 answer
case $answer in
Y | y) echo
       echo "拉取新代码中..."
       git pull;;
N | n) echo 
       echo "不拉新代码，直接打包";;
esac

#先清空前一次build
fastlane gym --workspace ${workspace_path} --scheme ${scheme} --clean --archive_path ${archive_path} --export_method ${export_method} --output_directory ${output_path} --output_name ${ipa_name}

#上传到pgy https://www.pgyer.com/account/api
curl -F "file=@${ipa_path}" -F "_api_key=替换APIKey" -F "buildUpdateDescription=${commit_msg}" https://www.pgyer.com/apiv2/app/upload

#删除App
rm -rf ${output_path}

#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="