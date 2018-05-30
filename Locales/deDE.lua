local L = LibStub("AceLocale-3.0"):NewLocale("Graphit", "deDE")
if not L then return end

L["This is Graphit!"] = "Das ist Graphit!"
L["Loaded!"] = "Geladen!"

L["TODO"] = true

L["Resize"] = "H\195\182he ver\195\164ndern"

L["shadowModeTooltip"] = "Bestimmt, wie viele Schatten gezeichnet werden."
L["shadowTextureSizeTooltip"] = "Bestimmt, ob Schatten mit niedriger und höherer Auflösung gezeichnet werden."
L["shadowSoftTooltip"] = "Bestimmt, ob Schatten weicher gezeichnet werden. (Abhängig von den anderen Schatteneinstellungen ist es schwer, überaupt einen Unterschied zu bemerken.)"

L["worldBaseMipTooltip"] = "Bestimmt die Detailiertheit von Terrain-Texturen. (Das Spiel kann kurz hängen, nachdem die Option geändert wird.)"
L["terrainMipLevelTooltip"] = "Bestimmt die Qualität von Textur-Übergängen im Terrain. (Das Spiel kann kurz hängen, wenn zu 'low' gewechselt wird, während worldBaseMipTooltip auf 'high' ist.)"
L["componentTextureLevelTooltip"] = "Bestimmt die Detailiertheit von Player-Texturen wie Rüstungen. Scheint nur einen Effekt bei Rüstungen neuerer WoW-Erweiterungen zu haben. (Das Spiel kann kurz hängen, wenn zu 'low' gewechselt wird, während worldBaseMipTooltip auf 'high' ist.)"

L["graphicsTextureFilteringTooltip"] = "Verbessert die Schärfe von Texturen, insbesondere wenn diese schräg von der Seite angeschaut werden."
L["projectedTexturesTooltip"] = "Legt fest, ob Texturen auf die Umgebung projeziert werden; z.B. bei bestimmten AoE spells."




L["graphicsDepthEffects"] = "Falls jemand rausfindet, was das eigentlich macht, wäre ich sehr interessiert! :-)"
L["ffxAntiAliasingMode"] = "Heißt Post-Process AA in den Settings. Sorgt für Weichzeichnen."