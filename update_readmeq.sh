#!/bin/bash

# Change to the directory containing the repository
cd /Users/mac/StudioProjects/flutter_feature_tour

# Loop to make 100 changes
for i in {1..500}
do
  # Add a random word to the README.md file
  echo "RandomWord$RANDOM" >> README.md

  # Add changes to git
  git add README.md

  # Commit the changes
  git commit -m "Auto-update README with random word $i"

  # Push the changes
  git push origin master

  # Wait for 2 minutes before the next iteration
  sleep 20
done