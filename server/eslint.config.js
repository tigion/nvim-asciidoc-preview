import globals from "globals";
import pluginJs from "@eslint/js";

export default [
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.commonjs,
        ...globals.node,
      },
      // ecmaVersion: 12,
      // sourceType: "commonjs",
    },
  },

  pluginJs.configs.recommended,

  {
    rules: {
      "no-unused-vars": [
        "warn",
        { vars: "all", args: "none", ignoreRestSiblings: false },
      ],
      "no-undef": "warn",
    },
  },
];
