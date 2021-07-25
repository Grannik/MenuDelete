#!/bin/bash
 
 E='echo -e';e='echo -en';trap "R;exit" 2
 ESC=$( $e "\e")
 TPUT(){ $e "\e[${1};${2}H" ;}
 CLEAR(){ $e "\ec";}
# 25 возможно это 
 CIVIS(){ $e "\e[?25l";}
# это цвет текста списка перед курсором при значении 0 в переменной  UNMARK(){ $e "\e[0m";}
 MARK(){ $e "\e[41m";}
# 0 это цвет заднего фона списка
 UNMARK(){ $e "\e[0m";}
# ~~~~~~~~ Эти строки задают цвет фона ~~~~~~~~
 R(){ CLEAR ;stty sane;CLEAR;};
#R(){ CLEAR ;stty sane;$e "\ec\e[37;44m\e[J";};
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 HEAD(){ for (( a=1; a<=16; a++ ))
  do
   TPUT $a 1
        $E "\xE2\x94\x82                                        \xE2\x94\x82";
  done
  TPUT 3 2
        $E "$(tput setaf 2)  Справочник операции удаления $(tput sgr 0)";
  TPUT 5 2
        $E "$(tput setaf 2)  delete $(tput sgr 0)";
  TPUT 8 2
        $E "$(tput setaf 2)  rm $(tput sgr 0)";
  TPUT 13 2 
        $E "$(tput setaf 2)  Up \xE2\x86\x91 \xE2\x86\x93 Down Select Enter$(tput sgr 0) ";
 MARK;TPUT 1 2
        $E "  Программа написана на bash tput       " ;UNMARK;}
   i=0; CLEAR; CIVIS;NULL=/dev/null
# 32 это расстояние сверху и 48 это расстояние слева
   FOOT(){ MARK;TPUT 16 2
# нижнее заглавие
        $E "  *** | Grannik | 2021.07.25 | ***      ";UNMARK;}
# это управляет кнопками ввер/хвниз
 i=0; CLEAR; CIVIS;NULL=/dev/null
#
 ARROW(){ IFS= read -s -n1 key 2>/dev/null >&2
           if [[ $key = $ESC ]];then 
              read -s -n1 key 2>/dev/null >&2;
              if [[ $key = \[ ]]; then
                 read -s -n1 key 2>/dev/null >&2;
                 if [[ $key = A ]]; then echo up;fi
                 if [[ $key = B ]];then echo dn;fi
              fi
           fi
           if [[ "$key" == "$($e \\x0A)" ]];then echo enter;fi;}
# 4 и далее это отступ сверху и 48 это расстояние слева
 M0(){ TPUT  6 3; $e " Удалить по расширению все файлы     ";}
 M1(){ TPUT  7 3; $e " Удалить по части названия все файла ";}
 M2(){ TPUT  9 3; $e " Мануал                              ";}
 M3(){ TPUT 10 3; $e " Удаление файлов                     ";}
 M4(){ TPUT 11 3; $e " Удаление директорий                 ";}
 M5(){ TPUT 12 3; $e " Остальные команды                   ";}
#
 M6(){ TPUT 14 3; $e " EXIT                                ";}
# далее идет переменная LM=16 позволяющая выстраивать список в вертикаль.
LM=6
   MENU(){ for each in $(seq 0 $LM);do M${each};done;}
    POS(){ if [[ $cur == up ]];then ((i--));fi
           if [[ $cur == dn ]];then ((i++));fi
           if [[ $i -lt 0   ]];then i=$LM;fi
           if [[ $i -gt $LM ]];then i=0;fi;}
REFRESH(){ after=$((i+1)); before=$((i-1))
           if [[ $before -lt 0  ]];then before=$LM;fi
           if [[ $after -gt $LM ]];then after=0;fi
           if [[ $j -lt $i      ]];then UNMARK;M$before;else UNMARK;M$after;fi
           if [[ $after -eq 0 ]] || [ $before -eq $LM ];then
           UNMARK; M$before; M$after;fi;j=$i;UNMARK;M$before;M$after;}
   INIT(){ R;HEAD;FOOT;MENU;}
     SC(){ REFRESH;MARK;$S;$b;cur=`ARROW`;}
# Функция возвращения в меню
     ES(){ MARK;$e " ENTER = main menu ";$b;read;INIT;};INIT
  while [[ "$O" != " " ]]; do case $i in
# Здесь необходимо следить за двумя перепенными 0) и S=M0 Они должны совпадать между собой и переменной списка M0().
        0) S=M0;SC;if [[ $cur == enter ]];then R;echo "
 Удаляет файлы рекурсивно внутрь папок
 find . -type f -name \"*.txt\" -delete
";ES;fi;;
        1) S=M1;SC;if [[ $cur == enter ]];then R;echo "
 find . -type f -name 'smth*' -delete
";ES;fi;;
        2) S=M2;SC;if [[ $cur == enter ]];then R;rm --help;ES;fi;;
        3) S=M3;SC;if [[ $cur == enter ]];then R;echo "
 удаляет файл:
 rm назв.txt
 -------------
 удаляет все файлы:
 rm *
";ES;fi;;
        4) S=M4;SC;if [[ $cur == enter ]];then R;echo "
 удаляет папку:
 rmdir название
 ---------------------------
 удаляет папку с содержимым:
 rm -rf название
 ---------------------------
 рекурсивно удалять каталоги и их содержимое
 rm -R название
 rm --recursive
";ES;fi;;
        5) S=M5;SC;if [[ $cur == enter ]];then R;echo "
 -f --force               игнорировать несуществующие файлы и аргументы, ни о чем не спрашивать
 -i                       запрашивать подтверждение перед каждым удалением
 -I                       запрашивать подтверждение один раз перед удалением более трёх файлов или перед рекурсивным удалением
    --interactive[=КОГДА] запрашивать подтверждение в соответствии
                          с КОГДА: never (никогда), once (-I, один раз) или
                          always (-i, всегда);
                          если КОГДА не задано — запрашивать всегда
    --one-file-system     при рекурсивном удалении иерархии, пропускать все каталоги, находящиеся не на той же файловой системе,
                          что и соответствующий аргумент командной строки
    --no-preserve-root    не обрабатывать «/» особым образом
    --preserve-root[=all] не удалять «/» (по умолчанию); при указании «all» отвергать любой аргумент командной строки
                          на отдельном устройстве от его родителя
 -d --dir                 удалять пустые каталоги
 -v --verbose             пояснять производимые действия
    --version             показать информацию о версии и выйти
 rm -- -foo               Для удаления файла, начинающегося с «-» (например: «-foo»)
 rm ./-foo
";ES;fi;;
        6) S=M6;SC;if [[ $cur == enter ]];then R;clear;ls -l;exit 0;fi;;
 esac;POS;done
