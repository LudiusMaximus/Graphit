local L = LibStub("AceLocale-3.0"):NewLocale("Graphit", "deDE")
if not L then return end

L["Resize"] = "H\195\182he ver\195\164ndern"

L["horizonStartTooltip"] = "Bestimmt, bis zu welcher Distanz die Spielwelt gerendert wird. Maximalwerte haben nur einen Effekt, wenn farclip auch maximal eingestellt ist."
L["farclipTooltip"] = "Bestimmt, wie die Umgebung um den Horizont herum gerendert wird. Maximalwerte haben nur einen Effekt, wenn horizonStart auch maximal eingestellt ist."

L["lodObjectCullDistTooltip"] = "Objekte, die weiter entfernt sind als dieser Wert, werden ausgeblendet. Die Blizzard-Settings lassen es auf 30 f\195\188r fast alle Voreinstellungen. Interagiert mit lodObjectCullSize. |cffff0000(Das Ver\195\164ndern dieser Einstellung kann dazu f\195\188hren, dass alle Objekte kurz verschwinden, bevor sie neu gezeichnet werden.)"
L["lodObjectCullSizeTooltip"] = "Objekte, die kleiner als dieser Wert erscheinen w\195\188rden, werden ausgeblendet. Interagiert mit lodObjectCullDist. |cffff0000(Das Ver\195\164ndern dieser Einstellung kann dazu f\195\188hren, dass alle Objekte kurz verschwinden, bevor sie neu gezeichnet werden.)"
L["lodObjectMinSizeTooltip"] = "Wenn lodObjectCullSize und lodObjectCullDist auf ihre Minimalwerte gestellt sind, kann man diese Variable hoch setzen, um das Ausblenden gro\195\159er Objekte (z.B. B\195\164ume) zu unterbinden. Die Blizzard-Settings lassen sie jedoch auf 0 f\195\188r fast alle Voreinstellungen. |cffff0000(Das Ver\195\164ndern dieser Einstellung kann dazu f\195\188hren, dass alle Objekte kurz verschwinden, bevor sie neu gezeichnet werden.)"
L["lodObjectFadeScaleTooltip"] = "Bestimmt, ab welcher Entfernung Objekte mit niedrigem Level-of-Detail (LOD) ausgeblendet werden. |cffff0000(Das Ver\195\164ndern dieser Einstellung kann dazu f\195\188hren, dass alle Objekte kurz verschwinden, bevor sie neu gezeichnet werden.)"

L["terrainLodDistTooltip"] = "Bestimmt, ab welcher Entfernung ein niedriger Level-of-Detail (LOD) f\195\188r das Terrain verwendet werden soll."
L["wmoLodDistTooltip"] = "TODO"
L["entityLodDistTooltip"] = "TODO"

L["entityShadowFadeScaleTooltip"] = "Bestimmt, ab welcher Entfernung die Schatten von Objekten ausgeblendet werden sollen."
L["shadowModeTooltip"] = "Bestimmt, wie viele Schatten gezeichnet werden."
L["shadowTextureSizeTooltip"] = "Bestimmt, ob Schatten mit niedriger und h\195\182herer Aufl\195\182sung gezeichnet werden."
L["shadowSoftTooltip"] = "Bestimmt, ob Schatten weicher gezeichnet werden. (Abh\195\164ngig von den anderen Schatteneinstellungen ist es schwer, \195\188beraupt einen Unterschied zu bemerken.)"

L["graphicsTextureFilteringTooltip"] = "Verbessert die Sch\195\164rfe von Texturen, insbesondere wenn diese schr\195\164g von der Seite angeschaut werden."
L["projectedTexturesTooltip"] = "Aktiviert das Projezieren von Texturen auf die Umgebung; z.B. bei bestimmten AoE spells."

L["worldBaseMipTooltip"] = "Bestimmt die Detailiertheit von Terrain-Texturen. |cffff0000(Das Spiel kann kurz h\195\164ngen, nachdem die Option ge\195\164ndert wird.)"
L["terrainMipLevelTooltip"] = "Bestimmt die Qualit\195\164t von Textur-\195\156berg\195\164ngen im Terrain. |cffff0000(Das Spiel kann kurz h\195\164ngen, wenn zu 'low' gewechselt wird, w\195\164hrend worldBaseMipTooltip auf 'high' ist.)"
L["componentTextureLevelTooltip"] = "Bestimmt die Detailiertheit von Player-Texturen wie R\195\188stungen. Scheint nur einen Effekt bei R\195\188stungen neuerer WoW-Erweiterungen zu haben. |cffff0000(Das Spiel kann kurz h\195\164ngen, wenn zu 'low' gewechselt wird, w\195\164hrend worldBaseMipTooltip auf 'high' ist.)"







L["graphicsDepthEffects"] = "Falls jemand rausfindet, was das eigentlich macht, w\195\164re ich sehr interessiert! :-)"
L["ffxAntiAliasingMode"] = "Hei\195\159t Post-Process AA in den Settings. Sorgt f\195\188r Weichzeichnen."


-- AE: \195\132
-- OE: \195\150
-- UE: \195\156
-- ae: \195\164
-- oe: \195\182
-- ue: \195\188
-- sz: \195\159