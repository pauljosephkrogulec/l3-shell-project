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

function isSort() {
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

            elif test $(isSort $i) -eq 1 -a $param_tri -eq 0
                then
                param_tri="$ind"; save_tri="$i"; found=1
            fi
        else
            if test $(isDirectory $i) -eq 1 -a $param_rep -eq 0
                then
                param_rep="$ind"; save_rep="$i"; found=1
            fi
        fi

        test $found -eq 0 && echo "invalid option -- '$i'" && exit 4
        ind=`expr $ind + 1`
    done
    test $param_rep -eq 0 && echo "Need a directory as parameter" && exit 5
}

function nameFile() {
   # Fonction qui prend en paramètre un fichier et retourne son nom.
    echo $(basename $1)
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
    echo $res
}

function printString() {
    # Fonction qui va parcourir la chaine de caractère stringFiles contenant l'ensemble des fichiers du paramètres données.
    # Et va afficher les fichiers séparés par un séparateur ":"

    local i=1;local nbFiles=$(countFiles $1);
    local file=""

    for i in `seq 1 $nbFiles`
        do
        file="$(echo $1 | cut -d':' -f"$i")"
        echo -e "$file \t\t : $(linesFile $file)"
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

function sortDescending() {
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

function sortByOption() {
    # Fonction qui prend en paramètre une chaine de caractère de fichiers,
    # et va trier cette chaine selon le nom des fichiers. (méthode de tri par sélection)

    local newString="$1";local word="";local word_mini="";local ref="";local tmp=0
    local len=$(countFiles $1);local i=1;local j;local mini=0

    for i in `seq 1 $len`
        do
        mini="$i"
        j="$i"
        for j in `seq $i $len`
            do
            word=$(echo $newString | cut -d':' -f"$j")
            word_mini=$(echo $newString | cut -d':' -f"$mini")

            local val1="$($2 $word)"
            local val2="$($2 $word_mini)"

            test -z $val1 && val1=0
            test -z $val2 && val2=0

            if test "$2" == "linesFile"
                then
                test $(compareNumber $val1 $val2) -eq -1 && mini="$j"
            else
                test $(compareText $val1 $val2) -eq -1 && mini="$j"
            fi
        done
        word=$(echo $newString | cut -d':' -f"$i")
        word_mini=$(echo $newString | cut -d':' -f"$mini")

        # on remplace inverse les fichiers dans la chaine
        newString=$(awk -v a="$word_mini" 'BEGIN{FS=OFS=":"} {$'$i'=a; print}' <<< "$newString")
        newString=$(awk -v a="$word" 'BEGIN{FS=OFS=":"} {$'$mini'=a; print}' <<< "$newString")
    done
    echo "$newString"
}

function sortString {
    # Fonction qui ne prend rien en paramètre,
    # et effectue pour chaque commande passé en entrée, le trie sur la chaine de caractère contenant les fichiers.
    local i="$2"
    local option=${save_tri:i:1};local newString="$1";
    # en fonction du critère du tri appelé...
    case "$option" in 
        # si on appel le critère "n", on exécute la fonction qui trie la chaine par nom des entrées.
        "n") newString=$(sortByOption $1 nameFile $2);;

        # si on appel le critère "s", on exécute la fonction qui trie la chaine par la taille des entrées.
        "s") newString=$(sortByOption $1 sizeFile $2);;

        # si on appel le critère "m", on exécute la fonction qui trie la chaine par la taille des entrées.
        "m") newString=$(sortByOption $1 lastDateFile $2);;

        # si on appel le critère "s", on exécute la fonction qui trie la chaine par la taille des entrées.
        "l") newString=$(sortByOption $1 linesFile $2);;

        # si on appel le critère "s", on exécute la fonction qui trie la chaine par la taille des entrées.
        "e") newString=$(sortByOption $1 extensionFile $2);;

        # si on appel le critère "s", on exécute la fonction qui trie la chaine par la taille des entrées.
        "p") newString=$(sortByOption $1 ownerFile $2);;

        # si on appel le critère "s", on exécute la fonction qui trie la chaine par la taille des entrées.
        "g") newString=$(sortByOption $1 groupFile $2);;
        *) echo "$newString";;
    esac

    # on retourne la chaine trié.
    echo "$newString"

}

function main() {
    # Fonction main qui ne prend rien en paramètre,
    # et va exécuter les diverses commandes nécessaires au bon déroulement du programme.

    # On vérifie la commande d'entrée donnée.
    checkCommands

    # On crée la chaine de caractère contenant l'ensemble des fichiers.
    createString "$save_rep"

    # On tri la chaine de caractère selon les critères de tris donnée en entrée.
    stringFiles=$(sortString $stringFiles 1)
    
    # si la commande "-d" à été appelé, on exécute la fonction qui trie la chaine par ordre décroissant.
    test "$param_dec" -ne 0 && newString=$(sortDescending $newString)

    # on affiche l'ensemble des ficheirs triés.
    printString "$stringFiles"
}

# on appelle la fonction main pour lancer le programme
main
