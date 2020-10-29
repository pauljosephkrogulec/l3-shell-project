#!/bin/bash

# on vérifie si il existe un parmatrè.
test $# -lt 1 && echo "Need a command as parameter" && exit 1

# Déclaration des variables
nb_param="$#"         # nombre de paramètre
all_param="$@"        # tous les paramètres
param_rec=false       # Vrai si la commande -R est appelé, sinon faux.
param_dec=false       # Vrai si la commande -d est appelé, sinon faux.
param_nsmletpg=false  # Vrai si la commande -nsmletpg est appelé, sinon faux.
param_rep=false       # Vrai si on a bien un répertoire en paramètre, faux sinon.

isCommand() {
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

# Fonciton qui vérifie si le premier paramètre est bien une commande d'appel pour effecuter les tri (-nsmletpg)
isDirectory() {
    test -d "$1" && echo 1 || echo 0
}



isNsmletpg() { 
    echo 0
}

i=1
end=0
# On verifie si le paramètre 
# on appelle une fonction qui verifie les paramètres
while test $i -le $# -a $end -eq 0
do  
    if test $(isCommand $1) -eq 1
    then
        if test $param_rec != true -a $(isRecursif $1) -eq 1
        then
            param_rec=true
        else
            if test $param_dec != true -a $(isDescending $1) -eq 1
            then
                param_dec=true
            else
                if test $param_nsmletpg != true -a $(isNsmletpg $1) -eq 1
                then
                    param_nsmletpg=true
                else
                    echo "invalid option -- '$1'"
                    end=1
            fi
            fi
        fi
    else
        if test $param_rep != true -a $(isDirectory $1) -eq 1
        then
            param_rep=true
        else
            echo "invalid option -- '$1'"
            end=1
        fi
    fi
    if test $end -ne 1
    then
        shift
    fi
done
