# projtasks.nvim
My personal, simple task-running and terminal plugin for neovim.

## Usage
Commands:
- `require('projtasks').toggle_terminal_direction()` - Toggle the terminal direction (horizonta/vertical)
- `require("projtasks").toggle()` - Toggle the terminal view
- `require("projtasks").setup({})` - Load projtasks
- Task-running:
  - `require("projtasks").term_run()` - Run the `run` task
  - `require("projtasks").term_build()` - Run the `build` task
  - `require("projtasks").term_test()` - Run the `test` task
  - `require("projtasks").term_bench()` - Run the `bench` task
  - `require("projtasks").term_profile()` - Run the `profile` task

 As this is my personal plugin, there is currently no way to add a call for a custom task, although such a feature could easily be added if requested.

## Plugin Spec
```lua
local default_config = {
    defaults = {}, -- Specify per-filetype default tasks
    terminal_config = {
        direction = "horizontal",
        size = {
            vertical = 70,
            horizontal = 20,
        }
    }
    static_config = {
        direction = "vertical",
        size = {
            vertical = 70,
            horizontal = 20,
        }
    }
}
```

## A sample `projfile.lua`
```lua
return {
    ["version"] = "0.1.1",
    ["tasks"] = {
        ["run"] = { [[cargo run --release]] },
        ["build"] = { [[cargo build --release]] },
        ["test"] = {
            -- Commands don't have to be flattened
            {
                [[./test_a > test/out/a.out]]
                [[diff test/out/a.out test/out/a.out.correct]]
            },
            {
                [[./test_b > test/out/b.out]]
                [[diff test/out/b.out test/out/b.out.correct]]
            },
        },
        ["bench"] = { [[cargo bench]] },
        ["profile"] = {
            [[cargo build --release]],
            [[your_profiler ./target/release/your_project]],
        },
    },
}
```
## Programatically building a command
```lua
local build = {
    [[g++ ]],
    [[-std=c++20 ]],
    [[-O3 ]],
    [[-g ]],
    [[-Wall ]],
    [[-Wpedantic ]],

    [[src/Window.cpp ]],
    [[src/Color.cpp ]],
    [[src/Effects.cpp ]],
    [[src/Mesh.cpp ]],
    [[src/Texture.cpp ]],

    [[-lsfml-graphics ]],
    [[-lsfml-window ]],
    [[-lsfml-system ]],

    [[-Xclang ]],
    [[-fopenmp ]],
    [[-lomp ]],

    [[-o bin/out ]],
    [[src/main.cpp ]],
}
local build_command = table.concat(build)
return {
    ["version"] = "0.1.1",
    ["tasks"] = {
        ["run"] = {
            [[./bin/rasterbox]],
        },
        ["build"] = { build_command },
    },
}
```
