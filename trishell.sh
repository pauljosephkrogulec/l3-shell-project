#!/bin/sh

# on vérifie si il existe un parmatrè.
test $# -ne 1 && echo "Need a command as parameter" && exit 1

# Déclaration des variables
nb_param="$#"       # nombre de paramètre
cmd_rec=false       # Vrai si la commande -R est appelé, sinon faux.
cmd_dec=false       # Vrai si la commande -d est appelé, sinon faux.
cmd_nsmletpg=false  # Vrai si la commande -nsmletpg est appelé, sinon faux.
isRep=false         # Vrai si on a bien un répertoire en paramètre, faux sinon.
param_nsmletpg=""

isDirectory() {
    if test -d "$1"
    then
        isRep=true
    fi
}

isRecursif() {
    if test "$1" == "-R"
    then
        cmd_rec=true
    fi
}

isDescending() {
    if test "$1" == "-d"
    then
        cmd_dec=true
    fi
}

isNsmletpg() {

}

isDescending $1
echo $cmd_dec
# On verifie si le paramètre 
# on appell une fonction qui verifie les paramètres
