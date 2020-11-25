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

    while test "$i" -lt "$lengthWord" -a "$valid" -eq 1
        do
        carac1=${1:i:1};found_type=0;j=0
        while test "$j" -lt "$length_nsmletpg" -a "$found_type" -ne 1
            do
            carac2=${ALL_TRI:j:1}
            if test "$carac1" == "$carac2"
                then
                found_type=1
            fi
            j=`expr $j + 1`
        done

        if test "$found_type" -ne 1
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

    local ind=1;local found

    for i in $ALL_PARAM
        do
        found=0
        if test $(isCommand $i) -eq 1
            then
            if test $(isRecursif $i) -eq 1 -a "$param_rec" -eq 0
                then
                param_rec="$ind"; found=1

            elif test $(isDescending $i) -eq 1 -a "$param_dec" -eq 0
                then
                param_dec="$ind"; found=1

            elif test $(isSort $i) -eq 1 -a "$param_tri" -eq 0
                then
                param_tri="$ind"; save_tri="$i"; found=1
            fi
        else
            if test $(isDirectory $i) -eq 1 -a "$param_rep" -eq 0
                then
                param_rep="$ind"; save_rep="$i"; found=1
            fi
        fi
        # Si le paramètre n'est pas une option accepté, on sort du programme.
        test "$found" -eq 0 && echo "invalid option -- '$i'" && exit 3

        # on incrémente la position où l'on se trouve dans les paramètres.
        ind=`expr $ind + 1`
    done
    # Si il n'y a pas de répertoire ou si il n'est pas le dernier argument, on sort du programme.
    test "$param_rep" -eq 0 && echo "Need a directory as parameter" && exit 4
    test "$param_rep" -ne "$NB_PARAM" && echo "invalid -- '$save_rep must be the last parameter'" && exit 5
}

function nameFile() {
   # Fonction qui prend en paramètre un fichier et retourne son nom.
    local file=$(basename $1)
    echo ${file%%.*}
}

function sizeFile() {
    # Fonction qui prend en paramètre un fichier et retourne sa taille.
    local res;
    res=$(stat -c "%s" $1)

    test -z "$res" && echo 0 || echo "$res"
}

function lastDateFile() {
    # Fonction qui prend en paramètre un fichier et retourne la date de sa dernière modification.
    echo $(stat -c "%Y" $1)
}

function linesFile() {
    # Fonction qui prend en paramètre un fichier et retourne sa taille.
    # Si la taille est nul ou si il ne s'agit pas d'un fichier standart, on retourne 0.

    local res;
    
    if test \! -f "$1"
        then
        echo 0
    else
        res=$(sed -n '$=' $1)
        test -z "$res" && echo 0 || echo $res

    fi
}

function extensionFile() {
    # Fonction qui prend en paramètre un fichier et retourne son extension.
    echo ${1##*.}
}

function typeFile() {
    # Fonction qui prend en paramètre un fichier et retourne son type.
    # 1 : répertoire, 2 : fichier, 3 : liens, 4 : bloc, 5 : caractère, 6 : tube, 7 : socket

    # si c'est un répertoire.
    if test -d "$1"
        then
        echo 1
    # si c'est un fichier.
    elif test -f "$1"
        then
        echo 2
    # si c'est un lien symbolique.
    elif test -L "$1"
        then 
        echo 3
    # si c'est un fichier spécial de type bloc.
    elif test -b "$1"
        then
        echo 4
    # si c'est un fichier spécial de type caractère.
    elif test -c "$1"
        then
        echo 5
    # si c'est un tube nommé.
    elif test -p "$1"
        then
        echo 6
    # si c'est un socket.
    elif test -S "$1"
        then
        echo 7
    fi
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
        if test -d "$i" -a "$param_rec" -ne 0
        then
            chaine="$chaine$i$SEPARATOR$(createString "$i")"
        else
            chaine="$chaine$i$SEPARATOR"
        fi
    done
    echo "$chaine"
}

function countFiles() {
    # Fonction qui va parcourir une chaine de caractère passé en paramètre contenant des fichiers.
    # Et va retourner le nombre de ficheirs (séparé par le séparateur ":").

    local len=`expr length $1`;local ch
    local carac;local res=0
    for i in `seq 0 $len`
        do
        carac=${1:i:1}
        if test "$carac" == "$SEPARATOR"
            then
            res=`expr $res + 1`
            ch=""
        else
            ch="$ch$carac"
        fi
    done
    echo $res
}

function printString() {
    # Fonction qui va parcourir la chaine de caractère stringFiles contenant l'ensemble des fichiers du paramètres données.
    # Et va afficher les fichiers séparés par un séparateur ":"

    local i=1;local nbFiles=$(countFiles $1);local len_sort
    local file;local name;local size;local lines;local typ;local space1;local space2
    local space2;local ind=1;local car;

    # Si il n'y a pas d'otpion, on réglé la longueur a 1.
    test -z "$save_tri" && len_sort=1 || len_sort=`expr length $save_tri`

    # on affiche l'entête des données (nom).
    printf "Nom$(tput cuf 17)"

    # on affiche chaque entête selon les options en entrées.
    while test "$ind" -le "$len_sort"
        do
        car=${save_tri:ind:1}
        case "$car" in 
            "s") printf "| Taille $(tput cuf 8)";;
            "l") printf "| Nb Lignes $(tput cuf 5)";;
            "t") printf "| Type $(tput cuf 10)";;
            *);;
        esac
        ind=`expr $ind + 1`
    done
    # on affiche par defaut le chemin du ficheir également.
    printf "| Chemin\n"
    ind=1
    while test "$ind" -le "$len_sort"
        do
        printf "============================="
        ind=`expr $ind + 1`
    done
    printf "\n"
    for i in `seq 1 $nbFiles`
        do
        file="$(echo $1 | cut -d':' -f"$i")"
        name=$(basename $file);space1=`expr 20 - \( length $name \)`

        printf $name"$(tput cuf $space1)"
        ind=1
        while test "$ind" -le "$len_sort"
            do
            car=${save_tri:ind:1}
            case "$car" in 
                "s") size=$(sizeFile $file);space2=`expr 15 - \( length $size \)`;printf "| $size$(tput cuf $space2)";;
                "l") lines=$(linesFile $file);space2=`expr 15 - \( length $lines \)`;printf "| $lines$(tput cuf $space2)";;
                "t") typ=$(typeFile $file);space2=`expr 15 - \( length $typ \)`;printf "| $typ$(tput cuf $space2)";;
                *);;
            esac
            ind=`expr $ind + 1`
        done

        printf "| $file\n"
    done
}

