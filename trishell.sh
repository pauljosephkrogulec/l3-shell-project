#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                     #
#                           Projet de Shell                           #
#       Réalisé par Quentin Carpentier & Paul-Joseph Krogulec         #
#   GitHub : https://github.com/pauljosephkrogulec/l3-shell-project   #
#                                                                     #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# on vérifie si il y a bien un répertoire passé en paramètre.
test $# -lt 1 && echo "Need a command as parameter" && exit 1
test $# -ge 5 && echo "Too many parameters (4 max)" && exit 2
# Constantes
SEPARATOR=":"
NB_PARAM="$#"
ALL_PARAM="$@"
ALL_TRI="nsmletpg"      # on défini l'ensemble des critères de tris possibles.
# Déclaration des variables
param_rec=0         # Indique du paramètre si la commande -R est appelé, sinon 0.
param_dec=0         # Indique du paramètre si la commande -d est appelé, sinon 0.
param_tri=0         # Indique du paramètre si la commande -nsmletpg est appelé, sinon 0.
param_rep=0         # Indique du paramètre si on a bien un répertoire en paramètre, 0 sinon.

save_rep=""         # on sauvegarde le répertoire donné en paramètre.
save_tri=""         # on sauvegarde les critères de tris donnés en paramètre.

stringFiles=""      # on sauvegarde dans la chaine l'ensemble des fichiers.

function isCommand() {
    # Fonction qui vérifie si le premier caractère du paramètre est un "-", si c'est le cas
    # on retourne 1, sinon 0.

    test ${1:0:1} == '-' && echo 1 || echo 0
}

function isRecursif() {
    # Fonciton qui vérifie si le premier paramètre est bien une commande d'appel résursif (-R)
    # Si c'est bien la commande -R, on retourne 1, sinon 0.

    test "$1" == "-R" && echo 1 || echo 0
}

function isDescending() {
    # Fonciton qui vérifie si le premier paramètre est bien une commande pour trier de manière décroissante (-d)
    # Si c'est bien la commande -d, on retourne 1, sinon 0.

    test "$1" == "-d" && echo 1 || echo 0
}

function isTris() {
    # Fonction qui vérifie si le premier paramètre est bien la commande qui spécifie les critères de tris utilisés.
    # Si c'est bien la commande -nsmletpg on enregistre les critères et on retourne 1, sinon faux

    local i=1;local j;local lengthWord=`expr length $1`;local length_nsmletpg=`expr length $ALL_TRI`
    local valid=1;local carac1;local carac2;local found_type

    while test "$i" -lt $lengthWord -a $valid -eq 1
        do
        carac1=${1:i:1};found_type=0;j=0
        while test $j -lt $length_nsmletpg -a $found_type -ne 1
            do
            carac2=${ALL_TRI:j:1}
            if test "$carac1" == "$carac2"
                then
                found_type=1
            fi
            j=`expr $j + 1`
        done

        if test $found_type -ne 1
            then
            valid=0
        fi
        
        i=`expr $i + 1`
    done
    
    echo $valid
}

function isDirectory() {
    # Fonction qui vérifie si le premier paramètre est bien un répertoire,
    # Si c'est le cas, on retourne 1, sinon 0.

    test -d "$1" && echo 1 || echo 0
}

function checkCommands() {
    # Fonction qui va parcourir l'ensemble des éléments de la commande donnés en paramètre, et va vérifier si chaque type d'élément est valide.
    # Si un élément n'est pas valide, ou valide mais qu'un autre élément du même type à déjà été rencontré... alors la commande donnée en paramètre
    # est fausse et on sort du programme en indiquant l'option invalide.

    local ind=1;local found;local i
    for i in $ALL_PARAM
        do
        found=0
        if test $(isCommand $i) -eq 1
            then
            if test $(isRecursif $i) -eq 1 -a $param_rec -eq 0
                then
                param_rec="$ind"; found=1

            elif test $(isDescending $i) -eq 1 -a $param_dec -eq 0
                then
                param_dec="$ind"; found=1

            elif test $(isTris $i) -eq 1 -a $param_tri -eq 0
                then
                param_tri="$ind"; save_tri="$i"; found=1
            fi
        else
            if test $(isDirectory $i) -eq 1 -a $param_rep -eq 0
                then
                param_rep="$ind"; save_rep="$i"; found=1
            fi
        fi

        test $found -eq 0 && echo "invalid option -- '$i'" && exit 3
        ind=`expr $ind + 1`
    done
    test $param_rep -eq 0 && echo "Need a directory as parameter" && exit 4
}

function nameFile() {
   # Fonction qui prend en paramètre un fichier et retourne son nom.
    echo .$(echo $1 | cut -d'.' -f2)
}

function sizeFile() {
    # Fonction qui prend en paramètre un fichier et retourne sa taille.
    echo $(stat -c "%s" $1)
}

function lastDateFile() {
    # Fonction qui prend en paramètre un fichier et retourne la date de sa dernière modification.
    echo $(stat -c "%y" $1)
}

function linesFile() {
   # Fonction qui prend en paramètre un fichier et retourne son nombre de lignes.
   echo $(sed -n '$=' $1)
}

