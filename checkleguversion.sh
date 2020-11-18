oldV=4.1.0.13
oldversion=${oldV}

:<<!
curl -F "apk=@/home/homework/user/zh/app-release-138-update_legu.apk" "https://platmis.zuoyebang.cc/platmis/apkpack/allsignedaligntest" > app-release-138-update_legu_ssgined.apk

getVersion(){
    $apk='pwd'$1
    echo $apk
    $filepath=$2
    name=$(ls $apk | cut -d. -f1 )
    zipfile=${name}."zip"
    echo $name
    mv $apk $zipfile
    unzip "$zipfile" -d "$name"
    
    filepath=$name/lib/armeabi-v7a/*

    filepath=$1                                  
    for file in $filepath
        do
            var=${file#*-}
            if [ $var -eq "libshella" ]
            then
                version=${var%.*}
                echo ${var}
                echo "$version"
                return 1;
            fi
    done
    echo "查找版本失败！"
    return 0
}
!
clean_folder(){ [ -d $1 ]&& rm -rf $1; mkdir $1;}

version_gt(){ test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }

version_lt(){ test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }


signed_folder="/home/homework/user/signed_folder"
clean_folder $signed_folder

apk=${1##*\/}
echo $apk
name=$signed_folder/$(ls $apk | cut -d. -f1 )
echo $name
zipfile=${name}."zip"
echo $zipfile

#clean_files $zipfile $name

mv $apk $zipfile
unzip "$zipfile" -d "$name"

filepath=$name/lib/armeabi-v7a/*

#result=getVersion ${filepath}
for file in $filepath
    do       
        var=${file##*\/}
        fname=${var%-*}
        if [ $fname = "libshella" ]
        then
             version=${var%.*}
             version=${version#*-}
        fi
done

if version_gt $version $oldversion
then
    echo "本次app安装包加固版本有升级！请在发包前回归测试"
#   sed -ie 's/${version}/${version}/g' /home/homework/user/zh/new.sh
    con="oldV=${version}"
    sed -i "1c${con}" ./$BASH_SOURCE
elif version_lt $version $oldversion
then
    echo "本次app安装包加固版本低于上次版本，可能乐固版本有回滚！请在发包前回归测试"
    con="oldV=${version}"
    sed -i "1c${con}" ./$BASH_SOURCE
else  
    echo "本次app安装包加固版本未升级~ ~"
fi

echo "上次版本："${oldversion}
echo "本次版本："${version}

#clean_files $zipfile $name
clean_folder $signed_folder
