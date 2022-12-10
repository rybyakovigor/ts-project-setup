#!/usr/bin/env bash

function createEditorConfig() {
  echo 'root = true

[*]
charset = utf-8
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
max_line_length = off
trim_trailing_whitespace = false' >.editorconfig
}

function installPrettier() {
  echo "...Установка prettier"
  case $1 in
  "Yarn")
    yarn add -D prettier
    ;;
  "Npm")
    npm install -save-dev prettier
    ;;
  esac
}

function createPrettierConfig() {
  echo '{
  "arrowParens": "always",
  "bracketSpacing": true,
  "embeddedLanguageFormatting": "auto",
  "htmlWhitespaceSensitivity": "css",
  "insertPragma": false,
  "jsxSingleQuote": false,
  "printWidth": 120,
  "proseWrap": "preserve",
  "quoteProps": "as-needed",
  "requirePragma": false,
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "useTabs": false,
  "vueIndentScriptAndStyle": false
}' >.prettierrc
}

function installEslint() {
  echo "...Установка eslint"
  case $1 in
  "Yarn")
    yarn add -D eslint
    yarn add -D @typescript-eslint/eslint-plugin
    yarn add -D @typescript-eslint/parser
    yarn add -D eslint-plugin-prettier
    yarn add -D eslint-config-prettier
    ;;
  "Npm")
    npm install -save-dev eslint
    npm install -save-dev @typescript-eslint/eslint-plugin
    npm install -save-dev @typescript-eslint/parser
    npm install -save-dev eslint-plugin-prettier
    npm install -save-dev eslint-config-prettier
    ;;
  esac
}

function createEslintConfig() {
  echo '{
  "root": true,
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": [
      "./tsconfig.json"
    ]
  },
  "plugins": [
    "@typescript-eslint"
  ],
  "rules": {
    "no-console": [
      "error",
      {
        "allow": [
          "warn",
          "error"
        ]
      }
    ],
    "prettier/prettier": "off"
  },
  "ignorePatterns": [
    "src/**/*.test.ts"
  ]
}' >.eslintrc
}

function insrallStylelint() {
  echo "...Установка stylelint"
  case $1 in
  "Yarn")
    yarn add -D stylelint
    yarn add -D stylelint-config-standard
    yarn add -D stylelint-order
    yarn add -D stylelint-config-recess-order
    ;;
  "Npm")
    npm install -save-dev stylelint
    npm install -save-dev stylelint-config-standard
    npm install -save-dev stylelint-order
    npm install -save-dev stylelint-config-recess-order
    ;;
  esac
}

function createStylelintConfig() {
  echo '{
  "plugins": ["stylelint-order"],
  "extends": ["stylelint-config-standard", "stylelint-config-recess-order"],
  "ignoreFiles": ["node_modules"],
  "rules": {}
}' >.stylelintrc
}

function installHusky() {
  echo "...Установка husky"
  case $1 in
  "Yarn")
    npx husky-init && yarn
    ;;
  "Npm")
    npx husky-init && npm
    ;;
  esac
}

function installCommitLint() {
  echo "...Установка CommitLint"
  case $1 in
  "Yarn")
    yarn add -D @commitlint/{config-conventional,cli}
    ;;
  "Npm")
    npm install -save-dev @commitlint/{config-conventional,cli}
    ;;
  esac

  echo "module.exports = {extends: ['@commitlint/config-conventional']}" >commitlint.config.js
  npx husky add .husky/commit-msg
}

function createHuskyConfigs() {

  case $1 in
  "Yarn")
    echo '#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

yarn tsc
yarn lint
yarn prettier' >.husky/pre-commit

    if [[ "$2" == "Да" ]]; then
      echo 'yarn stylelint' >>.husky/pre-commit
    fi
    ;;
  "Npm")
    echo '#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npm run tsc
npm run lint
npm run prettier' >.husky/pre-commit

    if [[ "$2" == "Да" ]]; then
      echo 'npm run stylelint' >>.husky/pre-commit
    fi
    ;;
  esac

  echo '#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npx --no-install commitlint --edit "$1"' >.husky/commit-msg
}

function writeScriptsToPackageJson() {
  sed -i '' 's/\("scripts":\).*/\1 {\n    "prettier": "prettier --check src",/' package.json
  sed -i '' 's/\("scripts":\).*/\1 {\n    "prettier:fix": "prettier --write src",/' package.json

  sed -i '' 's/\("scripts":\).*/\1 {\n    "lint": "eslint src",/' package.json
  sed -i '' 's/\("scripts":\).*/\1 {\n    "lint:fix": "eslint src --fix",/' package.json

  sed -i '' 's/\("scripts":\).*/\1 {\n    "tsc": "tsc --noEmit",/' package.json

  if [[ "$1" == "Да" ]]; then
    sed -i '' 's%\("scripts":\).*%\1 {\n    "stylelint": "stylelint src/**/*.css",%' package.json
    sed -i '' 's%\("scripts":\).*%\1 {\n    "stylelint:fix": "stylelint src/**/*.css --fix",%' package.json
  fi
}


echo "Выберите пакетный менеджер: "
manager_options=(
  "Yarn"
  "Npm"
)

select manager in "${manager_options[@]}"; do
  createEditorConfig

  installPrettier $manager
  createPrettierConfig

  installEslint $manager
  createEslintConfig

  echo "Устанавливаем stylelint?: "
  stylelint_options=(
    "Да"
    "Нет"
  )
  select stylelint_answer in "${stylelint_options[@]}"; do
    if [[ "$stylelint_answer" == "Да" ]]; then
      echo "Установка stylelint"

      insrallStylelint $manager
      createStylelintConfig
    fi
    break
  done

  installHusky $manager
  installCommitLint $manager
  createHuskyConfigs $manager $stylelint_answer

  writeScriptsToPackageJson $stylelint_answer

  echo "Установка завершена"
  break
done
