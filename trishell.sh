#!/bin/sh

# on vérifie si il existe un parmatrè.
test $# -lt 1 && echo "Need a directory as parameter" && exit 1

# Déclaration des variables...
nb_param="$#"           # nombre de paramètre
param_rec=false         # Vrai si la commande -R est appelé, sinon faux.
param_dec=false         # Vrai si la commande -d est appelé, sinon faux.
param_nsmletpg=false    # Vrai si les commande -nsmletpg est appelé, sinon faux.
param_rep=false         # Vrai si on a bien un répertoire en paramètre, faux sinon.

nsmletpg="nsmletpg"

syntaxValid() {
    test ${1:0:1} == '-' && echo 1 || echo 0
}

# Fonciton qui vérifie si le premier paramètre est bien une commande d'appel résursif (-R)
isRecursif() {
    test "$1" == "-R" && echo 1 || echo 0
}

# Fonciton qui vérifie si le premier paramètre est bien une commande pour trier de manière décroissante (-d)
isDescending() {
    test "$1" == "-d" && echo 1 || echo 0
}

isNsmletpg() {
    local i=1;local j;local lengthWord=`expr length $1`;local length_nsmletpg
    local valid=1;local carac1;local carac2;local found_type

    while test $i -lt $lengthWord -a $valid -eq 1
    do
        carac1=${1:i:1};found_type=0;j=0
        length_nsmletpg=`expr length $nsmletpg`
        while test $j -lt $length_nsmletpg -a $found_type -ne 1
        do
            carac2=${nsmletpg:j:1}
            if test $carac1 == $carac2
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

# Fonciton qui vérifie si le premier paramètre est bien une commande d'appel pour effecuter les tri (-nsmletpg)
isDirectory() {
    test -d "$1" && echo 1 && echo 0
}

isNsmletpg $1
