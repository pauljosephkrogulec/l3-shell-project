#!/bin/sh

# on vérifie si il y a bien un répertoire passé en paramètre.
test $# -lt 1 && echo "Need a command as parameter" && exit 1

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

files=""            # on sauvegarde dans la chaine l'ensemble des fichiers.

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

    while test $i -lt $lengthWord -a $valid -eq 1
        do
        carac1=${1:i:1};found_type=0;j=0
        while test $j -lt $length_nsmletpg -a $found_type -ne 1
            do
            carac2=${ALL_TRI:j:1}
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

function isDirectory() {
    # Fonction qui vérifie si le premier paramètre est bien un répertoire,
    # Si c'est le cas, on retourne 1, sinon 0.

    test -d "$1" && echo 1 || echo 0
}

function checkCommands() {
    # Fonction qui va parcourir l'ensemble des éléments de la commande donnés en paramètre, et va vérifier si chaque type d'élément est valide.
    # Si un élément n'est pas valide, ou valide mais qu'un autre élément du même type à déjà été rencontré... alors la commande donnée en paramètre
    # est fausse et on sort du programme en indiquant l'option invalide.

    local ind=1
    for i in $ALL_PARAM
        do
        if test $(isRecursif $i) -eq 1 -a $param_rec -eq 0
            then
            param_rec="$ind"

        elif test $(isDescending $i) -eq 1 -a $param_dec -eq 0
            then
            param_dec="$ind"

        elif test $(isTris $i) -eq 1 -a $param_tri -eq 0
            then
            param_tri="$ind"
            save_tri="$i"
        
        elif test $(isDirectory $i) -eq 1 -a $param_rep -eq 0
            then
            param_rep="$ind"

        else
            echo "invalid option -- '$i'"
            exit 2
        fi

        ind=`expr $ind + 1`
    done
}

function main() {
    # Fonction qui nb prend rien en paramètre et exécute le programme.

    # On vérifie la commande donnée.
    checkCommands
}

# on appelle la fonction main pour lancer le programme
main
