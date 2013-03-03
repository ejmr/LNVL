-- This example script demonstrates how we can change some global
-- settings in the script itself, without modifying the
-- 'src/settings.lua' file.

-- Explicitly disable debugging mode.
LNVL.Settings.DebugModeEnabled = false

-- Change global settings for all scenes.
LNVL.Settings.Scenes.TextColor = Color.Blue
LNVL.Settings.Scenes.BorderSize = 0

-- Use two scenes to make sure the changes above affect all scenes.

START = Scene {
    "This text should appear in blue.",
    ChangeToScene "END",
}

END = Scene {
    "With no border around the dialog box.",
}
