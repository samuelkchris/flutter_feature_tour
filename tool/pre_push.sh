#!/bin/bash

echo "Running pre-push checks..."

# Format code
echo "Formatting code..."
dart format .
if [ $? -ne 0 ]; then
    echo "Error: Code formatting failed"
    exit 1
fi

# Analyze code
echo "Analyzing code..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "Error: Code analysis failed"
    exit 1
fi

## Run tests
#echo "Running tests..."
#flutter test
#if [ $? -ne 0 ]; then
#    echo "Error: Tests failed"
#    exit 1
#fi

# Check package
echo "Checking package..."
flutter pub publish --dry-run
if [ $? -ne 0 ]; then
    echo "Error: Package validation failed"
    exit 1
fi

echo "All checks passed! Ready to push."