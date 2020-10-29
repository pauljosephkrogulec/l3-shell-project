#!/bin/sh

# on vérifie si il existe un parmatrè.
test $# -ne 1 && echo "Need a command as parameter" && exit 1

# Déclaration des variables...
nb_param="$#"           # nombre de paramètre
param_rec=false         # Vrai si la commande -R est appelé, sinon faux.
param_dec=false         # Vrai si la commande -d est appelé, sinon faux.
param_nsmletpg=false    # Vrai si la commande -nsmletpg est appelé, sinon faux.
param_rep=false         # Vrai si on a bien un répertoire en paramètre, faux sinon.

isCommand() {
    test ${1:0:1} == '-' && return 1 || return 0
}

# Fonciton qui vérifie si le premier paramètre est bien une commande d'appel résursif (-R)
isRecursif() {
    test "$1" == "-R" && param_rec=true
}

# Fonciton qui vérifie si le premier paramètre est bien une commande pour trier de manière décroissante (-d)
isDescending() {
    test "$1" == "-d" && param_dec=true
}

# Fonciton qui vérifie si le premier paramètre est bien une commande d'appel pour effecuter les tri (-nsmletpg)
isDirectory() {
    test -d "$1" && param_rep=true
}

isDescending $1
echo $cmd_dec
