-- This script tests LNVL's reserved keyword mechanic.  Running this
-- script should always produce an error because it attempts to
-- re-define keywords which LNVL considers reserved.  See the comments
-- in 'LNVL.lua' regarding the 'LNVL.ReservedKeywords' table for more
-- information, along with the checkReservedKeywordTypes() function.

-- Ideally this should trigger an error but under the current
-- circumstances it does not.  See the commit
--
--     [Feature] Protect against dialog scripts redefining reserved keywords
--
-- for details about why this does cause an error.
Scene = function () end

-- This should always trigger an error.
Character = "Not the Character constructor."

START = Scene {}
