# bash-tools-framework

> **_NOTE:_** **Documentation is best viewed on
> [github-pages](https://fchastanet.github.io/bash-tools-framework/)**

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD013 -->

[![CI/CD](https://github.com/fchastanet/bash-tools-framework/actions/workflows/lint-test.yml/badge.svg)](https://github.com/fchastanet/bash-tools-framework/actions?query=workflow%3A%22Lint+and+test%22+branch%3Amaster)
[![Project Status](http://opensource.box.com/badges/active.svg)](http://opensource.box.com/badges)
[![DeepSource](https://deepsource.io/gh/fchastanet/bash-tools-framework.svg/?label=active+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/bash-tools-framework/?ref=repository-badge)
[![DeepSource](https://deepsource.io/gh/fchastanet/bash-tools-framework.svg/?label=resolved+issues&show_trend=true)](https://deepsource.io/gh/fchastanet/bash-tools-framework/?ref=repository-badge)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/fchastanet/bash-tools-framework.svg)](http://isitmaintained.com/project/fchastanet/bash-tools-framework 'Average time to resolve an issue')
[![Percentage of issues still open](http://isitmaintained.com/badge/open/fchastanet/bash-tools-framework.svg)](http://isitmaintained.com/project/fchastanet/bash-tools-framework 'Percentage of issues still open')

<!-- markdownlint-restore -->

- [1. Excerpt](#1-excerpt)
- [2. Installation/Configuration](#2-installationconfiguration)
- [3. Development Environment](#3-development-environment)
  - [3.1. Install dev dependencies](#31-install-dev-dependencies)
  - [3.2. UT](#32-ut)
  - [3.3. auto generated bash doc](#33-auto-generated-bash-doc)
  - [3.4. github page](#34-github-page)
- [4. Acknowledgements](#4-acknowledgements)

## 1. Excerpt

This is a collection of several bash tools using a bash framework allowing to
easily import bash script, log, display log messages, database manipulation,
user interaction, version comparison, ...

List of tools:

- **gitRenameBranch** : easy rename git local branch, use options to push new
  branch and delete old branch
- **cli** : easy connection to docker container
- **dbImport** : Import db from aws dump or mysql into target db
- **dbImportTable** : Import remote db table from aws or mysql into target db
- **dbQueryAllDatabases** : Execute a query on multiple database in order to
  generate a report, query can be parallelized on multiple databases
- **dbScriptAllDatabases** : same as dbQueryAllDatabases but you can execute an
  arbitrary script on each database
- **gitIsAncestor** : show an error if commit is not an ancestor of branch
- **gitIsBranch** : show an error if branchName is not a known branch
- **gitRenameBranch** : rename git local branch, use options to push new branch
  and delete old branch
- **waitForIt** : useful in docker container to know if another container port
  is accessible
- **waitForMysql** : useful in docker container to know if mysql server is ready
  to receive queries

## 2. Installation/Configuration

clone this repository and create configuration files in your home directory
alternatively you can use the **install.sh** script

```bash
git clone git@github.com:fchastanet/bash-tools.git
cd bash-tools
./install.sh
```

The following structure will be created in your home directory

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD033 -->
<pre>
~/.bash-tools/
├── cliProfiles
│   ├── default.sh
│   ├── mysql.remote.sh
│   ├── mysql.sh
├── dbImportDumps
├── dbImportProfiles
│   ├── all.sh
│   ├── default.sh
│   ├── none.sh
├── dbQueries
│   └── databaseSize.sql
├── dsn
│   └── default.local.env
│   └── default.remote.env
│   └── localhost-root.env
└── .env
</pre>
<!-- markdownlint-restore -->

Some tools need [GNU parallel software](https://www.gnu.org/software/parallel/),
it allows running multiple processes in parallel. You can install it running

```bash
sudo apt update
sudo apt install -y parallel
# remove parallel nagware
mkdir ~/.parallel
touch ~/.parallel/will-cite
```

## 3. Development Environment

### 3.1. Install dev dependencies

Dev dependencies are automatically installed when used

`bin/test` script will install the following libraries inside `vendor` folder:

- [bats-core/bats-core](https://github.com/bats-core/bats-core.git)
- [bats-core/bats-support](https://github.com/bats-core/bats-support.git)
- [bats-core/bats-assert](https://github.com/bats-core/bats-assert.git)
- [Flamefire/bats-mock](https://github.com/Flamefire/bats-mock.git)

`./bin/doc` script will install:

- [fchastanet/tomdoc.sh](https://github.com/fchastanet/tomdoc.sh.git)

To avoid checking for libraries update and have an impact on performance, a file
is created in vendor dir.

- `vendor/.tomdocInstalled`
- `vendor/.batsInstalled` You can remove these files to force the update of the
  libraries, or just wait 24 hours that the timeout expires.

### 3.2. UT

All the methods of this framework are unit tested, you can run the unit tests
using the following command

```bash
./test.sh
```

### 3.3. auto generated bash doc

generated by running

```bash
./bin/doc
```

### 3.4. github page

Launch locally

```bash
sudo apt-get install ruby-dev
sudo gem install bundler
bundle install
bundle exec jekyll serve --source jekyll
```

Navigate to <http://localhost:4000/>

## 4. Acknowledgements

Like so many projects, this effort has roots in many places.

I would like to thank particularly Bazyli Brzóska for his work on the project
[Bash Infinity](https://github.com/niieani/bash-oo-framework). Framework part of
this project is largely inspired by his work(some parts copied). You can see his
[blog](https://invent.life/project/bash-infinity-framework) too that is really
interesting
