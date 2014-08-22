-- This example script makes sure LNVL can change the background
-- images for scenes dynamically as we go through the scene's content.

START = Scene {
    background = "examples/images/Celestial-Background.jpg",
    "I am seriously over-engineering all of this.",
    ChangeSceneBackgroundTo "examples/images/Sunny-Hill.jpg",
    "Seriously.  I am.",
}
