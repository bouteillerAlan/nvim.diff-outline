# diff-outline

Highlight Git conflict markers in green, yellow, and red. The two sides get background-only tints that disappear when the conflict is no longer complete.

## Install with lazy.nvim

Add [`bouteillerAlan/nvim.diff-outline`](https://github.com/bouteillerAlan/nvim.diff-outline) to your plugin specs:

```lua
{
  "bouteillerAlan/nvim.diff-outline",
  main = "diff-outline",
  dependencies = { "nvim-mini/mini.hipatterns" },
  opts = {},
}
```

`diff-outline` configures `mini.hipatterns`. Pass any additional `mini.hipatterns` settings, including extra highlighters, in `opts` rather than calling its setup separately.