function stringCompare() {
    # Fonction qui prend en paramètre deux chaine de caractère, et qui retourne
    # 1 si la première chaine est plus grande que le seconde, -1 si elle est plus petite,
    # ou 0 si les deux chaines sont égales.

    if test "$1" \> "$2"
        then
        echo 1
    elif test "$1" \< "$2"
        then
        echo -1
    else
        echo 0
    fi
}

function numCompare() {
    # Fonction qui prend en paramètre deux entiers, et qui retourne
    # 1 si le premier entier est supérieur au second,  -1 si il est inférieur,
    # ou 0 si les deux entiers sont égaux.
    if test "$1" -gt "$2" 
        then
        echo 1
    elif test "$1" -eq "$2"
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
    local newString;local word

    while test "$i" -ne 0
        do
        word=$(echo $1 | cut -d':' -f"$i")
        newString="$newString$word$SEPARATOR"
        i=`expr $i - 1`
    done
    echo "$newString"
}

function sortByOption() {
    # Fonction qui prend en paramètre une chaine de caractère de fichiers,
    # et va trier cette chaine selon le nom des fichiers. (méthode de tri par sélection)

    local newString="$1";local word;local word_mini;local ref;local tmp=0
    local len=$(countFiles $1);local i=1;local j;local mini=0;local val_word;local val_mini

    for i in `seq 1 $len`
        do
        mini="$i"
        j="$i"
        for j in `seq $i $len`
            do
            word=$(echo $newString | cut -d':' -f"$j")
            word_mini=$(echo $newString | cut -d':' -f"$mini")

            if test "$2" == "linesFile" -o "$2" == "sizeFile" -o "$2" == "typeFile"
                then
                test $(numCompare "$($2 $word)" "$($2 $word_mini)") -eq -1 && mini="$j"
            else
                test $(stringCompare "$($2 $word)" "$($2 $word_mini)") -eq -1 && mini="$j"
       
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
        "n") newString=$(sortByOption $1 nameFile);;

        # si on appel le critère "s", on exécute la fonction qui trie la chaine par la taille des entrées.
        "s") newString=$(sortByOption $1 sizeFile);;

        # si on appel le critère "m", on exécute la fonction qui trie la chaine par la taille des entrées.
        "m") newString=$(sortByOption $1 lastDateFile);;

        # si on appel le critère "sl", on exécute la fonction qui trie la chaine par la taille des entrées.
        "l") newString=$(sortByOption $1 linesFile);;

        # si on appel le critère "e", on exécute la fonction qui trie la chaine par la taille des entrées.
        "e") newString=$(sortByOption $1 extensionFile);;

        # si on appel le critère "e", on exécute la fonction qui trie la chaine par la taille des entrées.
        "t") newString=$(sortByOption $1 typeFile);;

        # si on appel le critère "p", on exécute la fonction qui trie la chaine par la taille des entrées.
        "p") newString=$(sortByOption $1 ownerFile);;

        # si on appel le critère "g", on exécute la fonction qui trie la chaine par la taille des entrées.
        "g") newString=$(sortByOption $1 groupFile);;
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

    # On crée et sauvegarde la chaine de caractère contenant l'ensemble des fichiers.
    stringFiles=$(createString "$save_rep")

    # On tri et sauvegarde la chaine de fichiers selon les critères de tris donnée en entrée.
    stringFiles=$(sortString $stringFiles 1) # 1 correspond au premier caractère de la chaine de critères de tri.
    
    # si la commande "-d" à été appelé, on exécute la fonction qui trie la chaine par ordre décroissant.
    test "$param_dec" -ne 0 && stringFiles=$(sortDescending $stringFiles)

    # on affiche l'ensemble des ficheirs triés.
    printString "$stringFiles"
}

# on appelle la fonction main pour lancer le programme
main
