#!/bin/bash

lovewindowspath="/home/etn/.dev/love2d/windows-exe"
path=""

if [ -f "./main.lua" ]; then
  path=$(pwd)
else
  path=`zenity --file-selection --directory --title="Sélectionner le dossier du jeu LÖVE"`
fi

name=$(basename $path)

## Déplacement dans le répertoire d'export
cd $path

## Barre de progression
#zenity --progress --text="Exportation de \"$name\" en cours..." --pulsate --auto-close --no-cancel

if [ -f "./main.lua" ]; then
  ## Suppression de l'éventuel ancien répertoire d'export
  rm -rf "./export"
  
  ## Création du fichier LÖVE
  #echo "Création du fichier LÖVE '$name.love'"
  zip -9 -q -r "$name.love" "."

  ## Création du répertoire d'export et déplacement dans celui-ci
  mkdir -p "./export"
  cd "./export"
  mv "../$name.love" "."

  ## Création de l'exécutable et copie des DLLs
  #echo "Création de l'exécutable Windows '$name.exe'"
  cat "$lovewindowspath/love.exe" "$name.love" > "$name.exe"

  ## Copie des DLLs
  #echo "Copie des DLLs"
  if [ -f "$lovewindowspath/DevIL.dll" ];
    [ -f "$lovewindowspath/OpenAL32.dll" ];
    [ -f "$lovewindowspath/SDL.dll" ]; then
    
    cp "$lovewindowspath/DevIL.dll" "."
    cp "$lovewindowspath/OpenAL32.dll" "."
    cp "$lovewindowspath/SDL.dll" "."

    ## Création d'un zip avec les DLL "prêt à envoyer"
    #echo "Création de l'archive ZIP pour Windows '$name-win.zip'"
    zip -9 -q -r "$name-win.zip" "$name.exe" "DevIL.dll" "OpenAL32.dll" "SDL.dll"

    #echo 100
    #echo "Terminé, les fichiers se trouvent dans le répertoire 'export/' du jeu."
    zenity --notification --timeout=1 --text="\"$name\" exporté avec succès."
    
    exit 0
  else
    zenity --error --text="Impossible d'exporter \"$name\" pour Windows,
 car le répertoire \"$lovewindowspath\"
 ne contient pas les fichiers requis ou n'existe pas."
    exit 1
  fi
else
  zenity --error --text="Impossible d'exporter \"$name\"."
  exit 1
fi
