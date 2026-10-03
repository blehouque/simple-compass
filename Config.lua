-- User-adjustable compass dimensions, defaults, and labels.
local _, addon = ...

addon.Config = {
    BarWidth = 220,
    BarHeight = 40,
    DegreesVisible = 120,
    MarkerStep = 15,
    UpdateInterval = 0.05,
    Defaults = {
        point = "TOP",
        x = 0,
        y = -120,
        locked = false,
    },
    Cardinals = {
        [0] = "N",
        [45] = "NO",
        [90] = "O",
        [135] = "SO",
        [180] = "S",
        [225] = "SE",
        [270] = "E",
        [315] = "NE",
    },
}