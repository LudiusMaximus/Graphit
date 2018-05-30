local L = LibStub("AceLocale-3.0"):NewLocale("Graphit", "deDE")
if not L then return end

L["This is Graphit!"] = "Das ist Graphit!"
L["Loaded!"] = "Geladen!"

L["TODO"] = true


-- AE: \195\132
-- OE: \195\150
-- UE: \195\156
-- ae: \195\164
-- oe: \195\182
-- ue: \195\188
-- sz: \195\159

L["Resize"] = "H\195\182he ver\195\164ndern"

L["shadowModeTooltip"] = "Bestimmt, wie viele Schatten gezeichnet werden."
L["shadowTextureSizeTooltip"] = "Bestimmt, ob Schatten mit niedriger und h\195\182herer Aufl\195\182sung gezeichnet werden."
L["shadowSoftTooltip"] = "Bestimmt, ob Schatten weicher gezeichnet werden. (Abh\195\164ngig von den anderen Schatteneinstellungen ist es schwer, \195\188beraupt einen Unterschied zu bemerken.)"

L["worldBaseMipTooltip"] = "Bestimmt die Detailiertheit von Terrain-Texturen. |cffff0000(Das Spiel kann kurz h\195\164ngen, nachdem die Option ge\195\164ndert wird.)"
L["terrainMipLevelTooltip"] = "Bestimmt die Qualit\195\164t von Textur-\195\156berg\195\164ngen im Terrain. |cffff0000(Das Spiel kann kurz h\195\164ngen, wenn zu 'low' gewechselt wird, w\195\164hrend worldBaseMipTooltip auf 'high' ist.)"
L["componentTextureLevelTooltip"] = "Bestimmt die Detailiertheit von Player-Texturen wie R\195\188stungen. Scheint nur einen Effekt bei R\195\188stungen neuerer WoW-Erweiterungen zu haben. |cffff0000(Das Spiel kann kurz h\195\164ngen, wenn zu 'low' gewechselt wird, w\195\164hrend worldBaseMipTooltip auf 'high' ist.)"

L["graphicsTextureFilteringTooltip"] = "Verbessert die Sch\195\164rfe von Texturen, insbesondere wenn diese schr\195\164g von der Seite angeschaut werden."
L["projectedTexturesTooltip"] = "Legt fest, ob Texturen auf die Umgebung projeziert werden; z.B. bei bestimmten AoE spells."




L["graphicsDepthEffects"] = "Falls jemand rausfindet, was das eigentlich macht, w\195\164re ich sehr interessiert! :-)"
L["ffxAntiAliasingMode"] = "Hei\195\159t Post-Process AA in den Settings. Sorgt f\195\188r Weichzeichnen."