function extensionFile() {
    # Fonction qui prend en paramètre un fichier et retourne son extension.
    echo $(sed 's/^.*\(...$\)/\1/' <<< $1)
}

function ownerFile() {
    # Fonction qui prend en paramètre un fichier et retourne le propriétaire.
    echo $(stat -c "%U" $1)
}

function groupFile() {
    # Fonction qui prend en paramètre un fichier et retourne le groupe du propriétaire.
    echo $(stat -c "%G" $1)
}

function createString() {
    # Fonction qui à partir de du répertoire donné en paramètre de la commande,
    # va stocker l'ensemble des fichiers en les séparant tous par le séparateur définit en constante ":"
    # Si la chaine a été crée on retourne 1, sinon 0

    local chaine=""
    for i in "$1"/*
    do
        if test -f "$i"
        then
            chaine=$chaine"$i$SEPARATOR"
        elif test -d "$i" -a $param_rec -ne 0
            then
            chaine= createString $i
        fi
    done
    stringFiles=$stringFiles$chaine
}

function countFiles() {
    # Fonction qui va parcourir une chaine de caractère passé en paramètre contenant des fichiers.
    # Et va retourner le nombre de ficheirs (séparé par le séparateur ":").

    local len=`expr length $1`;local ch=""
    local carac="";local res=0
    for i in `seq 0 $len`
        do
        carac=${1:i:1}
        if test "$carac" == "$SEPARATOR"
            then
            res=`expr $res + 1`
            ch=""
        else
            ch=$ch"$carac"
        fi
    done
    echo "$res"
}

function printString() {
    # Fonction qui va parcourir la chaine de caractère stringFiles contenant l'ensemble des fichiers du paramètres données.
    # Et va afficher les fichiers séparés par un séparateur ":"

    local i=1;local nbFiles=$(countFiles $1)

    while test "$i" -le "$nbFiles"
        do
        echo $(echo $1 | cut -d':' -f"$i")
        i=`expr $i + 1`
    done
}

function compareText() {
    if test $1 \> $2 
        then
        echo 1
    elif test $1 \< $2 
        then
        echo -1
    else
        echo 0
    fi
}
function compareNumber() {
    if test $1 -gt $2 
        then
        echo 1
    elif test $1 -eq $2 
        then
        echo 0
    else
        echo -1
    fi
}

function tri_d() {
    # Fonction qui prend en paramètre récupère chaque fichier de la chaine de caractère à l'aide de la commande cut,
    # et va ajouter chaque fichier dans une nouvelle chaine qui remplacera la chaine de fichier actuelle..
    
    local i=$(countFiles $1)
    local newString="";local word=""

    while test "$i" -ne 0
        do
        word=$(echo $1 | cut -d':' -f"$i")
        newString=$newString"$word"$SEPARATOR
        i=`expr $i - 1`
    done
    echo "$newString"
}

function tri_n() {
    # Fonction qui prend en paramètre récupère chaque fichier de la chaine de caractère à l'aide de la commande cut,
    # et va ajouter chaque fichier dans une nouvelle chaine qui remplacera la chaine de fichier actuelle..

    local i=1;local j=1;local k=1; local cpt=0
    local newString="";local file="";local file2="";local numberF=0;local name1="";local name2="";local tmp=""
    local len=$(countFiles $1)
    while test "$i" -le "$len"
        do
        file=$(echo $1 | cut -d':' -f"$i")
        if test $numberF -eq 0
            then
            newString="$file:"
            numberF=1
        else
            j=1;found=0
            name1=$(nameFile $file)
            file2=$(echo $newString | cut -d':' -f1)
            name2=$(nameFile $file2)
            while test $(compareText $name2 $name1) -ne 1 -a $j -le $numberF
                do
                j=`expr $j + 1`
                file2=$(echo $newString | cut -d':' -f"$j")
                name2=$(nameFile $file2)
                cpt=$j
            done
            if test $cpt -gt $numberF 
                then 
                newString="$newString$file:"
                numberF=`expr $numberF + 1`
            else
                if test $(compareText $name2 $name1) -eq 1
                    then
                    cpt=`expr $cpt + 1`
                    while test $k -lt $cpt
                        do
                        tmp="$tmp$(echo $newString | cut -d':' -f"$k")":
                        k=`expr $k + 1`
                    done
                    tmp="$tmp$file:"
                    cpt=`expr $cpt + 1`
                    while test $cpt -lt $numberF
                        do
                        tmp="$tmp$(echo $newString | cut -d':' -f"$k"):"
                        cpt=`expr $cpt + 1`
                    done
                    newString=$tmp
                    numberF=`expr $numberF + 1`
                fi
            fi
        fi
        i=`expr $i + 1`
    done
    stringFiles="$newString"
}


function main() {
    # Fonction qui nb prend rien en paramètre et exécute le programme.

    # On vérifie la commande donnée.
    checkCommands
    createString $save_rep
    
    tri_n $stringFiles
    stringFiles=$(tri_d $stringFiles)
    printString $stringFiles
}

# on appelle la fonction main pour lancer le programme
main 