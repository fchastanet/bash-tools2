<?php

return [
  'defaultCommandConfig' => [
    'author' => '[François Chastanet](https://github.com/fchastanet)',
    'sourceFile' => '${REPOSITORY_URL}/tree/master/${SRC_FILE_PATH}',
    'license' => 'MIT License',
    'copyright' => 'copyrightCallback',
    'optionGroups' => [
      [
        'title' => 'GLOBAL OPTIONS:',
        'functionName' => 'zzzGroupGlobalOptionsFunction',
      ],
    ],
    'includes' => [
      'default.options.tpl' => true,
    ],
  ],
  'defaultCommandOptions' => [
    [
      'variableName' => 'optionHelp',
      'group' => 'zzzGroupGlobalOptionsFunction',
      'type' => 'Boolean',
      'help' => 'Display this command help',
      'alts' => ['--help','-h',],
      'callbacks' => [
        'optionHelpCallback',
      ],
    ],
  ],
];
