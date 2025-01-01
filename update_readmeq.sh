#!/bin/bash

# Change to the directory containing the repository
cd /Users/mac/StudioProjects/LoveGrow/lovegrow

# Loop to make 50 changes
for i in {1..100}
do
  # Add a random word to the README.md file
  echo "RandomWord$RANDOM" >> README.md

  # Add changes to git
  git add README.md

  # Commit the changes
  git commit -m "Auto-update README with random word $i"

  # Push the changes
  git push origin main
done