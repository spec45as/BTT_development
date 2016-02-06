return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 6,
  height = 6,
  tilewidth = 64,
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../layout_source/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../layout_source/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 128,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 6,
      height = 6,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 6, 6, 6, 0, 0,
        6, 6, 6, 6, 6, 0,
        6, 6, 5, 5, 6, 6,
        6, 6, 5, 5, 6, 6,
        0, 6, 6, 6, 6, 6,
        0, 6, 6, 6, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "firepit",
          shape = "rectangle",
          x = 191,
          y = 189,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "log_chunk",
          shape = "rectangle",
          x = 139,
          y = 146,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "tent_cone",
          shape = "rectangle",
          x = 54,
          y = 165,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "note3",
          shape = "rectangle",
          x = 122,
          y = 232,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "batteries",
          shape = "rectangle",
          x = 253,
          y = 251,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "blood1",
          shape = "rectangle",
          x = 132,
          y = 240,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "blood3",
          shape = "rectangle",
          x = 125,
          y = 225,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
