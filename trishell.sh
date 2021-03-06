#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                     #
#                           Projet de Shell                           #
#       Réalisé par Quentin Carpentier & Paul-Joseph Krogulec         #
#   GitHub : https://github.com/pauljosephkrogulec/l3-shell-project   #
#                                                                     #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# on vérifie si il y a bien au moins un argument en paramètre et au plus 4 arguments.
test $# -lt 1 && echo "Need a command as parameter" && exit 1
test $# -ge 5 && echo "Too many parameters (4 max)" && exit 2

# Constantes
SEPARATOR=":"
NB_PARAM="$#"
ALL_PARAM="$@"
ALL_TRI="nsmletpg"      # on défini l'ensemble des critères de tris possibles.

# Déclaration des variables gloables.
param_rec=0         # Indique du paramètre si la commande -R est appelé, sinon 0.
param_dec=0         # Indique du paramètre si la commande -d est appelé, sinon 0.
param_tri=0         # Indique du paramètre si la commande -nsmletpg est appelé, sinon 0.
param_rep=0         # Indique du paramètre si on a bien un répertoire en paramètre, 0 sinon.

save_rep=""         # on sauvegarde le répertoire donné en paramètre.
save_options=""     # on sauvegarde les critères de tris donnés en paramètre.

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
    
    # déclaration de variables...
    local i=1;local j;local len_entree=`expr length $1`;local len_nsmletpg=`expr length $ALL_TRI`
    local valid=1;local carac1;local carac2;local found_type

    # on parcourt la chaine d'optino de tri et tant que chaque élements soit valide
    while test "$i" -lt "$len_entree" -a "$valid" -eq 1
        do
        # on récupérer le i caractère de la chaine en entrée
        carac1=${1:i:1};found_type=0;j=0

        # on le compare à chaque option possible
        while test "$j" -lt "$len_nsmletpg" -a "$found_type" -ne 1
            do
            # on récupérer le h caractère de la chaine sauvegardée
            carac2=${ALL_TRI:j:1}
            # et on compare els deux caractère, si ils sont égaux, on à trouvé et on s'arrête.
            test "$carac1" == "$carac2" && found_type=1
            # on incrémente j
            j=`expr $j + 1`
        done

        # si le caractère n'est pas une option de tri, on s'arrête et on met valide à faux.
        test "$found_type" -ne 1 && valid=0

        # on incrémente i
        i=`expr $i + 1`
    done
    
    # on retourne si c'est valide ou non (1, 0)
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

    # déclaration de variables...
    local ind=1;local found

    # pour chaque paramètre
    for i in $ALL_PARAM
        do
        # on remet found à 0 pour chaque paramètre.
        found=0
        # si c'est une commande..
        if test $(isCommand $i) -eq 1
            then
            # si il s'agit d'un appel -R et que l'on ne l'a pas déjà rencontré avant.
            if test $(isRecursif $i) -eq 1 -a "$param_rec" -eq 0
                then
                # on actualise le paramètre à 1 pour dire qu'on à rencontré un -R
                # et on dit qu'on a trouvé un paramètre valide (found = 1)
                param_rec="$ind"; found=1

            # si il s'agit d'un appel -d et que l'on ne l'a pas déjà rencontré avant.
            elif test $(isDescending $i) -eq 1 -a "$param_dec" -eq 0
                then
                # on actualise le paramètre à 1 pour dire qu'on à rencontré un -d
                # et on dit qu'on a trouvé un paramètre valide (found = 1)
                param_dec="$ind"; found=1

            # si il s'agit d'un appel d'une option de tri et que l'on ne l'a pas déjà rencontré avant.
            elif test $(isSort $i) -eq 1 -a "$param_tri" -eq 0
                then
                # on actualise le paramètre à 1 pour dire qu'on à rencontré une option de tri
                # et on dit qu'on a trouvé un paramètre valide (found = 1)
                param_tri="$ind"; save_options="$i"; found=1
            fi
        # si ce n'est pas une commande...
        else
            # on regarde si c'est bien un répertoire et qu'il n'y a pas encore eu de répertoire appelé
            if test $(isDirectory $i) -eq 1 -a "$param_rep" -eq 0
                then
                # on actualise le paramètre à 1 pour dire qu'on à rencontré un répertoire
                # et on dit qu'on a trouvé un paramètre valide (found = 1)
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

    local res

    # si ce n'est pas un fichier, on retourne 0 comme nombre de ligne.
    if test \! -f "$1"
        then
        echo 0
    # sinon on retourne le nombre de ligne du fichier.
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

    # déclaration de variables...
    local newString
    # pour chaque fichier du répertoire en paramètre..
    for i in "$1"/*
    do
        # on l'ajoute à la chaine.
        newString="$newString$i$SEPARATOR"
        # si c'est un répertoire, on rappel la chaine de manière récursiv (et on ajoute ce répertoire à la chaine)
        test -d "$i" -a "$param_rec" -ne 0 && newString="$newString$(createString "$i")"
    done

    # on retourne la chaine crée.
    echo "$newString"
}

function countFiles() {
    # Fonction qui va parcourir une chaine de caractère passé en paramètre contenant des fichiers.
    # Et va retourner le nombre de fichiers (séparé par le séparateur ":").
    
    # déclaration de variables...
    local len=`expr length $1`;local carac;local res=0
    for i in `seq 1 $len`
        do
        carac=${1:i:1}
        test "$carac" == "$SEPARATOR" && res=`expr $res + 1`
    done

    # on retourne le resultat.
    echo $res
}

function printString() {
    # Fonction qui va parcourir la chaine de caractère stringFiles contenant l'ensemble des fichiers du paramètres données.
    # Et va afficher les fichiers séparés par un séparateur ":"

    # déclaration de variables...
    local len_sort;local space;local car
    local file;local name;local size;local lines;local typ;local date;local owner;local group;

    # Si il n'y a pas d'otpion, on réglé la longueur a 1.
    test -z "$save_options" && len_sort=1 || len_sort=`expr length $save_options`

    # on affiche l'entête des données (nom).
    printf "Nom (.ext)$(tput cuf 10)"

    # on affiche chaque entête selon les options en entrées.
    for j in `seq 1 $len_sort`
        do
        car=${save_options:j:1}
        case "$car" in 
            "s") printf "| Taille $(tput cuf 8)";;
            "m") printf "| Derniere modif. $(tput cuf 8)";;
            "l") printf "| Nb Lignes $(tput cuf 5)";;
            "t") printf "| Type $(tput cuf 10)";;
            "p") printf "| Proprietaire $(tput cuf 9)";;
            "g") printf "| Groupe $(tput cuf 15)";;
            *);;
        esac
    done
    # on affiche par defaut le chemin du ficheir également.
    printf "| Chemin\n"
    for i in `seq 1 $(countFiles $1)`
        do
        file="$(echo $1 | cut -d':' -f"$i")"
        name=$(basename $file);space=`expr 20 - \( length $name \)`

        printf $name"$(tput cuf $space)"
        for j in `seq 1 $len_sort`
            do
            car=${save_options:j:1}
            case "$car" in 
                "s") size=$(sizeFile $file);space=`expr 15 - \( length $size \)`;printf "| $size$(tput cuf $space)";;
                "m") date="$(stat -c "%y" $file)";printf "| $(echo $date | cut -d' ' -f1)$(tput cuf 14)";;
                "l") lines=$(linesFile $file);space=`expr 15 - \( length $lines \)`;printf "| $lines$(tput cuf $space)";;
                "t") typ=$(typeFile $file);space=`expr 15 - \( length $typ \)`;printf "| $typ$(tput cuf $space)";;
                "p") owner=$(ownerFile $file);space=`expr 22 - \( length $owner \)`;printf "| $owner$(tput cuf $space)";;
                "g") group=$(groupFile $file);space=`expr 22 - \( length $group \)`;printf "| $group$(tput cuf $space)";;
                *);;
            esac
        done
        # le chemin d'accès au fichier.
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
    
    # déclaration de variables...
    local len=$(countFiles $1)
    local newString;local word

    # on parcourt la chaine dans le sens inverse
    for i in `seq 1 $len`
        do
        # et on ajoute à chaque fois en début de chaine.
        word=$(echo $1 | cut -d':' -f"$i")
        newString="$word$SEPARATOR$newString"
    done

    # on retourne la chaine
    echo "$newString"
}

function swapFile() {
    # Fonction qui prend en paramètre une chaine de caractère contenant les fichiers et deux indices.
    # La fonction va inverser les deux fichiers selon leurs indices et retourner la nouvelle chaine.

    # déclaration de variables...
    local newString="$1"
    local word_1=$(echo $newString | cut -d':' -f"$2")
    local word_2=$(echo $newString | cut -d':' -f"$3")

    # on inverse les fichiers dans la chaine
    newString=$(awk -v a="$word_2" 'BEGIN{FS=OFS=":"} {$'$2'=a; print}' <<< "$newString")
    newString=$(awk -v a="$word_1" 'BEGIN{FS=OFS=":"} {$'$3'=a; print}' <<< "$newString")

    # on retourne la chaine
    echo "$newString"
}

function sortByOption() {
    # Fonction qui prend en paramètre une chaine de caractère de fichiers,
    # et va trier cette chaine selon le nom des fichiers. (méthode de tri par sélection)

    # déclaration de variables...
    local newString="$1";local word;local word_mini
    local len=$(countFiles $1);local i=1;local j;local mini=0

    for i in `seq 1 $len`
        do
        mini="$i"
        j=`expr $i + 1`
        for j in `seq $i $len`
            do
            word=$(echo $newString | cut -d':' -f"$j")
            word_mini=$(echo $newString | cut -d':' -f"$mini")

            # pour le cas, si on compare des données de type nombres.
            if test "$2" == "linesFile" -o "$2" == "sizeFile" -o "$2" == "typeFile"
                then
                test $(numCompare "$($2 $word)" "$($2 $word_mini)") -eq -1 && mini="$j"

            # pour le cas, si on compare des données de type chaine.
            else
                test $(stringCompare "$($2 $word)" "$($2 $word_mini)") -eq -1 && mini="$j"
            fi
        done

        # on inverse les fichiers dans la chaine
        newString=$(swapFile $newString $i $mini)
    done

    # on retourne la chaine
    echo "$newString"
}

function equals() {
    # Prend en paramètre une chaine de caractère, un appel de fonction et l'indice de l'option de tri.
    # La fonction va parcourir la chaine et trier les élements identiques en appelant l'option de tri suivante.
    
    # déclaration de variables...
    local newString;local len=$(countFiles $1);local word=$(echo $1 | cut -d':' -f1)
    local ind=$($2 $word);local tmp;local k=`expr $3 + 1`

    # pour le cas, si on compare des données de type nombres.
    if test "$2" == "linesFile" -o "$2" == "sizeFile" -o "$2" == "typeFile"
        then
        for i in `seq 1 $len`
            do
            word=$(echo $1 | cut -d':' -f"$i")
            if test $(numCompare $($2 $word) $ind) -ne 0
                then
                if test $(countFiles $tmp) -ne 1
                    then
                    newString=$newString$(sortString $tmp $k)
                else
                    newString="$newString$tmp"
                fi
                tmp=""
                ind=$($2 $word)
            fi
            tmp="$tmp$word$SEPARATOR"
        done
    
    # pour le cas, si on compare des données de type chaine.
    else
        for i in `seq 1 $len`
            do
            word=$(echo $1 | cut -d':' -f"$i")
            if test $(stringCompare "$($2 $word)" "$ind") -ne 0
                then
                if test $(countFiles $tmp) -ne 1
                    then
                    newString=$newString$(sortString $tmp $k)
                else
                    newString="$newString$tmp"
                fi
                tmp=""
                ind=$($2 $word)
            fi
            tmp="$tmp$word$SEPARATOR"
        done
    fi
    
    test $(countFiles $tmp) -ne 1 && newString=$newString$(sortString $tmp $k) || newString="$newString$tmp"

    # on retourne la chaine
    echo "$newString"
}

function sortString {
    # Fonction qui ne prend rien en paramètre,
    # et effectue pour chaque commande passé en entrée, le trie sur la chaine de caractère contenant les fichiers.
    
    # déclaration de variables...
    local i="$2";i_p=`expr $i + 1`
    local option=${save_options:i:1};local option2=${save_options:i_p:1};local newString="$1"

    # en fonction du critère du tri appelé...
    case "$option" in 
        # si on appel le critère "n", on exécute la fonction qui trie la chaine par nom des entrées.
        "n") newString=$(sortByOption $1 nameFile);test \! -z $option2 && newString=$(equals $newString nameFile $2);;

        # si on appel le critère "s", on exécute la fonction qui trie la chaine par la taille des entrées.
        "s") newString=$(sortByOption $1 sizeFile);test \! -z $option2 && newString=$(equals $newString sizeFile $2);;

        # si on appel le critère "m", on exécute la fonction qui trie la chaine par la taille des entrées.
        "m") newString=$(sortByOption $1 lastDateFile);test \! -z $option2 && newString=$(equals $newString lastDateFile $2);;

        # si on appel le critère "sl", on exécute la fonction qui trie la chaine par la taille des entrées.
        "l") newString=$(sortByOption $1 linesFile);test \! -z $option2 && newString=$(equals $newString linesFile $2);;

        # si on appel le critère "e", on exécute la fonction qui trie la chaine par la taille des entrées.
        "e") newString=$(sortByOption $1 extensionFile);test \! -z $option2 && newString=$(equals $newString extensionFile $2);;

        # si on appel le critère "e", on exécute la fonction qui trie la chaine par la taille des entrées.
        "t") newString=$(sortByOption $1 typeFile);test \! -z $option2 && newString=$(equals $newString typeFile $2);;

        # si on appel le critère "p", on exécute la fonction qui trie la chaine par la taille des entrées.
        "p") newString=$(sortByOption $1 ownerFile);test \! -z $option2 && newString=$(equals $newString ownerFile $2);;

        # si on appel le critère "g", on exécute la fonction qui trie la chaine par la taille des entrées.
        "g") newString=$(sortByOption $1 groupFile);test \! -z $option2 && newString=$(equals $newString groupFile $2);;
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
