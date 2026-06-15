local _, Graphit = ...

-- ===================================================================
-- AUTO-GENERATED skeleton by ExtractSettings.lua via /graphitcontroltypes.
-- Pre-filled with heuristic suggestions -- resolve every TODO by hand.
-- type = "slider" | "dropdown" | "checkbox". Ranges/values come from
-- GraphicsSettings_extracted.lua; to override, replace the string with a
-- table -- a slider's range/step or a dropdown's value list:
--   { type = "slider",   min = .., max = .., step = .. }
--   { type = "dropdown", values = { 0, 1, 2 } }
-- Re-generate after a dump changes child CVars, then re-apply decisions.
-- ===================================================================
Graphit.controlTypes = {

  -- graphicsViewDistance
  ["TerrainLodDiv"] = "dropdown",  -- TODO: 384/512/768 -- confirm dropdown (or slider if continuous)
  ["entityLodDist"] = "slider",  -- 4 values, 5..10
  ["entityShadowFadeScale"] = "slider",  -- 7 values, 10..50
  ["farclip"] = "slider",  -- 8 values, 1500..10000
  ["horizonClip"] = "slider",  -- 8 values, 1500..10000
  ["horizonStart"] = "slider",  -- 10 values, 400..4000
  ["terrainLodDist"] = "slider",  -- 8 values, 200..650
  ["wmoLodDist"] = "slider",  -- 4 values, 250..400

  -- graphicsShadowQuality
  ["shadowBlendCascades"] = "dropdown",  -- TODO: 0/1 -- checkbox if truly binary, else dropdown
  ["shadowMode"] = "dropdown",  -- TODO: dense set 0/1/2/3/4 -- dropdown or stepped slider
  ["shadowNumCascades"] = "dropdown",  -- TODO: dense set 1/2/3/4 -- dropdown or stepped slider
  ["shadowSoft"] = "dropdown",  -- TODO: 0/1 -- checkbox if truly binary, else dropdown
  ["shadowTextureSize"] = "dropdown",  -- TODO: 1024/2048 -- confirm dropdown (or slider if continuous)

  -- graphicsLiquidDetail
  ["reflectionMode"] = "dropdown",  -- TODO: 0/3 -- confirm dropdown (or slider if continuous)
  ["rippleDetail"] = "dropdown",  -- TODO: 0/1/2 -- confirm dropdown (or slider if continuous)
  ["waterDetail"] = "dropdown",  -- TODO: dense set 0/1/2/3 -- dropdown or stepped slider

  -- graphicsParticleDensity
  ["particleDensity"] = "slider",  -- 6 values, 0..100
  ["particleMTDensity"] = "slider",  -- 5 values, 0..100
  ["weatherDensity"] = "dropdown",  -- TODO: 0/1/3 -- confirm dropdown (or slider if continuous)

  -- graphicsDepthEffects
  ["DepthBasedOpacity"] = "dropdown",  -- TODO: 0/1 -- checkbox if truly binary, else dropdown
  ["refraction"] = "dropdown",  -- TODO: 0/1/2 -- confirm dropdown (or slider if continuous)
  ["sunShafts"] = "dropdown",  -- TODO: 0/1/2 -- confirm dropdown (or slider if continuous)

  -- graphicsComputeEffects
  ["clusteredShading"] = "dropdown",  -- TODO: 0/1 -- checkbox if truly binary, else dropdown
  ["particulatesEnabled"] = "dropdown",  -- TODO: 0/1 -- checkbox if truly binary, else dropdown
  ["volumeFog"] = "dropdown",  -- TODO: 0/1 -- checkbox if truly binary, else dropdown
  ["volumeFogLevel"] = "dropdown",  -- TODO: dense set 0/1/2/3 -- dropdown or stepped slider

  -- graphicsTextureResolution
  ["componentTextureLevel"] = "dropdown",  -- TODO: 0/1 -- checkbox if truly binary, else dropdown
  ["terrainMipLevel"] = "dropdown",  -- TODO: 0/1 -- checkbox if truly binary, else dropdown
  ["worldBaseMip"] = "dropdown",  -- TODO: 0/1/2 -- confirm dropdown (or slider if continuous)

  -- graphicsSpellDensity
  ["spellClutter"] = "dropdown",  -- TODO: 1/2/4 -- confirm dropdown (or slider if continuous)
  ["spellVisualDensityFilterSetting"] = "dropdown",  -- TODO: 1/2/4 -- confirm dropdown (or slider if continuous)

  -- graphicsEnvironmentDetail
  ["doodadLodScale"] = "slider",  -- 5 values, 50..150
  ["lodObjectCullSize"] = "slider",  -- 10 values, 14..35
  ["lodObjectFadeScale"] = "slider",  -- 7 values, 50..150
  ["lodObjectMinSize"] = "dropdown",  -- TODO: 0/20/30 -- confirm dropdown (or slider if continuous)

  -- graphicsGroundClutter
  ["groundEffectDensity"] = "slider",  -- 6 values, 16..256
  ["groundEffectDist"] = "slider",  -- 10 values, 40..320

}